//
//  answerCell.swift
//  quizApp
//
//  Created by 東原与生 on 2017/05/04.
//  Copyright © 2017年 yoki. All rights reserved.
//

import UIKit

class answerCell: UITableViewCell {
    
    @IBOutlet weak var problemLabel:UILabel!
    @IBOutlet weak var answerLabel:UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
