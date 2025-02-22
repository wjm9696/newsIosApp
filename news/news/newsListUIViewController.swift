//
//  newsListUIViewController.swift
//  news
//
//  Created by Jimmy on 4/5/17.
//  Copyright © 2017 teddy-jimmy. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import FirebaseAuth


class newsListUIViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    var catalogName:String?
    var feedArray:[News] = [News]()
    

    @IBOutlet weak var newsTableView: UITableView!
    var refreshControl = UIRefreshControl()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newsTableView.delegate = self
        let notificationKey = "finishedSorting"
        newsTableView.dataSource = self
        if let newsData = newsData[catalogName!]{
            feedArray = newsData

        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(newsListUIViewController.reloadView), name: NSNotification.Name(rawValue: notificationKey), object: nil)
        
        
        newsTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(self.refreshData), for: .valueChanged)
        
        // Do any additional setup after loading the view.
    }
    
    func refreshData(){
        
        
        fetchNews(completion:{_ in
            print("reloading")
            self.newsTableView.reloadData()
            self.refreshControl.endRefreshing()

        }, callback: true)
        
        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell") as! newsTableViewCell
        cell.newsImage.image = nil
        cell.newsTitle.text = feedArray[indexPath.row].title
        Alamofire.request(feedArray[indexPath.row].urlToImage!).responseData(completionHandler: { response in
            if let data = response.result.value {
                cell.newsImage.image = UIImage(data: data)
            }else{
                cell.newsImage.image = nil            }
        })
        return cell

    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            updateNewsLocal(newsTitle: feedArray[indexPath.row].title!, category:catalogName!, upvote: false)

            feedArray.remove(at: 2)
            newsTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    @objc func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Dislike" //or customize for each indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let title = feedArray[indexPath.row].title
        if FIRAuth.auth()?.currentUser != nil {
            let id = FIRAuth.auth()?.currentUser?.uid
            downloadUserData(userId: id!)
            uploadReadNews(news: feedArray[indexPath.row], userId: id!)
            downloadReadNews(userId: id!)
            
        }
        sortModel().startSortNews()
        performSegue(withIdentifier: "newsListToNewsWeb", sender: self.feedArray[indexPath.row])
        
        updateNewsLocal(newsTitle: title!, category:self.catalogName!, upvote: true)
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    

    
    func reloadView() {
        feedArray = newsData[catalogName!]!
        self.newsTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? newsWebUIVIewController {
            if let sender = sender{
                let news = sender as! News
                destinationVC.url = news.url!
            }
        }
    }
    
    
    
    

}
