import UIKit
import FirebaseDatabase

class ProfileVC: UIViewController  {

    var user: User?
    @IBOutlet weak var cases_box: UIView!
    @IBOutlet weak var discussions_box: UIView!
    @IBOutlet weak var researches_box: UIView!
    @IBOutlet weak var cases: UIButton!
    @IBOutlet weak var discussions: UIButton!
    @IBOutlet weak var researches: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setHeader(largeTitles: true, gray: true)
        self.title = user!.username
        cases_box.setBorder()
        discussions_box.setBorder()
        researches_box.setBorder()
        getPosts(path: "Cases")
        getPosts(path: "Discussions")
        getPosts(path: "Researches")
        cases_box.backgroundColor =  UIColor.init(hexString: "cfdbe6")
        discussions_box.backgroundColor =  UIColor.init(hexString: "cfdbe6")
        researches_box.backgroundColor =  UIColor.init(hexString: "cfdbe6")
    }
    
    func getPosts(path: String) {
        self.startAnimation()
        Database.database().reference().child(path).observeSingleEvent(of: .value, with: { snapshot in
            var count = 0
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let dict = child.value as? [String : AnyObject] ?? [:]
                let userid = dict["user"]! as! String
                if (userid == self.user!.id) {
                    count += 1
                }
            }
            self.stopAnimation()
            switch(path) {
            case "Cases":
                self.cases.setTitle("Clinical cases · \(count)", for: .normal)
            case "Discussions":
                self.discussions.setTitle("Discussions · \(count)", for: .normal)
            default:
                self.researches.setTitle("Researches · \(count)", for: .normal)
            }
        })
    }
    
    @IBAction func showUserCases(_ sender: Any) {
    }
    
    @IBAction func showUserDiscussions(_ sender: Any) {
    }
    
    @IBAction func showUserResearches(_ sender: Any) {
        let researches_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ResearchesVC") as? ResearchesVC
        researches_vc!.user = user
        navigationController?.pushViewController(researches_vc!, animated: false)
    }
    
    
}
