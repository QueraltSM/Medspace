import Foundation
import UserNotifications
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
class PostsWorker {
    
    var timer: Timer?
    var appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    func start() {
        if UserDefaults.standard.integer(forKey: "newsCount") == 0 {
            UserDefaults.standard.setValue(0, forKey: "newsCount")
        }
        if UserDefaults.standard.integer(forKey: "casesCount") == 0 {
            UserDefaults.standard.setValue(0, forKey: "casesCount")
        }
        if UserDefaults.standard.integer(forKey: "discussionsCount") == 0 {
            UserDefaults.standard.setValue(0, forKey: "discussionsCount")
        }
        if UserDefaults.standard.integer(forKey: "researchesCount") == 0 {
            UserDefaults.standard.setValue(0, forKey: "researchesCount")
        }
        if timer == nil {
            timer = Timer.scheduledTimer(
                timeInterval: TimeInterval(60),
                target: self,
                selector: #selector(self.checkPosts),
                userInfo: nil,
                repeats: true)
        }
    }
    
    @objc func checkPosts() {
        self.getPosts(child: "News", key:"newsCount", type:"news")
        self.getPosts(child: "Cases", key:"casesCount", type:"case")
        self.getPosts(child: "Discussions", key:"discussionsCount", type:"discussion")
        self.getPosts(child: "Researches", key:"researchesCount", type:"research")
    }

    func getPosts(child: String, key: String, type:String) {
        let ref = Database.database().reference()
        ref.child(child).observeSingleEvent(of: .childAdded, with: { [self] snapshot in
            let lastCount = UserDefaults.standard.integer(forKey: key)
            if (snapshot.children.allObjects.count > lastCount) {
                for item in lastCount...snapshot.children.allObjects.count-1 {
                    let post = snapshot.children.allObjects[item] as! DataSnapshot
                    let data = post.value as? [String : AnyObject] ?? [:]
                    let title = data["title"]! as! String
                    let description = data["description"]! as! String
                    let user = data["user"]! as! String
                    if user != uid! {
                        self.checkKeywords(title: title, description: description)
                        UserDefaults.standard.setValue(snapshot.children.allObjects.count, forKey: key)
                    }
                }
            }
        })
    }
    
    func checkKeywords(title: String, description: String) {
        let ref = Database.database().reference()
        var notified = false
        ref.child("Keywords/\(uid!)").observeSingleEvent(of: .value, with: { snapshot in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let key = Keyword(id: child.key, keyword: child.value as! String)
                if (title.lowercased().contains(key.keyword.lowercased()) ||
                        description.lowercased().contains(key.keyword.lowercased())) && !notified {
                    self.appDelegate?.scheduleNotification(title: title)
                    notified = true
                }
            }
        })
    }
    
    func stop() {
        timer?.invalidate()
    }
}
