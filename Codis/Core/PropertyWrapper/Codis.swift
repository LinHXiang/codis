//
//  Codis.swift
//  codis
//
//  Created by lin haoxiang on 2025/10/9.
//

import Foundation
import Combine

/// Codis配置包装器，提供@propertyWrapper语法糖，简化配置存取操作
/// 支持类型安全的配置管理，底层使用CodisManager进行实际存储
/// 现在只需要传入key，默认值从key的defaultValue属性获取
@propertyWrapper
public struct Codis<T: CodisBasicLimit>{
    /// 配置的key值，用于唯一标识该配置项
    let key: CodisKeyProtocol

    /// 使用协议枚举key初始化包装器
    /// - Parameter key: 实现了CodisKeyProtocol的配置枚举，必须提供defaultValue
    public init(key: CodisKeyProtocol) {
        self.key = key
    }

    /// 包装值，提供getter和setter来存取配置
    /// getter：从配置管理器获取值，如果不存在则返回key的默认值
    /// setter：将新值保存到配置管理器
    public var wrappedValue: T {
        get {
            // 优先从配置管理器获取值
            if let value = CodisManager.getConfig(with: key) as? T {
                return value
            }
            // 如果没有设置值，使用key的默认值
            if let defaultValue = key.defaultValue as? T {
                return defaultValue
            }
            // 没有默认值则检查是否是可选类型,返回nil
            if T.self is ExpressibleByNilLiteral.Type {
                return unsafeBitCast(Optional<T>.none, to: T.self)
            }
            
            fatalError("配置项 \(key.key) 没有提供默认值且不是可选类型，请检查")
        }
        set {
            switch newValue {
            case let custom as any CodisLimit:
                setCustomTypeWrappedValue(custom)

            case let basic as any CodisBasicLimit:
                // 基础类型
                CodisManager.updateConfig(with: key, value: basic)

            default:
#if DEBUG
                fatalError("⚠️ 未知类型: \(type(of: newValue))")
#endif
            }
        }
    }
    
    /// projectedValue 直接返回 CodisManager 的 Publisher
    /// 这样属性本身的变化会通过 CodisManager 广播给所有监听者
    public var projectedValue: AnyPublisher<T?, Never> {
        return CodisManager.publisher(for: key)
    }
    
    // MARK: Set Method
    private func setCustomTypeWrappedValue(_ value: any CodisLimit) {
        // 判断是否为nil值
        let mirror = Mirror(reflecting: value)
        if mirror.displayStyle == .optional, mirror.children.count == 0 {
            CodisManager.updateConfig(with: key, value: nil)
            return
        }
        // 非nil,编码存入
        do {
            let canEncodeValue = value as Encodable
            let encode = try JSONEncoder().encode(canEncodeValue)
            CodisManager.updateConfig(with: key, value: encode)
        } catch {
#if DEBUG
            fatalError("自定义类型编码失败")
#endif
        }
    }
}
