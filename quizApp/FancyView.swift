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
        let SHADOW_GRAY: CGFloat = 120.0 / 255.0
        layer.shadowColor = UIColor(red:SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).cgColor
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 0.5
        layer.shadowOffset = CGSize(width: 1.0, height: 7.0)
        layer.cornerRadius = 2.0
    }

}
