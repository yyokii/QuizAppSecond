//
//  ViewController.swift
//  quizApp
//
//  Created by 東原与生 on 2017/04/23.
//  Copyright © 2017年 yoki. All rights reserved.
//

import UIKit
import LTMorphingLabel
import MBCircularProgressBar

class ViewController: UIViewController {
    
    @IBOutlet weak var circleBar: MBCircularProgressBarView!
    @IBOutlet weak var levelLabel: LTMorphingLabel!
    @IBOutlet weak var ratioLabel: LTMorphingLabel!
    
    var exp: CGFloat = 0
    var level: Int = 0
    var ratio: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        levelLabel.morphingEffect = .anvil
        ratioLabel.morphingEffect = .pixelate
    }
    
    override func viewDidAppear(_ animated: Bool) {
        exp = GameScore.fetchExp().0
        level = GameScore.fetchExp().1
        ratio = GameScore.ratio()
        
        self.circleBar.value = 0
        
        if GameScore.fetchAllGameScore().count == 0 {
            self.ratioLabel.text = "Ratio　：　0 %"
        } else {
            self.ratioLabel.text = "Ratio　：　\(ratio) %"
        }
        
        levelLabel.text = "\(level)"
        UIView.animate(withDuration: 2) {
            self.circleBar.value = self.exp
        }
    }
    
    //クイズ画面に遷移するアクション
    @IBAction func goQuizAction(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "goQuiz", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

