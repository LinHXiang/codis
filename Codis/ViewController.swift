//
//  ViewController.swift
//  codis
//
//  Created by lin haoxiang on 2025/10/10.
//

import UIKit
import SwiftUI

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 添加并布局按钮到页面中央
        view.addSubview(openConfigButton)
        NSLayoutConstraint.activate([
            openConfigButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openConfigButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        var user = User()
        user.name = "用户1"
        
        var optionalUser = User()
        optionalUser.name = "用户2"

        self.user = user
        self.optionalUser = optionalUser
    }
    
    // 按钮响应：呈现 Codis 配置页面
    @objc private func openConfigTapped() {
        let codisVC = UIHostingController(rootView: CodisView())
        let nav = UINavigationController(rootViewController: codisVC)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true, completion: nil)
    }
}

