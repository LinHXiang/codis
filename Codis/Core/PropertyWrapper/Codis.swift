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

    private let valueWrapper: CodisOptionalWrapper<T>
    
    /// 使用协议枚举key初始化包装器
    /// - Parameter key: 实现了CodisKeyProtocol的配置枚举，必须提供defaultValue
    public init(key: CodisKeyProtocol, defaultValue: T) {
        self.key = key
        self.valueWrapper = CodisOptionalWrapper(value: defaultValue)
    }

    /// 无参数初始化器，T必须是可选类型
    /// - Parameter key: 实现了CodisKeyProtocol的配置枚举
    public init(key: CodisKeyProtocol) where T: ExpressibleByNilLiteral {
        self.key = key
        self.valueWrapper = CodisOptionalWrapper<T>()
    }
    
    /// 包装值，提供getter和setter来存取配置
    /// getter：从配置管理器获取值，如果不存在则返回key的默认值
    /// setter：将新值保存到配置管理器
    public var wrappedValue: T {
        get {
            getWrappedValue()
        }
        set {
            switch newValue {
            case let custom as any CodisLimit:
                setCustomTypeWrappedValue(custom)
            case let enumValue as any CodisEnum:
                // 枚举类型 - 存储原始值
                setRawRepresentableWrappedValue(enumValue)
            case let enumArray as [any CodisEnum]:
                // 枚举类型数组 - 转换为NSArray存储以解决Equatable问题
                let enumRawArray = enumArray.map({ $0.rawValue })
                let nsArray = NSArray(array: enumRawArray)
                CodisManager.updateConfig(with: key, value: nsArray)
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
    
// MARK: Get Method
    private func getWrappedValue(_ configDict: [String: Any] = CodisManager.shared.config) -> T {
        // 没有找到K-V
        guard let value = configDict[key.key] else {
            return valueWrapper.defaultValue
        }
        // 判断是否为nil值
        let mirror = Mirror(reflecting: value)
        if mirror.displayStyle == .optional, mirror.children.count == 0 {
            return valueWrapper.defaultValue
        }

        // 检查是否枚举
        if let enumType = T.self as? any CodisEnum.Type {
            if let rawValue = value as? (any CodisBasicLimit),
               let converted = enumType._createEnum(from: rawValue) as? T {
                return converted
            }
        }

        // 检查是否枚举数组
        if let nsArray = value as? NSArray, // config对于枚举数组,存入的是nsarray
           let arrayType = T.self as? any SequenceElementExtractable.Type, // 用辅助协议,方便提取实际类型
           let elementType = arrayType.elementType as? any CodisEnum.Type { // 获取元素类型用于转换
            
            // 尝试转成T,成功则返回,否则返回默认值
            let converted:[any CodisEnum] = nsArray.compactMap({ raw in
                guard let limit = raw as? any CodisBasicLimit else {
                    return nil
                }
                return elementType._createEnum(from: limit)
            })
                        
            if let result = converted as? T {
                return result
            }
        }
        
        // 检查是否自定义类型
        if let data = value as? Data, T.self is (any CodisLimit.Type), // 数据为data,但是T类型是CodisLimit,尝试解码
           let decodableType = T.self as? Decodable.Type, // 获取Decodable进行解码
            let decode = try? JSONDecoder().decode(decodableType, from: data) as? T {// 尝试解码
            return decode
        }
        // 基础数据类型,直接转换返回
        if let basic = value as? T {
            return basic
        }

        return valueWrapper.defaultValue
    }
    
// MARK: Set Method
    /// 自定义类型处理
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
            fatalError("自定义类型编码失败:\(error)")
#endif
        }
    }
    /// 枚举处理
    private func setRawRepresentableWrappedValue(_ value: any CodisEnum) {
        // 确保原始值遵循CodisBasicLimit协议
        let basicValue = value.rawValue
        CodisManager.updateConfig(with: key, value: basicValue)
    }

    
// MARK: Combine Support
    /// projectedValue 直接监听 config 变化，避免重复数据处理
    /// 在 Codis 内部统一处理类型转换，提高效率
    public var projectedValue: AnyPublisher<T, Never> {
        return CodisManager.shared.$config
            .map { config in
                return getWrappedValue(config)
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}

fileprivate struct CodisOptionalWrapper<T: CodisBasicLimit> {
    
    let defaultValue: T
    
    init(value: T) {
        self.defaultValue = value
    }
    
    init() where T: ExpressibleByNilLiteral {
        self.defaultValue = nil
    }
}

// 定义一个协议来提取元素类型
fileprivate protocol SequenceElementExtractable {
    associatedtype Element
    static var elementType: Element.Type { get }
}

// 为数组实现协议
extension Array: SequenceElementExtractable {
    static var elementType: Element.Type {
        return Element.self
    }
}
