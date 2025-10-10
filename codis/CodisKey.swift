//
//  CodisKey.swift
//  codis
//
//  Created by lin haoxiang on 2025/10/9.
//

import Foundation

/// Codis配置Key枚举，用于统一管理所有配置键，防止重复命名
enum CodisKey: String, CaseIterable, CodisKeyProtocol {

    case lastInstalledAppVersion = "LastInstalledAppVersion"
     
    case appStoreVersion = "AppStoreVersion"

    case isFirstExperienceCount = "isFirstExperienceCount"
    
    case userChatInputType = "userChatInputType"
    
    case rolesCache = "rolesCache"
    
    case currentRoleCache = "currentRoleCache"

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
        case .lastInstalledAppVersion: 
            return "上次安装app版本"
        case .appStoreVersion: 
            return "app store软件版本"
        case .isFirstExperienceCount: 
            return "首次体验流程次数"
        case .userChatInputType:
            return "用户输入方式缓存"
        case .rolesCache:
            return "角色列表数据缓存"
        case .currentRoleCache:
            return "当前选择的角色缓存"
        }
    }

    /// 配置的详细说明，提供更完整的配置用途解释
    /// - Returns: 详细的配置功能描述
    var detail: String {
        switch self {
        case .lastInstalledAppVersion: 
            return "上次安装app版本"
        case .appStoreVersion:
            return "缓存的App Store版本信息"
        case .isFirstExperienceCount: 
            return "首次体验(开场白+1,首次发送+1,首次发音+1),第四次则提示购买会员"
        case .userChatInputType:
            return "对话页面的输入方式: 0 = .voice, 1 = .keyboard"
        case .rolesCache:
            return "角色列表数据缓存"
        case .currentRoleCache:
            return "当前选择的角色缓存"
        }
    }

    /// 是否可以在UI中编辑，用于控制配置是否允许用户手动修改
    /// - Returns: true表示可以在配置界面编辑，false表示只读配置
    var canEdit: Bool {
        return false
    }

    /// 配置默认值，用于在应用首次使用或重置时提供初始值
    /// - Returns: 配置的默认值，如果为nil则表示没有默认值
    var defaultValue: CodisLimitType {
        switch self {
        case .lastInstalledAppVersion:
            return ""
        case .appStoreVersion:
            return ""
        case .isFirstExperienceCount:
            return 0
        case .userChatInputType:
            return 0
        case .rolesCache:
            return []
        case .currentRoleCache:
            return [:]
        }
    }

    /// 根据字符串key查找对应的枚举值
    /// - Parameter keyString: 配置键的字符串标识符
    /// - Returns: 对应的枚举值，如果找不到则返回nil
    static func find(keyString: String) -> CodisKey? {
        return CodisKey(rawValue: keyString)
    }
}
