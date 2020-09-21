import UIKit
import Firebase
import FirebaseAuth

class DoctorMenuVC: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var fullname: UILabel!
    @IBOutlet weak var menu_table: UITableView!
    
    let data = [
        CollapsableViewModel(label: "Home", image: UIImage(named: "Home.png"), segue:"NewsVC"),
        CollapsableViewModel(label: "My posts", image: UIImage(named: "MyPosts.png"), children: [
            CollapsableViewModel(label: "Clinical cases", image: UIImage(named: "Cases.png"), segue:"MyCasesVC"),
            CollapsableViewModel(label: "Discussions", image: UIImage(named: "Discussions.png"), segue:"MyDiscussionsVC"),
            CollapsableViewModel(label: "Researches", image: UIImage(named: "Researches.png"), segue:"MyResearchesVC")]),
        CollapsableViewModel(label: "Add new post", image: UIImage(named: "NewPost.png"), children: [
            CollapsableViewModel(label: "Clinical case", image: UIImage(named: "Cases.png"), segue:"CreateCaseVC"),
            CollapsableViewModel(label: "Discussion", image: UIImage(named: "Discussions.png"), segue:"CreateDiscussionVC"),
            CollapsableViewModel(label: "Research", image: UIImage(named: "Researches.png"), segue:"CreateResearchVC")]),
        CollapsableViewModel(label: "Posts", image: UIImage(named: "Posts.png"), children: [
            CollapsableViewModel(label: "Clinical cases", image: UIImage(named: "Cases.png"), segue:"CasesVC"),
            CollapsableViewModel(label: "Discussions", image: UIImage(named: "Discussions.png"), segue:"DiscussionsVC"),
            CollapsableViewModel(label: "Researches", image: UIImage(named: "Researches.png"), segue:"ResearchesVC")]),
        CollapsableViewModel(label: "Profile", image: UIImage(named: "Account.png"), segue:"ProfileVC"),
        CollapsableViewModel(label: "Account settings", image: UIImage(named: "Settings.png"), segue:"SettingsVC"),
        CollapsableViewModel(label: "Logout", image: UIImage(named: "Logout.png"))]
    
    var displayedRows: [CollapsableViewModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayedRows = data
        self.menu_table.delegate = self
        self.menu_table.dataSource = self
        menu_table.separatorStyle = .none
        self.view.backgroundColor = UIColor.clear
        self.fullname.text = username
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
        if (viewModel.label == "Logout") {
            logout()
        } else if (viewModel.segue != nil) {
            closeMenu()
            presentVC(segue: viewModel.segue!)
        }
    }
}
