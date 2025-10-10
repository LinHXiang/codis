//
//  CodisCustomLimitType.swift
//  codis
//
//  Created by lin haoxiang on 2025/10/10.
//

import Foundation

public protocol CodisCustomLimitType: CodisLimitType, Codable, Equatable {
    /// 解码数据(提取用)
    static func decodeData(_ data: Data) -> Self?
    /// 编码数据(保存用)
    static func encodeData(_ data: Self?) -> Data?
}

// MARK: - 数组扩展支持
public extension Array where Element: CodisCustomLimitType {
    /// 数组解码数据
    static func decodeArrayData(_ data: Data) -> [Element]? {
        do {
            return try JSONDecoder().decode([Element].self, from: data)
        } catch {
            print("数组解码错误: \(error)")
            return nil
        }
    }

    /// 数组编码数据
    func encodeArrayData() -> Data? {
        do {
            return try JSONEncoder().encode(self)
        } catch {
            print("数组编码错误: \(error)")
            return nil
        }
    }

    /// 格式化显示数组
    var formatArrayValue: String {
        return "数组 (\(count)个元素)"
    }
}

public extension CodisCustomLimitType {
    /// 解码数据(提取用)
    static func decodeData(_ data: Data) -> Self? {
        do {
            return try JSONDecoder().decode(Self.self, from: data)
        } catch {
            print("解码错误: \(error)")
            return nil
        }
    }
    
    /// 编码数据(保存用)
    static func encodeData(_ data: Self?) -> Data? {
        guard let data = data else { return nil }
        
        do {
            return try JSONEncoder().encode(data)
        } catch {
            print("编码错误: \(error)")
            return nil
        }
    }
}
