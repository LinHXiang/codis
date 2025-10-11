//
//  CodisKey.swift
//  codis
//
//  Created by lin haoxiang on 2025/10/9.
//

import Foundation

/// Codis配置Key枚举，用于统一管理所有配置键，防止重复命名
enum CodisKey: String, CaseIterable, CodisKeyProtocol {

    case user = "user"
     
    case optionalUser = "optionalUser"
    
    case userArray = "userArray"
    
    // MARK: - CodisKeyProtocol 实现

    /// 获取key的字符串值
    /// - Returns: 配置项的唯一标识符
    var key: String {
        return self.rawValue
    }

    /// 配置的描述信息，用于UI展示
    /// - Returns: 用户友好的配置名称
    var desc: String {
        switch self {
        case .user:
            return "自定义类型User"
        case .optionalUser:
            return "可选自定义类型User"
        case .userArray:
            return "自定义类型User数组"
        }
    }

    /// 配置的详细说明，提供更完整的配置用途解释
    /// - Returns: 详细的配置功能描述
    var detail: String {
        return desc
    }

    /// 是否可以在UI中编辑，用于控制配置是否允许用户手动修改
    /// - Returns: true表示可以在配置界面编辑，false表示只读配置
    var canEdit: Bool {
        return false
    }

    /// 数据类型 - 根据配置项返回对应的类型
    var dataType: any CodisBasicLimit.Type {
        switch self {
        case .user, .optionalUser:
            return User.self
        case .userArray:
            return [User].self
        }
    }

    /// 配置默认值，用于在应用首次使用或重置时提供初始值
    /// - Returns: 配置的默认值，如果为nil则表示没有默认值
    var defaultValue: (any CodisBasicLimit)? {
        switch self {
        case .user, .optionalUser:
            return nil
        case .userArray:
            return [User]()
        }
    }

    /// 根据字符串key查找对应的枚举值
    /// - Parameter keyString: 配置键的字符串标识符
    /// - Returns: 对应的枚举值，如果找不到则返回nil
    static func find(keyString: String) -> CodisKey? {
        return CodisKey(rawValue: keyString)
    }
}
