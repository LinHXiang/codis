//
//  CodisCombineValue.swift
//  Codis
//
//  Created by lin haoxiang on 2025/10/11.
//

import Foundation

/*
TODO:
 CodisBasicLimit已经扩展了自定义的可选类型,但是在combine中似乎没有太好的办法在回调T的时候返回nil,所以加一个包装容器来返回值
后续有好办法再调整
 */

/// Combine回调包装器
public enum CodisCombineValue<T: CodisBasicLimit>: Equatable {
    case some(T)
    case none
}

