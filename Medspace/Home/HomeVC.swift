//
//  Home2VC.swift
//  Medspace
//
//  Created by Queralt Sosa Mompel on 27/8/20.
//  Copyright © 2020 Queralt Sosa Mompel. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class HomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var news_timeline: UITableView!
    
    var news = [News]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usertype = UserDefaults.standard.string(forKey: "usertype")
        username = UserDefaults.standard.string(forKey: "fullname")
        setMenu()
        news_timeline.delegate = self
        news_timeline.dataSource = self
        getNews()
        refreshControl.attributedTitle = NSAttributedString(string: "Loading...")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        news_timeline.addSubview(refreshControl)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        news = [News]()
        getNews()
        news_timeline.reloadData()
        refreshControl.endRefreshing()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 350
    }
    
    @IBAction func didTapMenu(_ sender: Any) {
        swipeMenu()
    }
    
    
    @IBAction func didTapSearch(_ sender: Any) {
        print("Search news")
    }
    
    func getNews() {
        Database.database().reference().child("News").observeSingleEvent(of: .value, with: { snapshot in
            if (snapshot.children.allObjects.count == 0) {
                self.news_timeline.setEmptyView(title: "There is no news publish yet\n\n:(")
            } else {
                self.news_timeline.restore()
            }
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                self.setActivityIndicator()
                let dict = child.value as? [String : AnyObject] ?? [:]
                let storageRef = Storage.storage().reference().child(child.key)
                storageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) -> Void in
                    let title = dict["title"]! as! String
                    let speciality = dict["speciality"]! as! String
                    let date = dict["date"]! as! String
                    let final_date = self.getFormattedDate(date: date)
                    let body = dict["body"]! as! String
                    let user = dict["user"]! as! String
                    let pic = UIImage(data: data!)
                    var color = UIColor.init()
                    for s in specialities {
                        if s.name == speciality {
                            color = s.color!
                        }
                    }
                    self.news.append(News(id: child.key, image: pic!, date: final_date, title: title, speciality: Speciality(name: speciality, color: color), body: body, userid: user))
                    let sortedUsers = self.news.sorted {
                        $0.date > $1.date
                    }
                    self.news = sortedUsers
                    self.news_timeline.reloadData()
                    self.stopAnimation()
                }
            }
        })
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected_news = news[indexPath.row]
        let show_news_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ShowNewsVC") as? ShowNewsVC
        show_news_vc!.news = selected_news
        navigationController?.pushViewController(show_news_vc!, animated: false)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? HomeCell
        cell?.news_date.text = news[indexPath.row].date
        cell?.news_title.text = news[indexPath.row].title
        cell?.image_header.image = news[indexPath.row].image
        cell?.news_speciality.text = news[indexPath.row].speciality.name
        cell?.news_speciality.backgroundColor = news[indexPath.row].speciality.color
        return cell!
    }
}
