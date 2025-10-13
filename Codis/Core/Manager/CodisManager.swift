//
//  CodisManager.swift
//  codis
//
//  Created by lin haoxiang on 2025/10/9.
//

import Foundation
import Combine

/// Codis配置管理器，提供线程安全的本地配置管理功能
/// 基于UserDefaults进行持久化存储，支持Combine响应式编程
/// 提供配置读取、写入、监听等功能，支持协议枚举和普通字符串key
public class CodisManager: ObservableObject {
    
    /// UserDefaults中存储配置数据的key
    fileprivate static let configKey = "codis_config_userdefault_key"

    /// 单例实例，提供全局访问点
    /// 初始化时从UserDefaults加载已保存的配置数据
    static let shared = {
        let shared = CodisManager()
        shared.config = UserDefaults.standard.value(forKey: configKey) as? [String: Any] ?? [:]
        return shared
    }()
    
    private init(){ }

    /// 当前配置数据的发布者，支持Combine响应式编程
    /// 当配置发生变化时，会自动通知所有订阅者
    @Published
    private var config: [String: Any] = [:]
    
    public static var config: [String: Any] {
        return shared.config
    }

    /// 已注册的配置键类型数组
    /// 用于存储所有实现了CodisKeyProtocol的类型，支持动态查找配置键
    /// 通过addKeyType方法添加新的配置键类型
    private(set) var keyTypes: [CodisKeyProtocol.Type] = []

    /// UserDefaults实例，用于配置持久化
    private let defaults = UserDefaults.standard

    /// 线程安全锁，确保多线程环境下的配置操作安全
    private let lock = NSLock()

    /// 更新配置值，使用协议枚举key（推荐使用）
    /// - Parameters:
    ///   - key: 实现了CodisKeyProtocol的配置枚举
    ///   - value: 新的配置值，必须实现CodisBasicLimit协议
    public static func updateConfig(with key: CodisKeyProtocol, value: (any CodisBasicLimit)?) {
        shared.lock.lock()
        defer { shared.lock.unlock() }

        if value != nil {
            shared.config[key.key] = value
        } else {
            shared.config.removeValue(forKey: key.key)
        }

        // 持久化整个config字典
        shared.defaults.set(shared.config, forKey: configKey)
        shared.defaults.synchronize()
    }
    
    /// 获取配置值，使用协议枚举key（推荐使用）
    /// - Parameter key: 实现了CodisKeyProtocol的配置枚举
    /// - Returns: 配置值，如果配置不存在则返回nil
    public static func getConfig(with key: CodisKeyProtocol) -> (any CodisBasicLimit)? {
        return shared.config[key.key] as? (any CodisBasicLimit)
    }
    
    /// 注册配置键类型到管理器中
    /// 注册后的类型可以用于通过字符串key查找对应的配置键实例
    /// - Parameter keyType: 实现了CodisKeyProtocol的配置键类型
    /// - Note: 相同的类型只会被注册一次，重复注册会被自动忽略
    public static func addKeyType(type keyType: CodisKeyProtocol.Type) {
        // 过滤类型数组是否已经包含,不包含的话才添加
        if !shared.keyTypes.contains(where: { $0 == keyType }) {
            shared.keyTypes.append(keyType)
        }
    }

    /// 根据key字符串查找对应的配置键实例
    /// - Parameter keyString: 配置键的字符串标识符
    /// - Returns: 找到的配置键实例，如果找不到则返回nil
    public static func findKey(for keyString: String) -> CodisKeyProtocol? {
        guard let keyType = shared.keyTypes.first(where: { $0.find(keyString: keyString) != nil }) else {
            return nil
        }
        return keyType.find(keyString: keyString)
    }

    // MARK: - 数据迁移功能

    /// 将旧的UserDefaults数据迁移到Codis中
    /// - Parameters:
    ///   - migrationKeys: 需要迁移的key列表
    public static func migrateFromUserDefaults(_ migrationKeys: [String]) {

        shared.lock.lock()
        defer { shared.lock.unlock() }

        var migratedCount = 0
        var skippedCount = 0
        var failedKeys: [String] = []

        for key in migrationKeys {
            // 如果Codis中已经有值，则跳过
            if shared.config[key] != nil {
                skippedCount += 1
                continue
            }

            // 从UserDefaults获取旧数据
            if let oldValue = shared.defaults.object(forKey: key) as? (any CodisBasicLimit) {
                shared.config[key] = oldValue
                // 删除旧值,保证UserDefaults不会过大
                shared.defaults.removeObject(forKey: key)
                migratedCount += 1
            } else {
                failedKeys.append(key)
            }
        }

        // 保存迁移后的配置
        if migratedCount > 0 {
            shared.defaults.set(shared.config, forKey: configKey)
            shared.defaults.synchronize()
        }

#if DEBUG
        print("迁移数据进度完成,成功迁移\(migratedCount)个偏好设置,失败\(failedKeys.count)个,跳过(已有数据)\(migratedCount)个")
#endif
    }
}

// MARK: - Combine支持
extension CodisManager {

    /// 监听指定key的配置变化
    /// - Parameter key: 配置key（协议类型）
    /// - Returns: 配置值的Publisher
    public static func publisher<T: CodisBasicLimit>(for key: CodisKeyProtocol) -> AnyPublisher<CodisCombineValue<T>, Never> {
        return shared.$config
            .map { config in
                guard let value = config[key.key] else {
                    return .none
                }
                // 检查是否是自定义类型（存储为Data，但配置类型不是Data）
                if let data = value as? Data, key.dataType != Data.self,
                   let decodableType = key.dataType as? Decodable.Type,
                   let decode = try? JSONDecoder().decode(decodableType, from: data) as? T {
                    
                    return .some(decode)
                }
                // 基础数据类型,直接转换返回
                if let basic = value as? T {
                    return .some(basic)
                }
                
                // unsafeBitCast(Optional<T>.none, to: T.self)
                return .none
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
