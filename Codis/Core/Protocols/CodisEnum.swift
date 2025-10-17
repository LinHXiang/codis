//
//  CodisEnum.swift
//  Codis
//
//  Created by lin haoxiang on 2025/10/16.
//

import Foundation

public protocol CodisEnum: CodisBasicLimit, RawRepresentable where RawValue: CodisBasicLimit {
    static func _createEnum(from rawValue: any CodisBasicLimit) -> Self?
}

public extension CodisEnum {
    var formatValue: String {
        return "自定义枚举"
    }
    
    static func _createEnum(from rawValue: any CodisBasicLimit) -> Self? {
        guard let raw = rawValue as? RawValue else { return nil }
        return Self(rawValue: raw)
    }
}
