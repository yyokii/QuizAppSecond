//
//  QuizController.swift
//  quizApp
//
//  Created by 東原与生 on 2017/04/23.
//  Copyright © 2017年 yoki. All rights reserved.
//

import UIKit

//回答した番号の識別用enum
enum Answer: Int {
    case one = 1
    case two = 2
    case three = 3
    case four = 4
}

//ゲームに関係する定数
struct QuizStruct {
    static let timerDuration: Double = 10
    static let dataMaxCount: Int = 5
    static let limitTimer: Double = 10.000
    static let defaultCounter: Int = 10
}

class QuizController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var timerDisplayLabel: UILabel!
    
    @IBOutlet var problemCountLabel: UILabel!
    @IBOutlet var problemTextLabel: UILabel!
    
    @IBOutlet var imgView: UIImageView!
    
    @IBOutlet var answerButtonOne: UIButton!
    @IBOutlet var answerButtonTwo: UIButton!
    @IBOutlet var answerButtonThree: UIButton!
    @IBOutlet var answerButtonFour: UIButton!
    
    //タイマー関連のメンバ変数
    var pastCounter: Int = 10  //経過時間表示用
    var perSecTimer: Timer? = nil
    var doneTimer: Timer? = nil
    
    //問題関連のメンバ変数
    var counter: Int = 0
    
    //正解数と経過した時間
    var correctProblemNumber: Int = 0
    var totalSeconds: Double = 0.000
    
    //問題の内容を入れておくメンバ変数（計5問）
    var problemArray: NSMutableArray = []
    
    //問題毎の回答時間を算出するための時間を一時的に格納するためのメンバ変数
    var tmpTimerCount: Double!
    
    //タイム表示用のメンバ変数
    var timeProblemSolvedZero: Date!  //画面表示時点の時間
    var timeProblemSolvedOne: Date!   //第1問回答時点の時間
    var timeProblemSolvedTwo: Date!   //第2問回答時点の時間
    var timeProblemSolvedThree: Date! //第3問回答時点の時間
    var timeProblemSolvedFour: Date!  //第4問回答時点の時間
    var timeProblemSolvedFive: Date!  //第5問回答時点の時間
    
    //正解の選択肢（1~4）、csvには記入していないので毎回作る
    var answerSelection = -1
    
    //選択肢の格納
    var options: Array<String> = ["a","a","a","a"]

    //不正解問題の情報
    var incorrectProblem = Dictionary<String,String>()
    var incProblem:String!
    var reviewAnswer:String!
    
        
    //画面出現中のタイミングに読み込まれる処理
    override func viewWillAppear(_ animated: Bool) {
        
        //問題配列の取得
        self.setProblemsFromCSV()
    }
    
    //画面出現しきったタイミングに読み込まれる処理
    override func viewDidAppear(_ animated: Bool) {
        
        //ラベルを表示を「しばらくお待ちください...」から「あと10秒」という表記へ変更する
        self.timerDisplayLabel.text = "あと" + String(self.pastCounter) + "秒"
        
        //ボタンを全て活性状態にする
        self.allAnswerBtnEnabled()
        
        //問題を取得する
        self.createNextProblem()
        
        //1問目の解き始めの時間を保持する
        self.timeProblemSolvedZero = Date()
        
        //タイマーをセットする
        self.setTimer()
    }
    
    //画面が消えるタイミングに読み込まれる処理
    override func viewWillDisappear(_ animated: Bool) {
        
        //ラベルを表示を「しばらくお待ちください...」へ戻す
        self.timerDisplayLabel.text = "しばらくお待ちください..."
        
        //タイマーをリセットしておく 、大事そう
        self.resetTimer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ナビゲーションのデリゲート設定
        self.navigationController?.delegate = self
        self.navigationItem.title = "問題を解く"
        
    }
    
    //各選択肢のボタンアクション
    @IBAction func answerActionOne(_ sender: AnyObject) {
        self.judgeCurrentAnswer(Answer.one.rawValue)
    }
    
    @IBAction func answerActionTwo(_ sender: AnyObject) {
        self.judgeCurrentAnswer(Answer.two.rawValue)
    }
    
    @IBAction func answerActionThree(_ sender: AnyObject) {
        self.judgeCurrentAnswer(Answer.three.rawValue)
    }
    
    @IBAction func answerActionFour(_ sender: AnyObject) {
        self.judgeCurrentAnswer(Answer.four.rawValue)
    }
    
    func setTimer(){
        //毎秒ごとにperSecTimerDoneメソッドを実行するタイマーを作成する
        self.perSecTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(QuizController.perSecTimerDone), userInfo: nil, repeats: true)
        
        //指定秒数後にtimerDoneメソッドを実行するタイマーを作成する（問題の時間制限に到達した場合の実行）、　リセットいるな
        self.doneTimer = Timer.scheduledTimer(timeInterval: QuizStruct.timerDuration, target: self, selector: #selector(QuizController.timerDone), userInfo: nil, repeats: true)
    }
    
    //毎秒ごとのタイマーで呼び出されるメソッド
    func perSecTimerDone() {
        self.pastCounter -= 1
        self.timerDisplayLabel.text = "あと" + String(self.pastCounter) + "秒"
    }
    
    //問題の時間制限に到達した場合に実行されるメソッド
    func timerDone() {
        
        //10秒経過時は不正解として次の問題を読み込む
        
        self.totalSeconds = self.totalSeconds + QuizStruct.limitTimer
        //経過時間リセット
        self.pastCounter = QuizStruct.defaultCounter
        
        switch self.counter {
        case 0:
            self.timeProblemSolvedOne = Date()
        case 1:
            self.timeProblemSolvedTwo = Date()
        case 2:
            self.timeProblemSolvedThree = Date()
        case 3:
            self.timeProblemSolvedFour = Date()
        case 4:
            self.timeProblemSolvedFive = Date()
        default:
            self.tmpTimerCount = 0.000
        }
        
        //カウンターの値に+1をする
        self.counter += 1
        
        //タイマーを再設定する
        self.reloadTimer()
    }
    
    //CSVデータから問題を取得するメソッド
    func setProblemsFromCSV() {
        
        //問題を(CSV形式で準備)読み込む
        let csvBundle = Bundle.main.path(forResource: "problem", ofType: "csv")
        
        //CSVデータの解析処理
        do {
            //CSVデータを読み込む
            var csvData: String = try String(contentsOfFile: csvBundle!, encoding: String.Encoding.utf8)
            csvData = csvData.replacingOccurrences(of: "\r", with: "")
            
            //改行を基準にしてデータを分割する読み込む
            let csvArray = csvData.components(separatedBy: "\n")
            
            //CSVデータの行数分ループさせる
            for line in csvArray {
                
                //カンマ区切りの1行を["aaa", "bbb", ... , "zzz"]形式に変換して代入する
                let parts = line.components(separatedBy: ",")
                self.problemArray.add(parts)
            }

            //何故か最後に""が入るので削除してエラー回避
            problemArray.removeLastObject()
            
            //配列を引数分の要素をランダムにシャッフルする(※Extension.swift参照)
            self.problemArray.shuffle(self.problemArray.count)
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func reloadTimer () {
        //タイマーを破棄する
        self.resetTimer()
        
        //結果表示ページへ遷移するか次の問題を表示する
        self.compareNextProblemOrResultView()
    }
    
    //次の問題の表示を行うメソッド
    func createNextProblem() {
        
        //取得した問題を取得する
        let targetProblem: NSArray = self.problemArray[self.counter] as! NSArray
        
        //ラベルに表示されている値を変更する
        //配列 → 0番目：問題文, 1番目：正解の番号, 2番目：1番目の選択肢, 3番目：2番目の選択肢, 4番目：3番目の選択肢, 5番目：4番目の選択肢
        self.problemCountLabel.text = "第" + String(self.counter + 1) + "問"
        self.problemTextLabel.text = targetProblem[0] as? String
        
        //正解の単語を入れる場所の確定,0~3
        self.answerSelection = Int(arc4random_uniform(4))
    
        //選択肢の正解である場所に答えを入れる
        self.options[answerSelection] = targetProblem[1] as! String
        
        //その他の選択肢の作成
        for _ in 1...3 {
            //0~14
            let e = problemArray.count - 5
            let a =  arc4random_uniform(UInt32(e)) + 5
            
            for i in 0...3 {
                if self.options[i] == "a" {
                    var array:Array<String> = problemArray[Int(a)] as! Array
                    self.options[i] = array[1]
                    break
                }
            }

        }
               
        //ボタンに選択肢を表示する
        self.answerButtonOne.setTitle("1.　" + String(describing: options[0]), for: UIControlState())
        self.answerButtonTwo.setTitle("2.　" + String(describing: options[1]), for: UIControlState())
        self.answerButtonThree.setTitle("3.　" + String(describing: options[2]), for: UIControlState())
        self.answerButtonFour.setTitle("4.　" + String(describing: options[3]), for: UIControlState())
    }
    
    //選択された答えが正しいか誤りかを判定するメソッド
    func judgeCurrentAnswer(_ answer: Int) {
        
        //ボタンを全て非活性にする
        self.allAnswerBtnDisabled()
        
        //カウントを元に戻す
        self.pastCounter = QuizStruct.defaultCounter
        
        //[問題の回答時間] = [n問目の回答した際の時間] - [(n-1)問目の回答した際の時間]として算出する
        switch self.counter {
        case 0:
            self.timeProblemSolvedOne = Date()
            self.tmpTimerCount = self.timeProblemSolvedOne.timeIntervalSince(self.timeProblemSolvedZero)
        case 1:
            self.timeProblemSolvedTwo = Date()
            self.tmpTimerCount = self.timeProblemSolvedTwo.timeIntervalSince(self.timeProblemSolvedOne)
        case 2:
            self.timeProblemSolvedThree = Date()
            self.tmpTimerCount = self.timeProblemSolvedThree.timeIntervalSince(self.timeProblemSolvedTwo)
        case 3:
            self.timeProblemSolvedFour = Date()
            self.tmpTimerCount = self.timeProblemSolvedFour.timeIntervalSince(self.timeProblemSolvedThree)
        case 4:
            self.timeProblemSolvedFive = Date()
            self.tmpTimerCount = self.timeProblemSolvedFive.timeIntervalSince(self.timeProblemSolvedFour)
        default:
            self.tmpTimerCount = 0.000
        }
        
        //合計時間に問題の回答時間を加算する
        self.totalSeconds = self.totalSeconds + self.tmpTimerCount
        
        //該当の問題の回答番号を取得する
        let targetProblem: NSArray = self.problemArray[self.counter] as! NSArray

        //let targetAnswer: Int = Int(targetProblem[1] as! String)!
        
        //もし回答の数字とメソッドの引数が同じならば正解数の値に+1する
        if answer == answerSelection + 1 {
            self.showImg(bool: true)
            self.correctProblemNumber += 1
        } else {
            self.showImg(bool: false)
            incorrectProblem.updateValue(targetProblem[1] as! String, forKey: targetProblem[0] as! String)
        }
        
        //カウンターの値に+1をする
        self.counter += 1
        
        //選択肢の初期化
        self.options[0] = "a"
        self.options[1] = "a"
        self.options[2] = "a"
        self.options[3] = "a"
        
        //答えの場所の初期化
        self.answerSelection = -1

        //タイマーを再設定する、reloadTimer内の処理にメソッド:次の遷移先の準備、を含む
        self.reloadTimer()
    }
    
    //結果表示ページへ遷移するか次の問題を表示するかを決めるメソッド
    func compareNextProblemOrResultView() {
        
        if self.counter == QuizStruct.dataMaxCount {
            
            //（処理）規定回数まで到達した場合は次の画面へ遷移する
            //タイマーを破棄する
            self.resetTimer()
            
            //Realmに計算結果データを保存する
            let gameScoreObject = GameScore.create()
            gameScoreObject.correctAmount = self.correctProblemNumber
            gameScoreObject.timeCount = NSString(format:"%.3f", self.totalSeconds) as String
            gameScoreObject.createDate = Date() as NSDate
            gameScoreObject.save()
            
            //次のコントローラーへ遷移する
            self.performSegue(withIdentifier: "goScore", sender: nil)
            
        } else {
            
            //（処理）規定回数に達していない場合はカウントをリセットして次の問題を表示する
            //ボタンを全て活性にする
            self.allAnswerBtnEnabled()
            
            //次の問題をセットする
            self.createNextProblem()
            
            //ラベルの値を再セットする
            self.timerDisplayLabel.text = "あと" + String(self.pastCounter) + "秒"
            
            //タイマーをセットする
            self.setTimer()
        }
    }
    
    //セグエを呼び出したときに呼ばれるメソッド
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //セグエ名で判定を行う
        if segue.identifier == "goScore" {
            
            //遷移先のコントローラーの変数を用意する
            let scoreController = segue.destination as! ScoreController
            
            //遷移先のコントローラーに渡したい変数を格納（型を合わせてね）
            scoreController.correctProblemNumber = self.correctProblemNumber
            scoreController.totalSeconds = NSString(format:"%.3f", self.totalSeconds) as String
            scoreController.incorrectProblem = incorrectProblem
            
            //計算結果を入れる変数を初期化
            self.resetGameValues()
        }
    }
    
    func showImg (bool: Bool){
        if bool {
            self.imgView.isHidden = false
            self.imgView.image = UIImage(named: "circle")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.imgView.isHidden = true
            }
            
        } else {
            self.imgView.isHidden = false
            self.imgView.image = UIImage(named: "cross")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.imgView.isHidden = true
            }
        }
    }

    //ゲームのカウントに関する数を初期化する
    func resetGameValues() {
        self.counter = 0
        self.correctProblemNumber = 0
        self.totalSeconds = 0.000
    }
    
    
    //タイマー処理を全てリセットするメソッド
    func resetTimer() {
        self.perSecTimer!.invalidate()
        self.doneTimer!.invalidate()
    }
    
    //全ボタンを非活性にする
    func allAnswerBtnDisabled() {
        self.answerButtonOne.isEnabled = false
        self.answerButtonTwo.isEnabled = false
        self.answerButtonThree.isEnabled = false
        self.answerButtonFour.isEnabled = false
    }
    
    //全ボタンを活性にする
    func allAnswerBtnEnabled() {
        self.answerButtonOne.isEnabled = true
        self.answerButtonTwo.isEnabled = true
        self.answerButtonThree.isEnabled = true
        self.answerButtonFour.isEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
