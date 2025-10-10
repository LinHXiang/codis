# Codis

一个基于 Swift 的 iOS 本地配置管理框架，提供类型安全、响应式的配置管理解决方案。

## 功能特性

- **类型安全**: 使用 Swift 泛型和协议确保配置项的类型安全
- **响应式编程**: 基于 Combine 框架，支持配置变化的实时监听
- **线程安全**: 使用 NSLock 确保多线程环境下的安全访问
- **属性包装器**: 通过 `@propertyWrapper` 提供简洁的配置访问语法
- **持久化存储**: 基于 UserDefaults 实现配置的本地持久化
- **协议化设计**: 使用协议定义配置项，提高代码的可扩展性和可维护性

## 项目结构

```
codis/
├── Core/                          # 核心框架代码
│   ├── Utils/                     # 工具类
│   │   ├── CodisManager.swift     # 配置管理器（核心类）
│   │   ├── CodisKeyProtocol.swift # 配置键协议定义
│   │   └── CodisLimitType.swift   # 配置值类型协议
│   ├── PropertyWrapper/           # 属性包装器
│   │   └── Codis.swift           # @Codis 属性包装器
│   └── Views/                     # 视图组件
│       └── CodisView.swift       # 配置管理视图
├── CodisKey.swift                 # 配置键枚举定义
├── AppDelegate.swift             # 应用委托
├── SceneDelegate.swift           # 场景委托
└── ViewController.swift          # 主控制器
```

## 核心组件

### 1. CodisManager
配置管理的核心类，提供以下功能：
- 配置的读取和写入
- 基于 UserDefaults 的持久化存储
- Combine 响应式支持
- 线程安全的配置操作

### 2. @Codis 属性包装器
简化配置访问的语法糖：
```swift
@Codis(key: CodisKey.userChatInputType)
var chatInputType: Int
```

### 3. CodisKeyProtocol 协议
配置键协议定义，任何遵循该协议的类型都可以作为配置键使用。项目中的 `CodisKey` 枚举只是实现示例，用于防止key字符串重复。

协议要求：
- `key`: 配置的字符串标识符
- `desc`: 配置描述信息
- `detail`: 配置的详细说明
- `canEdit`: 是否允许UI编辑
- `defaultValue`: 配置的默认值

## 使用示例

### 自定义配置键
你可以创建自己的配置键类型，只需遵循 `CodisKeyProtocol` 协议：

```swift
// 自定义配置键枚举（推荐方式 - 防止key重复）
enum AppConfigKey: String, CodisKeyProtocol {
    case themeMode = "app_theme_mode"
    case fontSize = "app_font_size"
    case enableNotification = "app_enable_notification"

    var key: String { rawValue }

    var desc: String {
        switch self {
        case .themeMode: return "主题模式"
        case .fontSize: return "字体大小"
        case .enableNotification: return "启用通知"
        }
    }

    var detail: String { desc }

    var canEdit: Bool { true }

    var defaultValue: CodisLimitType {
        switch self {
        case .themeMode: return "light"
        case .fontSize: return 16
        case .enableNotification: return true
        }
    }
}

// 使用自定义配置键
@Codis(key: AppConfigKey.themeMode)
var themeMode: String
```

### 基本配置操作
```swift
// 更新配置
CodisManager.shared.updateConfig(with: CodisKey.userChatInputType, value: 1)

// 获取配置
let inputType = CodisManager.shared.getConfig(with: CodisKey.userChatInputType)

// 使用自定义配置键
CodisManager.shared.updateConfig(with: AppConfigKey.themeMode, value: "dark")
let currentTheme = CodisManager.shared.getConfig(with: AppConfigKey.themeMode)
```

### 使用 CodisView 配置查看器
`CodisView` 是一个 SwiftUI 视图，用于查看和管理配置项：

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // 主界面
            MainView()
                .tabItem {
                    Label("首页", systemImage: "house")
                }

            // 配置管理界面
            CodisView()
                .tabItem {
                    Label("配置", systemImage: "gearshape")
                }
        }
    }
}
```

#### CodisView 功能特性：
- **只读配置展示**: 显示所有已设置的配置项
- **搜索功能**: 支持按配置名称、描述或值进行搜索
- **配置统计**: 显示总配置数、已设置配置数等统计信息
- **展开查看**: 支持展开查看数组和字典类型的详细内容
- **状态标识**:
  - 🔒 只读配置（canEdit = false）
  - ⭐ 有默认值的配置
- **调试模式**: 在DEBUG模式下显示配置key字符串

#### 使用示例（在UIKit中）：
```swift
class ConfigViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // 创建 SwiftUI 视图
        let codisView = CodisView()

        // 创建 hosting controller
        let hostingController = UIHostingController(rootView: codisView)

        // 添加为子视图控制器
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

        // 设置约束
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
```

### 使用属性包装器
```swift
class ChatViewController: UIViewController {
    @Codis(key: CodisKey.userChatInputType)
    var inputType: Int

