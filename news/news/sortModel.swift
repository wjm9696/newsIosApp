//
//  sortModel.swift
//  news
//
//  Created by ZhangJianglai on 4/25/17.
//  Copyright © 2017 teddy-jimmy. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseAuth
import Alamofire

class sortModel {

    init() {
        let downloadNotificationKey = "finishedDownload"
        NotificationCenter.default.addObserver(self, selector: #selector(self.startSortNews), name: NSNotification.Name(rawValue: downloadNotificationKey), object: nil)
    }
    
    @objc func startSortNews() {
        print("start sorting")
        var userWordCount = currentUserWordCount
        var userCategoryCount = currentUserCategoryCount
        var news = newsData
        
        // Till this point all data (news and users') should have been loaded if there is any.
        var newsScore = [(News, Int)]()
        for (type, newsList) in news {
            for eachNews in newsList {
                var categoryScore = 0
                var wordScore = 0
                if userCategoryCount.keys.contains(type) {
                    categoryScore = userCategoryCount[type]!
                }
                let arr = eachNews.title?.characters.split{$0 == " "}.map(String.init)
                for word in arr! {
                    if userWordCount.keys.contains(word) {
                        wordScore = userWordCount[word]! + wordScore
                    }
                }
                var itsScore = 10 * categoryScore + wordScore // Weighing.
                newsScore.append((eachNews, itsScore))
            }
        }
        newsScore.sort(by: {$0.1>$1.1})
        sortedScore = newsScore
        
        print("finish sorting")
    }
}

