//
//  CodisView.swift
//  codis
//
//  Created by lin haoxiang on 2025/10/9.
//

import SwiftUI
import Combine

/// 配置列表视图（只读模式）- 直接从CodisManager获取配置数据展示
/// 适用于调试和查看配置状态，无需修改权限的场景
/// - 注意：此视图需要iOS 15.0+，使用了 `.searchable` 和 `.textSelection` 等API
@available(iOS 15.0, *)
public struct CodisView: View {

    @State private var configItems: [CodisConfigDisplayItem] = []
    @State private var searchText: String = ""

    // 过滤后的配置项
    private var filteredItems: [CodisConfigDisplayItem] {
        if searchText.isEmpty {
            return configItems
        } else {
            return configItems.filter { item in
                item.desc.localizedCaseInsensitiveContains(searchText) ||
                item.detail.localizedCaseInsensitiveContains(searchText) ||
                item.currentValue.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    public var body: some View {
        NavigationView {
            List {
                // 配置项列表（只读展示）
                Section(header: Text("配置项 (\(filteredItems.count))")) {
                    if filteredItems.isEmpty {
                        if searchText.isEmpty {
                            Text("暂无配置数据")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        } else {
                            Text("没有找到匹配的配置")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    } else {
                        ForEach(filteredItems) { item in
                            ConfigRowView(item: item)
                        }
                    }
                }

                // 配置统计信息
                Section(header: Text("统计信息")) {
                    HStack {
                        Text("显示配置数")
                        Spacer()
                        Text("\(filteredItems.count)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("总配置数")
                        Spacer()
                        Text("\(configItems.count)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("已设置配置数")
                        Spacer()
                        Text("\(getSetConfigCount())")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Codis配置")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "搜索配置项")
            .onAppear {
                loadConfigs()
            }
        }
    }

    /// 从CodisManager加载配置数据
    private func loadConfigs() {
        var displayItems: [CodisConfigDisplayItem] = []

        // 只遍历实际存储在CodisManager中的配置项
        for (keyString, value) in CodisManager.shared.config {
            // 根据key字符串找到对应的枚举值
            guard let configKey = CodisManager.shared.findKey(for: keyString) else {
                // 如果找不到对应的枚举，说明是过期的或无效的key，可以选择忽略或特殊处理
                continue
            }

            guard let value = value as? CodisLimitType else {
                continue
            }
            
            let displayItem = CodisConfigDisplayItem(
                configKey: configKey,
                currentValue: value.formatValue,
                originalValue: value
            )

            displayItems.append(displayItem)
        }

        // 按配置项名称排序
        configItems = displayItems.sorted { $0.configKey.desc < $1.configKey.desc }
    }

    /// 获取已设置的配置数量
    private func getSetConfigCount() -> Int {
        return CodisManager.shared.config.keys.count
    }
}

/// 配置展示项模型
@available(iOS 15.0, *)
struct CodisConfigDisplayItem: Identifiable {
    let id = UUID()
    let configKey: CodisKeyProtocol
    let currentValue: String
    let originalValue: CodisLimitType?  // 保存原始值用于展开显示

    var desc: String { configKey.desc }
    var detail: String { configKey.detail }
    var canEdit: Bool { configKey.canEdit }

    /// 是否可以展开显示（数组或字典类型）
    var isExpandable: Bool {
        guard let value = originalValue else { return false }
        return value is [Any] || value is [String: Any]
    }

    /// 获取展开后的详细文本
    var expandedText: String {
        guard let value = originalValue else { return "" }

        if let arrayValue = value as? [Any] {
            return arrayValue.enumerated().map { index, item in
                "\(index + 1). \(String(describing: item))"
            }.joined(separator: "\n")
        } else if let dictValue = value as? [String: Any] {
            return dictValue.map { key, value in
                "• \(key): \(String(describing: value))"
            }.sorted().joined(separator: "\n")
        }

        return ""
    }
}

/// 配置行视图（只读模式）
@available(iOS 15.0, *)
struct ConfigRowView: View {

    let item: CodisConfigDisplayItem
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 配置名称和状态
            HStack {
                Text(item.desc)
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                if !item.canEdit {
                    HStack(spacing: 2) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10))
                        Text("只读")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.orange)
                }
            }

            // 详细说明
            if !item.detail.isEmpty {
                Text(item.detail)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            // 当前值展示（重点突出）
            HStack {
                Text("当前值:")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                // 值标签 - 如果是可展开类型，添加展开指示器
                HStack(spacing: 6) {
                    Text(item.currentValue)
                        .font(.subheadline)
                        .foregroundColor(.accentColor)
                        .fontWeight(.medium)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(8)

                    if item.isExpandable {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .padding(.top, 4)

            // 展开内容
            if isExpanded {
                VStack(alignment: .leading, spacing: 4) {
                    Rectangle()
                        .fill(Color.accentColor.opacity(0.3))
                        .frame(height: 1)
                        .padding(.vertical, 4)

                    Text(item.expandedText)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineSpacing(2)
                        .padding(.horizontal, 8)
                        .background(Color.accentColor.opacity(0.05))
                        .cornerRadius(6)
                }
            }

            // 配置key（调试用，可选显示）
            if isDebugMode {
                HStack {
                    Text("Key:")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(item.configKey.key)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .textSelection(.enabled)
                }
                .padding(.top, 2)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle()) // 让整个区域都可点击
        .onTapGesture {
            if item.isExpandable {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }
        }
    }

    /// 是否处于调试模式
    private var isDebugMode: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
}

// MARK: - 扩展用于搜索功能
extension String {
    func localizedCaseInsensitiveContains(_ string: String) -> Bool {
        return self.range(of: string, options: [.caseInsensitive, .diacriticInsensitive]) != nil
    }
}
