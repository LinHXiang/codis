//
//  ViewController.swift
//  codis
//
//  Created by lin haoxiang on 2025/10/10.
//

import UIKit

struct User: CodisLimit {
    var name: String = "你的名字"
}

class ViewController: UIViewController {

    var user: User = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        print(user.formatValue)
        
    }
}