    override func viewDidLoad() {
        super.viewDidLoad()
        // 直接使用配置
        if inputType == 0 {
            // 语音输入模式
        }

        // 修改配置
        inputType = 1
    }
}
```

### 监听配置变化

#### 方式一：直接监听 CodisManager 单例
```swift
class SettingsViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()

    init() {
        // 监听配置变化（使用项目中定义的 CodisKey）
        CodisManager.shared.publisher(for: CodisKey.userChatInputType, defaultValue: 0)
            .sink { [weak self] newValue in
                // 处理配置变化
                self?.updateInputMode(newValue)
            }
            .store(in: &cancellables)

        // 监听自定义配置变化（使用自定义的 AppConfigKey）
        CodisManager.shared.publisher(for: AppConfigKey.themeMode, defaultValue: "light")
            .sink { [weak self] newTheme in
                self?.updateTheme(newTheme)
            }
            .store(in: &cancellables)
    }
}
```

#### 方式二：通过属性包装器监听（使用 projectedValue）
```swift
class ChatViewController: UIViewController {
    // 使用项目中定义的 CodisKey
    @Codis(key: CodisKey.userChatInputType)
    var inputType: Int

    // 使用自定义的 AppConfigKey
    @Codis(key: AppConfigKey.themeMode)
    var themeMode: String

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        // 监听输入方式变化（通过 $属性名 访问 projectedValue）
        $inputType
            .sink { [weak self] newValue in
                // 监听配置变化，更新UI
                self?.updateInputMode(newValue)
            }
            .store(in: &cancellables)

        // 监听主题模式变化
        $themeMode
            .sink { [weak self] newTheme in
                self?.updateTheme(newTheme)
            }
            .store(in: &cancellables)
    }

    func updateInputMode(_ type: Int) {
        if type == 0 {
            print("切换到语音输入")
        } else {
            print("切换到键盘输入")
        }
    }

    func updateTheme(_ theme: String) {
        print("切换到主题: \(theme)")
        // 更新UI主题
    }
}
```

#### 监听多个配置变化
```swift
class AppConfigManager: ObservableObject {
    private var cancellables = Set<AnyCancellable>()

    @Published var currentInputType: Int = 0
    @Published var currentRole: [String: Any] = [:]

    init() {
        // 监听输入方式变化
        CodisManager.shared.publisher(for: CodisKey.userChatInputType, defaultValue: 0)
            .assign(to: \.currentInputType, on: self)
            .store(in: &cancellables)

        // 监听当前角色变化
        CodisManager.shared.publisher(for: CodisKey.currentRoleCache, defaultValue: [:])
            .assign(to: \.currentRole, on: self)
            .store(in: &cancellables)
    }
}
```

## 配置项说明

| 配置键 | 描述 | 默认值 | 说明 |
|--------|------|--------|------|
| `lastInstalledAppVersion` | 上次安装app版本 | `""` | 用于版本更新检测 |
| `appStoreVersion` | App Store版本信息 | `""` | 缓存的App Store版本 |
| `isFirstExperienceCount` | 首次体验流程次数 | `0` | 第4次提示购买会员 |
| `userChatInputType` | 用户输入方式 | `0` | 0=语音, 1=键盘 |
| `rolesCache` | 角色列表缓存 | `[]` | 角色数据缓存 |
| `currentRoleCache` | 当前角色缓存 | `[:]` | 当前选择角色 |

## 技术特点

### 协议化设计
- `CodisKeyProtocol`: 定义配置键的协议，任何遵循该协议的类型都可作为配置键
- `CodisLimitType`: 定义配置值类型的协议
- 支持自定义配置类型，不依赖于具体的枚举实现

**重要**: 项目中的 `CodisKey` 枚举只是协议的一个实现示例，用于演示如何使用枚举来避免key字符串重复。在实际项目中，你应该根据自己的需求创建自定义的配置键类型，只需遵循 `CodisKeyProtocol` 协议即可。

### 线程安全
- 使用 `NSLock` 确保多线程安全
- 所有配置操作都是原子性的

### 响应式编程
- 基于 Combine 框架
- 支持配置变化的实时监听
- 提供带默认值的 Publisher

## 安装要求

- iOS 13.0+
- Swift 5.0+
- Xcode 11.0+

## 未来扩展方向

### 1. 配置展示和编辑
- **CodisView 增强**: 允许在配置展示页面直接修改配置项
- **UI 编辑支持**: 为 `canEdit = true` 的配置项提供编辑界面
- **配置分类展示**: 按模块或功能分组展示配置项

### 2. 配置生命周期管理
- **修改记录查看**: 增加配置修改历史记录功能
- **配置版本控制**: 支持配置回滚到历史版本
- **变更审计**: 记录配置变更的时间、原因和操作者

### 3. 数据模型支持
- **自定义模型支持**: 支持符合 `Codable` 协议的自定义数据模型
- **复杂数据结构**: 支持嵌套对象和数组的配置存储
- **模型验证**: 增加数据模型验证机制

### 4. 安全存储增强
- **Keychain 存储支持**: 为敏感配置提供 Keychain 存储选项
- **数据加密**: 支持配置数据的加密存储
- **生物识别保护**: 对敏感配置增加生物识别验证

### 5. 高级功能
- **配置同步**: 支持 iCloud 或其他云服务的配置同步
- **A/B 测试支持**: 为配置增加实验组和对照组功能
- **远程配置**: 支持从远程服务器动态加载配置
- **配置模板**: 支持配置模板和预设方案

## 许可证

MIT License

## 作者

Lin HaoXiang

## 贡献

欢迎提交 Issue 和 Pull Request！