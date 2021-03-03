import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class CommentsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var news: News?
    var clinical_case: Case?
    var discussion: Discussion?
    var research: Research?
    var path: String?
    var comments = [Comment]()
    var commentPath: String!
    @IBOutlet weak var comments_timeline: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        comments_timeline.delegate = self
        comments_timeline.dataSource = self
        comments_timeline.separatorColor = UIColor.white
        comments_timeline.separatorStyle = .none
        comments_timeline.rowHeight = UITableView.automaticDimension
        comments_timeline.tableFooterView = UIView()
        if news != nil {
            getComments(path: "Comments/News/\(news!.user.id)/\(news!.id)")
        } else if clinical_case != nil {
            getComments(path: "Comments/Cases/\(clinical_case!.user.id)/\(clinical_case!.id)")
        } else if discussion != nil {
            getComments(path: "Comments/Discussions/\(discussion!.user.id)/\(discussion!.id)")
        } else if research != nil {
            getComments(path: "Comments/Researches/\(research!.user.id)/\(research!.id)")
        } else {
            getComments(path: path!)
        }
    }
    
    func loopComments(path: String, ref: DatabaseReference, snapshot: DataSnapshot) {
        self.startAnimation()
        for child in snapshot.children.allObjects as! [DataSnapshot] {
            let dict = child.value as? [String : AnyObject] ?? [:]
            for childDict in dict {
                let data = childDict.value as? [String : AnyObject] ?? [:]
                let message = data["message"]! as! String
                let date = data["date"]! as! String
                let userid = data["user"]! as! String
                ref.child("Users/\(userid)").observeSingleEvent(of: .value, with: { snapshot
                    in
                    let dict = snapshot.value as? [String : AnyObject] ?? [:]
                    let username = dict["username"]! as! String
                    let fullname = dict["fullname"]! as! String
                    self.comments.append(Comment(id: childDict.key, date: date, message: message, user: User(id: userid, fullname: fullname, username: username)))
                    let sortedComments = self.comments.sorted {
                        $0.date > $1.date
                    }
                    self.comments = sortedComments
                    self.comments_timeline.reloadData()
                    self.stopAnimation()
                })
            }
        }
    }
    
    func getComments(path: String) {
        self.commentPath = path
        let ref = Database.database().reference()
        ref.child(path).observeSingleEvent(of: .value, with: { snapshot in
            if (snapshot.children.allObjects.count == 0) {
                self.comments_timeline.setEmptyView(title: "No comment has been posted yet")
            } else {
                self.comments_timeline.restore()
                self.loopComments(path: path, ref: ref, snapshot: snapshot)
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = comments_timeline.dequeueReusableCell(withIdentifier: "cell")
        var message = comments[indexPath.row].message+"\n"
        if indexPath.row > 0 {
            message = "\n\n\(message)"
        }
        cell!.textLabel?.text = message
        cell!.textLabel?.font = UIFont.systemFont(ofSize: 15)
        cell!.textLabel?.textAlignment = .justified
        let date = getFormattedDate(date: comments[indexPath.row].date)
        var subtitle = comments[indexPath.row].user.username + " at " + date
        if comments[indexPath.row].user.id == Auth.auth().currentUser!.uid {
            subtitle = "Me at " + date
        }
        cell!.detailTextLabel?.text = subtitle
        cell!.detailTextLabel?.textColor = UIColor.init(hexString: "#641E16")
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        comments_timeline.deselectRow(at: indexPath, animated: true)
        let cell = self.comments_timeline.cellForRow(at: indexPath)
        cell!.setBorder(color: UIColor.white)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if (comments[indexPath.row].user.id == Auth.auth().currentUser!.uid) {
            let editAction = UITableViewRowAction(style: .default, title: "Edit", handler: { (action, indexPath) in
                let comments_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EditCommentVC") as? EditCommentVC
                comments_vc!.news = self.news
                comments_vc!.clinical_case = self.clinical_case
                comments_vc!.discussion = self.discussion
                comments_vc!.research = self.research
                comments_vc!.commentPath = self.commentPath
                comments_vc!.comment = self.comments[indexPath.row]
                self.navigationController?.pushViewController(comments_vc!, animated: false)
            })
            editAction.backgroundColor = UIColor.init(hexString: "#2874A6")
            let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: { (action, indexPath) in
                let comment = self.comments[indexPath.row]
                let cell = self.comments_timeline.cellForRow(at: indexPath)
                cell!.setBorder(color: UIColor.init(hexString: "#2874A6"))
                self.askDelete(comment: comment, pos: indexPath.row, indexPath: indexPath)
            })
            deleteAction.backgroundColor = UIColor.init(hexString: "#2874A6")
            return [deleteAction, editAction]
        }
        return [];
    }
    
    func askDelete(comment: Comment, pos: Int, indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Are you sure you want delete this?"
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            let now = comment.date
            let path = "\(self.commentPath!)/\(uid!)/\(now)"
            self.removeDataDB(path: path)
            self.comments.remove(at: pos)
            self.comments_timeline.reloadData()
            if self.comments.count == 0 {
                self.comments_timeline.setEmptyView(title: "No comment has been posted yet")
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: {
            action in
            let cell = self.comments_timeline.cellForRow(at: indexPath)
            cell!.setBorder(color: UIColor.white)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addComment(_ sender: Any) {
        let comments_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CreateCommentVC") as? CreateCommentVC
        comments_vc!.commentPath = commentPath
        comments_vc!.news = news
        comments_vc!.clinical_case = clinical_case
        comments_vc!.discussion = discussion
        comments_vc!.research = research
        navigationController?.pushViewController(comments_vc!, animated: false)
    }
    
    
    @IBAction func backSegue(_ sender: Any) {
        if news != nil {
            let segue_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ShowNewsVC") as? ShowNewsVC
            segue_vc!.news = news
            navigationController?.pushViewController(segue_vc!, animated: false)
        } else if clinical_case != nil {
            let segue_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ShowCaseVC") as? ShowCaseVC
            segue_vc!.clinical_case = clinical_case
            navigationController?.pushViewController(segue_vc!, animated: false)
        } else if discussion != nil {
            let segue_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ShowDiscussionVC") as? ShowDiscussionVC
            segue_vc!.discussion = discussion
            navigationController?.pushViewController(segue_vc!, animated: false)
        } else if research != nil {
            let segue_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ShowResearchVC") as? ShowResearchVC
            segue_vc!.research = research
            navigationController?.pushViewController(segue_vc!, animated: false)
        }
    }
}
