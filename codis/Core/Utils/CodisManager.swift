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
class CodisManager: ObservableObject {
    
    /// UserDefaults中存储配置数据的key
    fileprivate static let configKey = "codis_config_userdefault_key"

    /// 单例实例，提供全局访问点
    /// 初始化时从UserDefaults加载已保存的配置数据
    static let shared = {
        let shared = CodisManager()
        shared.config = UserDefaults.standard.value(forKey: configKey) as? [String: Any] ?? [:]
        return shared
    }()

    /// 当前配置数据的发布者，支持Combine响应式编程
    /// 当配置发生变化时，会自动通知所有订阅者
    @Published
    private(set) var config: [String: Any] = [:]

    /// UserDefaults实例，用于配置持久化
    private let defaults = UserDefaults.standard

    /// 线程安全锁，确保多线程环境下的配置操作安全
    private let lock = NSLock()

    /// 更新配置值，使用协议枚举key（推荐使用）
    /// - Parameters:
    ///   - key: 实现了CodisKeyProtocol的配置枚举
    ///   - value: 新的配置值，必须实现CodisLimitType协议
    func updateConfig(with key: CodisKeyProtocol, value: CodisLimitType) {
        lock.lock()
        defer { lock.unlock() }

        config[key.key] = value

        // 持久化整个config字典
        defaults.set(config, forKey: Self.configKey)
        defaults.synchronize()
    }
    
    /// 获取配置值，使用协议枚举key（推荐使用）
    /// - Parameter key: 实现了CodisKeyProtocol的配置枚举
    /// - Returns: 配置值，如果配置不存在则返回nil
    func getConfig(with key: CodisKeyProtocol) -> CodisLimitType? {
        return config[key.key] as? CodisLimitType
    }
}

// MARK: - Combine支持
extension CodisManager {

    /// 监听指定key的配置变化
    /// - Parameter key: 配置key（协议类型）
    /// - Returns: 配置值的Publisher
    func publisher<T: CodisLimitType>(for key: CodisKeyProtocol, type: T.Type) -> AnyPublisher<T?, Never> {
        return $config
            .map { config in
                return config[key.key] as? T
            }
            .eraseToAnyPublisher()
    }

    /// 监听指定key的配置变化（带默认值）
    /// - Parameters:
    ///   - key: 配置key（协议类型）
    ///   - defaultValue: 默认值
    /// - Returns: 配置值的Publisher
    func publisher<T: CodisLimitType>(for key: CodisKeyProtocol, defaultValue: T) -> AnyPublisher<T, Never> {
        return $config
            .map { config in
                return (config[key.key] as? T) ?? defaultValue
            }
            .eraseToAnyPublisher()
    }
}
