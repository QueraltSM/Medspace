import UIKit
import FirebaseDatabase
import FirebaseAuth

class ProfileVC: UIViewController  {

    var user: User?
    @IBOutlet weak var discussions_box: UIView!
    @IBOutlet weak var researches_box: UIView!
    @IBOutlet weak var discussions: UIButton!
    @IBOutlet weak var researches: UIButton!
    @IBOutlet weak var full_name: UILabel!
    @IBOutlet weak var news_cases: UIButton!
    @IBOutlet weak var news_cases_box: UIView!
    var id = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setHeader(largeTitles: true, gray: true)
        var viewtitle = username
        id = uid
        var user_fullname = fullname
        if user != nil {
            viewtitle = user!.username
            id = user!.id
            user_fullname = user!.fullname
        }
        full_name.text = user_fullname
        self.title = viewtitle
        news_cases_box.setBorder()
        if usertype == "Doctor" {
            getPosts(path: "Cases")
            getPosts(path: "Discussions")
            getPosts(path: "Researches")
            configBoxes(enabled: true)
        } else {
            getPosts(path: "News")
            configBoxes(enabled: false)
        }
        news_cases_box.backgroundColor =  UIColor.init(hexString: "cfdbe6")
    }
    
    func configBoxes(enabled: Bool) {
        if enabled {
            discussions_box.setBorder()
            researches_box.setBorder()
            discussions_box.backgroundColor =  UIColor.init(hexString: "cfdbe6")
            researches_box.backgroundColor =  UIColor.init(hexString: "cfdbe6")
        }
        discussions.isEnabled = enabled
        researches.isEnabled = enabled
    }
    
    func getPosts(path: String) {
        Database.database().reference().child(path).observeSingleEvent(of: .value, with: { snapshot in
            var count = 0
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                self.startAnimation()
                let dict = child.value as? [String : AnyObject] ?? [:]
                let userid = dict["user"]! as! String
                if (userid == self.id) {
                    count += 1
                }
                self.stopAnimation()
            }
            var button_text = ""
            if count == 0 {
                button_text += "No \(path.lowercased())"
            } else {
                button_text += "\(path) (\(count))"
            }
            switch(path) {
            case "Discussions":
                self.discussions.setTitle(button_text, for: .normal)
            case "Researches":
                self.researches.setTitle(button_text, for: .normal)
            default:
                self.news_cases.setTitle(button_text, for: .normal)
            }
        })
    }
    
    
    @IBAction func showUserNewsCases(_ sender: Any) {
        var segue = ""
        if id == uid && usertype == "Admin" {
            segue = "MyNewsVC"
        } else if id == uid && usertype == "Doctor" {
            segue = "MyCasesVC"
        } else if id != uid && usertype == "Admin" {
            segue = "NewsVC"
        }
        if segue != "" {
            self.presentVC(segue: segue)
        } else {
            let cases_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CasesVC") as? CasesVC
            cases_vc!.user = user
            navigationController?.pushViewController(cases_vc!, animated: false)
        }
    }
    
    @IBAction func showUserDiscussions(_ sender: Any) {
        if id == uid {
            self.presentVC(segue: "MyDiscussionsVC")
        } else {
            let discussions_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DiscussionsVC") as? DiscussionsVC
            discussions_vc!.user = user
            navigationController?.pushViewController(discussions_vc!, animated: false)
        }
    }
    
    @IBAction func showUserResearches(_ sender: Any) {
        if id == uid {
            self.presentVC(segue: "MyResearchesVC")
        } else {
            let researches_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ResearchesVC") as? ResearchesVC
            researches_vc!.user = user
            navigationController?.pushViewController(researches_vc!, animated: false)
        }
    }
    
    @IBAction func didTapMenu(_ sender: Any) {
        swipeMenu()
    }
}
