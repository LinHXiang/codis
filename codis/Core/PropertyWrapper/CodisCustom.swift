//
//  CodisCustom.swift
//  codis
//
//  Created by lin haoxiang on 2025/10/10.
//

import Foundation
import Combine

/// Codis自定义类型配置包装器，专门用于CodisCustomLimitType类型
/// 提供@propertyWrapper语法糖，简化自定义配置类型的存取操作
/// 支持自动序列化和反序列化，底层使用JSON编解码
@propertyWrapper
public struct CodisCustom<T: CodisCustomLimitType> {
    /// 配置的key值，用于唯一标识该配置项
    let key: CodisKeyProtocol

    /// 使用协议枚举key初始化包装器
    /// - Parameter key: 实现了CodisKeyProtocol的配置枚举，必须提供defaultValue
    public init(key: CodisKeyProtocol) {
        self.key = key
    }

    /// 包装值，提供getter和setter来存取配置
    /// getter：从配置管理器获取值，如果不存在则返回key的默认值
    /// setter：将新值保存到配置管理器，自动进行序列化
    public var wrappedValue: T {
        get {            
            // 优先从配置管理器获取自定义类型的值
            if let cacheData = CodisManager.shared.getConfig(with: key) as? Data,
               let decode = T.self.decodeData(cacheData) {
                return decode
            }
            // 如果没有设置值，使用key的默认值
            guard let defaultValue = key.defaultValue as? T else {
                fatalError("配置项 \(key.key) 没有提供默认值，请确保实现了CodisKeyProtocol的defaultValue属性")
            }
            return defaultValue
        }
        set {
            let encode = T.self.encodeData(newValue)
            CodisManager.shared.updateConfig(with: key, value: encode)
        }
    }

    /// projectedValue 提供 Combine Publisher
    /// 监听自定义配置类型的变化
    public var projectedValue: AnyPublisher<T, Never> {
        // 使用现有的publisher方法监听Data变化，然后解码自定义类型
        return CodisManager.shared.publisher(for: key, type: Data.self)
            .compactMap { data in
                // 尝试解码数据
                if let data = data,
                   let decodedValue = T.decodeData(data) {
                    return decodedValue
                }

                // 如果没有数据，返回默认值
                guard let defaultValue = self.key.defaultValue as? T else {
                    return nil
                }
                return defaultValue
            }
            .removeDuplicates() // 避免重复发送相同的值
            .eraseToAnyPublisher()
    }
}
