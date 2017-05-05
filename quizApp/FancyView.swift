//
//  FancyView.swift
//  UdemySocialApp
//
//  Created by 東原与生 on 2017/03/16.
//  Copyright © 2017年 yoki. All rights reserved.
//

import UIKit

class FancyView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        layer.shadowOpacity = 0.5
    }

}
