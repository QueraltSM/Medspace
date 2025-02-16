import Firebase
import FirebaseAuth
import UIKit

class SideMenuVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var menu_table: UITableView!
    
    let adminData = [
        CollapsableViewModel(label: "Home", image: UIImage(named: "Home.png"), segue:"NewsVC"),
        CollapsableViewModel(label: "Posts", image: UIImage(named: "Posts.png"), children: [
            CollapsableViewModel(label: "Clinical cases", image: UIImage(named: "Cases.png"), segue:"CasesVC"),
            CollapsableViewModel(label: "Discussions", image: UIImage(named: "Discussions.png"), segue:"DiscussionsVC"),
            CollapsableViewModel(label: "Researches", image: UIImage(named: "Researches.png"), segue:"ResearchesVC")]),
        CollapsableViewModel(label: "Add post", image: UIImage(named: "NewPost.png"), segue:"CreateNewsVC"),
        CollapsableViewModel(label: "My posts", image: UIImage(named: "MyPosts.png"), segue:"MyNewsVC"),
        CollapsableViewModel(label: "Settings", image: UIImage(named: "Settings.png"), segue:"SettingsVC"),
        CollapsableViewModel(label: "Log Out", image: UIImage(named: "Logout.png"))]
    
    let doctorData = [
        CollapsableViewModel(label: "Home", image: UIImage(named: "Home.png"), segue:"NewsVC"),
        CollapsableViewModel(label: "Posts", image: UIImage(named: "Posts.png"), children: [
            CollapsableViewModel(label: "Clinical cases", image: UIImage(named: "Cases.png"), segue:"CasesVC"),
            CollapsableViewModel(label: "Discussions", image: UIImage(named: "Discussions.png"), segue:"DiscussionsVC"),
            CollapsableViewModel(label: "Researches", image: UIImage(named: "Researches.png"), segue:"ResearchesVC")]),
        CollapsableViewModel(label: "Add post", image: UIImage(named: "NewPost.png"), children: [
            CollapsableViewModel(label: "Clinical case", image: UIImage(named: "Cases.png"), segue:"CreateCaseVC"),
            CollapsableViewModel(label: "Discussion", image: UIImage(named: "Discussions.png"), segue:"CreateDiscussionVC"),
            CollapsableViewModel(label: "Research", image: UIImage(named: "Researches.png"), segue:"CreateResearchVC")]),
        CollapsableViewModel(label: "My posts", image: UIImage(named: "MyPosts.png"), children: [
            CollapsableViewModel(label: "Clinical cases", image: UIImage(named: "Cases.png"), segue:"MyCasesVC"),
            CollapsableViewModel(label: "Discussions", image: UIImage(named: "Discussions.png"), segue:"MyDiscussionsVC"),
            CollapsableViewModel(label: "Researches", image: UIImage(named: "Researches.png"), segue:"MyResearchesVC")]),
        CollapsableViewModel(label: "Settings", image: UIImage(named: "Settings.png"), segue:"SettingsVC"),
        CollapsableViewModel(label: "Log Out", image: UIImage(named: "Logout.png"))]
    
    var displayedRows: [CollapsableViewModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayedRows = doctorData
        if (usertype! == "Admin") {
            displayedRows = adminData
        }
        self.menu_table.delegate = self
        self.menu_table.dataSource = self
        menu_table.separatorStyle = .none
        self.view.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: menu_table.frame.width, height: 100))
        let myLabel = UILabel()
        myLabel.frame = CGRect(x:0, y:0, width:menu_table.frame.width, height:100)
        myLabel.font = UIFont.boldSystemFont(ofSize: 15)
        myLabel.textColor = UIColor.black
        myLabel.textAlignment = .center
        let attributsBold = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .bold)]
        let attributsNormal = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .regular)]
        let greeting = NSMutableAttributedString(string: "Hi ", attributes:attributsNormal)
        let user = NSMutableAttributedString(string: username, attributes:attributsBold)
        greeting.append(user)
        myLabel.attributedText = greeting
        headerView.addSubview(myLabel)
        return headerView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedRows.count
    }
    
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: "cell") as? CollapsibleTableViewCell) ?? CollapsibleTableViewCell(style: .default, reuseIdentifier: "cell")
        cell.configure(withViewModel: displayedRows[indexPath.row])
        return cell
    }
    
      func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let viewModel = displayedRows[indexPath.row]
        if viewModel.children.count > 0 {
            let range = indexPath.row+1...indexPath.row+viewModel.children.count
            let indexPaths = range.map { IndexPath(row: $0, section: indexPath.section) }
            tableView.beginUpdates()
            if viewModel.isCollapsed {
                displayedRows.insert(contentsOf: viewModel.children, at: indexPath.row + 1)
                tableView.insertRows(at: indexPaths, with: .automatic)
            } else {
                displayedRows.removeSubrange(range)
                tableView.deleteRows(at: indexPaths, with: .automatic)
            }
            tableView.endUpdates()
        }
        viewModel.isCollapsed = !viewModel.isCollapsed
        if (viewModel.label == "Log Out") {
            logout()
        } else if (viewModel.segue != nil) {
            closeMenu()
            presentVC(segue: viewModel.segue!)
        }
    }
}
