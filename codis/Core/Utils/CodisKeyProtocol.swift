//
//  CodisKeyProtocol.swift
//  codis
//
//  Created by lin haoxiang on 2025/10/9.
//

import Foundation

/// Codis配置Key协议，提供描述信息和Combine支持
protocol CodisKeyProtocol {
    /// 配置的key值
    var key: String { get }

    /// 配置的描述信息，用于UI展示
    var desc: String { get }

    /// 配置的详细说明
    var detail: String { get }

    /// 是否可以在UI中编辑
    var canEdit: Bool { get }

    /// 配置默认值
    var defaultValue: CodisLimitType { get }
}
