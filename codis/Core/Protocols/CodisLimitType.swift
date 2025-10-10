//
//  CodisLimitType.swift
//  codis
//
//  Created by lin haoxiang on 2025/10/9.
//

import Foundation

/// Codis配置包装器支持的类型限制协议
/// 只有实现了该协议的类型才能被CodisWrapper包装器使用
/// 支持基本数据类型、集合类型及其NS变种，确保配置存储的类型安全
public protocol CodisLimitType {
    /// 格式化配置值用于显示
    var formatValue: String { get }
}

// MARK: - 数组类型支持
extension NSArray: CodisLimitType {
    public var formatValue: String { return "数组 (\(self.count)项)" }
}
extension Array: CodisLimitType {
    public var formatValue: String { return "数组 (\(self.count)项)" }
}

// MARK: - 字典类型支持
extension Dictionary: CodisLimitType {
    public var formatValue: String { return "字典 (\(self.count)对键值)" }
}
extension NSDictionary: CodisLimitType {
    public var formatValue: String { return "字典 (\(self.count)对键值)" }
}

// MARK: - 字符串类型支持
extension NSString: CodisLimitType {
    public var formatValue: String { return (self as String).isEmpty ? "空字符串" : (self as String) }

}
extension String: CodisLimitType {
    public var formatValue: String { return self.isEmpty ? "空字符串" : self }
}

// MARK: - 数值类型支持
extension Int: CodisLimitType {
    public var formatValue: String { return  "\(self)" }
}
extension Double: CodisLimitType {
    public var formatValue: String { return String(format: "%.2f", self) }
}
extension Float: CodisLimitType {
    public var formatValue: String { return String(format: "%.2f", self) }
}
extension CGFloat: CodisLimitType {
    public var formatValue: String { return String(format: "%.2f", self) }
}

// MARK: - 布尔类型支持
extension Bool: CodisLimitType {
    public var formatValue: String { return self ? "开启" : "关闭" }
}

// MARK: - NSNumber支持
extension NSNumber: CodisLimitType {
    public var formatValue: String { return "\(self)" }
}

// MARK: - 二进制数据支持
extension Data: CodisLimitType{
    public var formatValue: String { return "二进制数据: 大小\(self.count)" }
}
extension NSData: CodisLimitType{
    public var formatValue: String { return "二进制数据: 大小\(self.count)" }
}
