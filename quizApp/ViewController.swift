//
//  ViewController.swift
//  quizApp
//
//  Created by 東原与生 on 2017/04/23.
//  Copyright © 2017年 yoki. All rights reserved.
//

import UIKit
import MBCircularProgressBar

class ViewController: UIViewController {
    
    @IBOutlet weak var circleBar: MBCircularProgressBarView!
    @IBOutlet weak var levelLabel: UILabel!
    
    var exp: CGFloat = 0
    var level: Int = 0
    
    override func viewWillAppear(_ animated: Bool) {
        exp = GameScore.fetchExp().0
        level = GameScore.fetchExp().1
        
        levelLabel.text = "\(level)"
        UIView.animate(withDuration: 2) {
            self.circleBar.value = self.exp
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.circleBar.value = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            UIView.animate(withDuration: 2, animations: { 
                self.circleBar.value = self.exp
            })
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

