//
//  Extension.swift
//  TimerQuiz
//
//  Created by 酒井文也 on 2016/03/24.
//  Copyright © 2016年 just1factory. All rights reserved.
//

import Foundation
import MBCircularProgressBar

//NSMutableArrayクラスのshuffleメソッドを実装
extension NSMutableArray {
    
    //NSMutableArrayの中身をランダムに並べ替えする処理
    func shuffle(_ count: Int) {
        for i in 0..<count {
            let nElements: Int = count - i
            let n: Int = Int(arc4random_uniform(UInt32(nElements))) + i //iは自分の位置までずらしている（要素の自分位置）
            self.exchangeObject(at: i, withObjectAt: n)
        }
    }
    
}
