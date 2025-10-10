Pod::Spec.new do |spec|
  spec.name         = "Codis"
  spec.version      = "1.0.0"
  spec.summary      = "一个基于 Swift 的 iOS 本地配置管理框架"
  spec.description  = <<-DESC
    Codis 是一个类型安全、响应式的 iOS 本地配置管理框架。
    提供基于 Combine 的配置变化监听、线程安全的配置操作、
    支持自定义类型配置的自动序列化等功能。
  DESC

  spec.homepage     = "https://github.com/LinHXiang/codis"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Lin HaoXiang" => "lin7946@outlook.com" }

  spec.platform     = :ios
  spec.ios.deployment_target = "13.0"
  spec.swift_version = "5.0"

  spec.source       = { :git => "https://github.com/LinHXiang/codis.git", :tag => "#{spec.version}" }

  spec.source_files = "codis/Core/**/*.{swift}"
  spec.frameworks   = "Foundation", "Combine"

  spec.requires_arc = true
end
