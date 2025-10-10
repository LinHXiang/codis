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
public struct Codis<T: CodisLimitType>{
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
            if let value = CodisManager.shared.getConfig(with: key) as? T {
                return value
            }
            // 如果没有设置值，使用key的默认值(基础数据类型必须赋值)
            guard let defaultValue = key.defaultValue as? T else {
                // 如果没有默认值，返回类型默认值（这不应该发生，因为协议要求有defaultValue）
                fatalError("配置项 \(key.key) 没有提供默认值，请确保实现了CodisKeyProtocol的defaultValue属性")
            }
            return defaultValue
        }
        set {
            CodisManager.shared.updateConfig(with: key, value: newValue)
        }
    }
    
    /// projectedValue 直接返回 CodisManager 的 Publisher
    /// 这样属性本身的变化会通过 CodisManager 广播给所有监听者
    public var projectedValue: AnyPublisher<T?, Never> {
        return CodisManager.shared.publisher(for: key)
    }
}
