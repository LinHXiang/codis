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

### 3. CodisKey 枚举
统一管理所有配置键，包含：
- 应用版本信息
- 用户体验计数
- 用户偏好设置
- 角色数据缓存

## 使用示例

### 基本配置操作
```swift
// 更新配置
CodisManager.shared.updateConfig(with: CodisKey.userChatInputType, value: 1)

// 获取配置
let inputType = CodisManager.shared.getConfig(with: CodisKey.userChatInputType)
```

### 使用属性包装器
```swiftnclass ChatViewController: UIViewController {
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
```swift
class SettingsViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()

    init() {
        // 监听配置变化
        CodisManager.shared.publisher(for: CodisKey.userChatInputType, defaultValue: 0)
            .sink { [weak self] newValue in
                // 处理配置变化
                self?.updateInputMode(newValue)
            }
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
- `CodisKeyProtocol`: 定义配置键的协议
- `CodisLimitType`: 定义配置值类型的协议
- 支持自定义配置类型

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

## 许可证

MIT License

## 作者

Lin HaoXiang

## 贡献

欢迎提交 Issue 和 Pull Request！