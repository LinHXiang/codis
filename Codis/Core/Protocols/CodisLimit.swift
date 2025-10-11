//
//  File.swift
//  Codis
//
//  Created by lin haoxiang on 2025/10/11.
//

import Foundation

public protocol CodisLimit: CodisBasicLimit, Codable, Equatable { }

// MARK: 默认实现
extension CodisLimit {
    public var formatValue: String {
        return "自定义类型\(type(of: self))"
    }
}

// MARK: - 自动让 Optional<Wrapped> 继承行为
extension Optional: CodisLimit, CodisBasicLimit where Wrapped: CodisLimit {
    public var formatValue: String {
        switch self {
        case .some(let wrapped):
            return "自定义类型\(type(of: wrapped)): (\(wrapped.formatValue))"
        case .none:
            return "自定义类型\(Wrapped.self): nil"
        }
    }
}

// MARK: - 可选：让数组也遵循
extension Array: CodisLimit where Element: CodisLimit {
    public var formatValue: String {
        "数组[\(count)]"
    }
}
