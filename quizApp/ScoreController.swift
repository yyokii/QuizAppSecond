//
//  ScoreController.swift
//  quizApp
//
//  Created by 東原与生 on 2017/04/24.
//  Copyright © 2017年 yoki. All rights reserved.
//

import UIKit
import RealmSwift
import Charts

//グラフに描画する要素数に関するenum
enum GraphXLabelList : Int {
    
    case one = 1
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    
    static func getXLabelList(_ count: Int) -> [String] {
        
        var xLabels: [String] = []
        
        //※この画面に遷移したらデータが登録されるので0は考えなくて良い
        if count == self.one.rawValue {
            xLabels = ["最新"]
        } else if count == self.two.rawValue {
            xLabels = ["最新", "2つ前"]
        } else if count == self.three.rawValue {
            xLabels = ["最新", "2つ前", "3つ前"]
        } else if count == self.four.rawValue {
            xLabels = ["最新", "2つ前", "3つ前", "4つ前"]
        } else {
            xLabels = ["最新", "2つ前", "3つ前", "4つ前", "5つ前"]
        }
        return xLabels
    }
    
}

//テーブルビューに関係する定数
struct ScoreTableStruct {
    static let cellSectionCount: Int = 1
    static let cellHeight: CGFloat = 100
}

class ScoreController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {
    
    //QuizControllerより引き渡される値を格納する
    var correctProblemNumber: Int!
    var totalSeconds: String!
    
    //テーブルデータ表示用に一時的にすべてのfetchデータを格納する
    //var scoreArrayForCell: NSMutableArray = []
    
    //折れ線グラフ用のメンバ変数
    var lineChartView: LineChartView = LineChartView()
    
    //不正解問題の情報
    var incorrectProblem = Dictionary<String,String>()

    @IBOutlet var resultDisplayLabel: UILabel!
    @IBOutlet var analyticsSegmentControl: UISegmentedControl!
    @IBOutlet var resultHistoryTable: UITableView!
    @IBOutlet var resultGraphView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        //QuizControllerから渡された値を出力
        self.resultDisplayLabel.text = "正解数：合計" + String(self.correctProblemNumber) + "問 / 経過時間：" + self.totalSeconds + "秒"
        
        //Realmから履歴データを呼び出す
        //self.fetchHistoryDataFromRealm()
        
        //セグメントコントロールの初期値を設定する
        self.analyticsSegmentControl.selectedSegmentIndex = 0
        self.resultHistoryTable.alpha = 1
        self.resultGraphView.alpha = 0 //??????????
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //テーブルビューのデリゲート設定
        self.resultHistoryTable.delegate = self
        self.resultHistoryTable.dataSource = self
        
        //Xibのクラスを読み込む
        let nibDefault: UINib = UINib(nibName: "answerCell", bundle: nil)
        self.resultHistoryTable.register(nibDefault, forCellReuseIdentifier: "answerCell")
        
        //データを成型して表示する（変数xLabelsとunitSoldに入る配列の要素数は合わせないと落ちる）
        let unitsSold: [Double] = GameScore.fetchGraphGameScore()
        let xLabels = GraphXLabelList.getXLabelList(unitsSold.count)
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<xLabels.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: unitsSold[i])
            dataEntries.insert(dataEntry, at: 0)
            //dataEntries.append(dataEntry)
        }
        
        
        //グラフに描画するデータを表示する
        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "ここ最近の得点グラフ")
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        
        //LineChartViewのインスタンスに値を追加する
        self.lineChartView.data = lineChartData
        
        //UIViewの中にLineChartViewを追加する
        self.resultGraphView.addSubview(self.lineChartView)
        
    }
    
    //レイアウト処理が完了した際の処理
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //レイアウトの再配置
        self.lineChartView.frame = CGRect(x: 0, y: 0, width: self.resultGraphView.frame.width, height: self.resultGraphView.frame.height)
    }
    
    
    //TableViewに関する設定一覧（セクション数）
    func numberOfSections(in tableView: UITableView) -> Int {
        return ScoreTableStruct.cellSectionCount
    }
    
    //TableViewに関する設定一覧（セクションのセル数）
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.incorrectProblem.count
        
    }
    
    //TableViewに関する設定一覧（セルに関する設定）
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Xibファイルを元にデータを作成する
        let cell = tableView.dequeueReusableCell(withIdentifier: "answerCell") as? answerCell

        let problem = Array(incorrectProblem.keys)
        let answer = Array(incorrectProblem.values)
        
        cell?.problemLabel.text = problem[indexPath.row]
        cell?.answerLabel.text = answer[indexPath.row]
        
        //セルのアクセサリタイプと背景の設定
        cell!.accessoryType = UITableViewCellAccessoryType.none
        cell!.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell!
    }
    
    //TableView: セルの高さを返す
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ScoreTableStruct.cellHeight
    }
    
    //TableView: テーブルビューをリロードする
    func reloadData(){
        self.resultHistoryTable.reloadData()
    }
    
    //セグメントコントロールで表示するものを切り替える
    @IBAction func changeDataDisplayAction(_ sender: AnyObject) {
        
        switch sender.selectedSegmentIndex {
            
        case 0:
            self.resultHistoryTable.alpha = 1
            self.resultGraphView.alpha = 0
            break
            
        case 1:
            self.resultHistoryTable.alpha = 0
            self.resultGraphView.alpha = 1
            break
            
        default:
            self.resultHistoryTable.alpha = 1
            self.resultGraphView.alpha = 0
            break
        }
    }
    
    @IBAction func backToHome (){
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        self.incorrectProblem.removeAll()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
