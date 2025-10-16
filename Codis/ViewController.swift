//
//  ViewController.swift
//  codis
//
//  Created by lin haoxiang on 2025/10/10.
//

import UIKit
import SwiftUI
import Combine

struct User: CodisLimit {
    var name: String = "你的名字"
}

// 测试枚举类型
// 注意：枚举的原始值类型（String/Int）必须遵循CodisBasicLimit协议
// 在我们的实现中，String和Int已经通过扩展遵循了CodisBasicLimit协议
enum Theme: String, CodisEnum, CaseIterable {    
    case light = "light"
    case dark = "dark"
    case auto = "auto"
}

class ViewController: UIViewController {
    @Codis(key: CodisKey.user, defaultValue: User())
    var user: User
    
    @Codis(key: CodisKey.optionalUser)
    var optionalUser: User?
    
    @Codis(key: CodisKey.userArray, defaultValue: [])
    var userArray: [User]

    // 枚举测试属性
    @Codis(key: CodisKey.theme, defaultValue: .auto)
    var theme: Theme

    // 新增：居中打开配置页面按钮
    private lazy var openConfigButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("打开 Codis 配置", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(openConfigTapped), for: .touchUpInside)
        return btn
    }()
    
    // 检查响应式的显示label
    private lazy var combineDisplayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        return label
    }()
    
    private lazy var changeConfigButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("修改 Codis 配置", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(changeConfigButtonTapped), for: .touchUpInside)
        return btn
    }()

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
                
        // 添加并布局按钮到页面中央
        view.addSubview(openConfigButton)
        view.addSubview(combineDisplayLabel)
        view.addSubview(changeConfigButton)

        NSLayoutConstraint.activate([
            combineDisplayLabel.bottomAnchor.constraint(equalTo: openConfigButton.topAnchor, constant: -20),
            combineDisplayLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            openConfigButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openConfigButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            changeConfigButton.topAnchor.constraint(equalTo: openConfigButton.bottomAnchor, constant: 20),
            changeConfigButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        // 测试会不会被关联响应
        $user
            .sink { user in
                print("user : \(user)")
            }
            .store(in: &cancellables)
        
        $optionalUser
            .sink { value in
                print("optionalUser : \(value)")
                self.combineDisplayLabel.text = "optionalUser : \(value)"
            }
            .store(in: &cancellables)
        
        
        $theme
            .sink { value in
                print("theme : \(value)")
            }
            .store(in: &cancellables)
    }
    
    // 按钮响应：呈现 Codis 配置页面
    @objc private func openConfigTapped() {
        let codisVC = UIHostingController(rootView: CodisView())
        let nav = UINavigationController(rootViewController: codisVC)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true, completion: nil)
    }
    
    @objc private func changeConfigButtonTapped() {

//        if optionalUser == nil {
//            optionalUser = User()
//        } else {
//            optionalUser = nil
//        }
//        
        // 测试切换枚举值
        let allThemes = Theme.allCases
        if let currentIndex = allThemes.firstIndex(of: theme) {
            let nextIndex = (currentIndex + 1) % allThemes.count
            theme = allThemes[nextIndex]
            print("切换后主题: \(theme)")
            print("切换后主题原始值: \(theme.rawValue)")
        }
    }

}

