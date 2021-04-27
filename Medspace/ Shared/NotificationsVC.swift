import UIKit
import FirebaseAuth
import Firebase

class NotificationsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var notificationsState: UISwitch!
    @IBOutlet weak var allKeywords: UITableView!
    var ref: DatabaseReference!
    var actualState: Bool!
    var keywords = [Keyword]()
    @IBOutlet weak var addKeywordBttn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        actualState = UserDefaults.standard.bool(forKey: "notificationsState")
        initComponents()
        customNavBar()
        getKeywords()
    }
    
    func loopKeywords(ref: DatabaseReference, snapshot: DataSnapshot) {
        self.startAnimation()
        for child in snapshot.children.allObjects as! [DataSnapshot] {
            keywords.append(Keyword(id: child.key, keyword: child.value as! String))
            allKeywords.reloadData()
        }
        self.stopAnimation()
    }
    
    func getKeywords() {
        let ref = Database.database().reference()
        ref.child("Keywords/\(uid!)").observeSingleEvent(of: .value, with: { snapshot in
            if (snapshot.children.allObjects.count == 0) {
                self.allKeywords.setEmptyView(title: "You have not added any keyword yet")
            } else {
                self.allKeywords.restore()
                self.loopKeywords(ref: ref, snapshot: snapshot)
            }
        })
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keywords.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: "cell") as? CollapsibleTableViewCell) ?? CollapsibleTableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel!.textColor = .black
        cell.textLabel!.textAlignment = .center
        cell.textLabel!.text = keywords[indexPath.row].keyword
        cell.contentView.backgroundColor = UIColor.white
        return cell
    }
    
    
    func initComponents(){
        self.notificationsState.setOn(actualState, animated: false)
        notificationsState.addTarget(self, action: #selector(self.changeState), for: .valueChanged)
        self.allKeywords.delegate = self
        self.allKeywords.dataSource = self
        let footerView = UIView()
        footerView.backgroundColor = UIColor.white
        self.allKeywords.tableFooterView = footerView
        self.notificationsState.backgroundColor = UIColor.white
    }
    
    func askDelete(keyword: Keyword, pos: Int, indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Are you sure you want delete keyword '\(keyword.keyword)'?"
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            let path = "Keywords/\(uid!)/\(keyword.id)"
            self.removeDataDB(path: path)
            self.presentVC(segue: "NotificationsVC")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: {
            action in
            let cell = self.allKeywords.cellForRow(at: indexPath)
            cell!.setBorder(color: UIColor.white)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
            let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: { (action, indexPath) in
            let keyword = self.keywords[indexPath.row]
            let cell = self.allKeywords.cellForRow(at: indexPath)
            cell!.setBorder(color: UIColor.init(hexString: "#2874A6"))
            self.askDelete(keyword: keyword, pos: indexPath.row, indexPath: indexPath)
        })
        deleteAction.backgroundColor = UIColor.init(hexString: "#2874A6")
        return [deleteAction]
    }
    
    @objc func changeState(){
        actualState = UserDefaults.standard.bool(forKey: "notificationsState")
        UserDefaults.standard.setValue(!actualState, forKey: "notificationsState")
        self.notificationsState.setOn(!actualState, animated: false)
    }
    
    func saveKeyword(keyword: String) {
        if keywords.contains(where: {$0.keyword.compare(keyword, options: .caseInsensitive) == .orderedSame}){
            self.showAlert(title: "Error", message: "Keyword already exists")
        } else {
            let now = Date().description
            keywords.append(Keyword(id: now, keyword: keyword))
            let path = "Keywords/\(uid!)"
            let ref = Database.database().reference()
            ref.child("\(path)/\(now)").setValue(keyword)
            allKeywords.reloadData()
        }
    }
    
    @IBAction func addKeyword(_ sender: Any) {
        let alert = UIAlertController(title: "Add keyword", message: "Enter a new one", preferredStyle: .alert)
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "For example: bones"
        }
        let save = UIAlertAction(title: "Done", style: .default, handler: { alertAction -> Void in
            if let textField = alert.textFields?[0] {
                if textField.text!.count > 0 {
                    self.allKeywords.restore()
                    self.saveKeyword(keyword: textField.text!)
                } else {
                    self.showAlert(title: "Error", message: "Keyword can not be empty")
                }
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: {
            (action : UIAlertAction!) -> Void in })
        alert.addAction(cancel)
        alert.addAction(save)
        alert.preferredAction = save
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.presentVC(segue: "SettingsVC")
    }
}
