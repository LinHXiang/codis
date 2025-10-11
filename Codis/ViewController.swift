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

class ViewController: UIViewController {
    @Codis(key: CodisKey.user)
    var user: User
    
    @Codis(key: CodisKey.optionalUser)
    var optionalUser: User?
    
    @Codis(key: CodisKey.userArray)
    var userArray: [User]

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
    
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
                
        // 添加并布局按钮到页面中央
        view.addSubview(openConfigButton)
        view.addSubview(combineDisplayLabel)

        NSLayoutConstraint.activate([
            openConfigButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openConfigButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            combineDisplayLabel.topAnchor.constraint(equalTo: openConfigButton.bottomAnchor, constant: 8),
            combineDisplayLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // 测试会不会被关联响应
        $user
            .sink { value in
                switch value {
                case .some(let t):
                    print("user 有值: \(t.name)")
                case .none:
                    print("user 为空")
                }
            }
            .store(in: &cancellables)
        
        $optionalUser
            .sink { value in
                switch value {
                case .some(let t):
                    print("optionalUser 有值: \(t?.name)")
                case .none:
                    print("optionalUser 为空")
                }
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if optionalUser == nil {
            optionalUser = User()
        } else {
            optionalUser = nil
        }
    }
}

