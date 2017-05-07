//
//  GameScore.swift
//  quizApp
//
//  Created by 東原与生 on 2017/04/24.
//  Copyright © 2017年 yoki. All rights reserved.
//

import RealmSwift

class GameScore: Object {
    
    //Realmクラスのインスタンス
    static let realm = try! Realm()
    
    //id
    dynamic fileprivate var id = 0

    //正解数（Int型）
    dynamic var correctAmount = 0
    
    //正解までにかかった時間（String型）
    dynamic var timeCount = ""
    
    //登録日（NSDate型）
    dynamic var createDate = NSDate(timeIntervalSince1970: 0) //1970-01-01 00:00:00 +0000
    
    //PrimaryKeyの設定
    override static func primaryKey() -> String? {
        return "id"
    }
    
    //新規追加用のインスタンス生成メソッド //id(プライマリーキー)作成＆インスタンス生成
    static func create() -> GameScore {
        let gameScore = GameScore()
        gameScore.id = self.getLastId()
        return gameScore
    }
    
    //プライマリキーの作成メソッド
    static func getLastId() -> Int {
        if let gameScore = realm.objects(GameScore.self).last {
            return gameScore.id + 1
        } else {
            return 1
        }
    }
    
    //インスタンス保存用メソッド
    func save() {
        try! GameScore.realm.write {
            GameScore.realm.add(self)
        }
    }
    
    //登録日順のデータの全件取得をする
    static func fetchAllGameScore() -> [GameScore] {
        let gameScores: Results<GameScore> = realm.objects(GameScore.self).sorted(byKeyPath: "createDate", ascending: false)
        var gameScoreList: [GameScore] = []
        for gameScore in gameScores {
            gameScoreList.append(gameScore)
        }
        return gameScoreList
    }
    
    //登録日順のデータを最新から5件取得をする
    static func fetchGraphGameScore() -> [Double] {
        let gameScores: Results<GameScore> = realm.objects(GameScore.self).sorted(byKeyPath: "createDate", ascending: false)
        var gameScoreList: [Double] = []
        for (index, element) in gameScores.enumerated() {
            if index < 5 {
                let target: Double = Double(element.correctAmount)
                gameScoreList.append(target)
            }
        }
        return gameScoreList
    }
    
    //経験値とレベルについて
    static func fetchExp() -> (CGFloat, Int) {
        var totalCorrect: Int = 0
        let gameScores: Results<GameScore> = realm.objects(GameScore.self)
        for gameScore in gameScores {
            totalCorrect += gameScore.correctAmount
        }
        let exp = totalCorrect % 5 * 20
        let  level = floor(Double(totalCorrect/5))
        
        return (CGFloat(exp),Int(level))
    }
    
    //正解率
    static func ratio () -> Double {
        var totalCorrect: Int = 0
        let gameScores: Results<GameScore> = realm.objects(GameScore.self)
        for gameScore in gameScores {
            totalCorrect += gameScore.correctAmount
        }
        var ratio:Double =  Double(totalCorrect)/Double(gameScores.count * 5) * 1000
        ratio = round(ratio)/10
        
        return ratio
    }
    
}
