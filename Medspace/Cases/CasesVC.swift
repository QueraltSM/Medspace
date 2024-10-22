import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class CasesVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating {

    var cases = [Case]()
    var casesMatched = [Case]()
    var searchController = UISearchController()
    @IBOutlet weak var cases_timeline: UITableView!
    var searchBarIsHidden: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
        customNavBar()
    }
    
    func initComponents(){
        cases_timeline.delegate = self
        cases_timeline.dataSource = self
        cases_timeline.separatorColor = UIColor.clear
        cases_timeline.rowHeight = UITableView.automaticDimension
        getCases()
        searchController.searchBar.delegate = self
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        cases_timeline.addSubview(refreshControl)
        UserDefaults.standard.set("CasesVC", forKey: "back")
    }

    func setSearchBar() {
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search by title, doctor or speciality"
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.barTintColor = UIColor.white
        searchController.searchResultsUpdater = self
        cases_timeline.tableHeaderView = searchController.searchBar
    }
    
    @objc func refresh(_ sender: AnyObject) {
        cases = [Case]()
        getCases()
        refreshControl.endRefreshing()
    }
    
    func filterContent(for searchText: String) {
        casesMatched = cases.filter({ (n) -> Bool in
            let match = n.title.lowercased().range(of: searchText.lowercased()) != nil ||
                n.speciality.name.lowercased().range(of: searchText.lowercased()) != nil ||
                n.user.username.lowercased().range(of: searchText.lowercased()) != nil ||
                n.user.fullname.lowercased().range(of: searchText.lowercased()) != nil
            return match
        })
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if !searchController.isActive {
            cases_timeline.tableHeaderView = nil
            cases_timeline.reloadData()
        } else {
            if let searchText = searchController.searchBar.text {
                if (searchController.searchBar.text?.count)! > 2  {
                    filterContent(for: searchText)
                    cases_timeline.reloadData()
                }
            }
        }
    }
    
    func loopCases(ref: DatabaseReference, snapshot: DataSnapshot) {
        for child in snapshot.children.allObjects as! [DataSnapshot] {
            self.startAnimation()
            let dict = child.value as? [String : AnyObject] ?? [:]
            for childDict in dict {
                let data = childDict.value as? [String : AnyObject] ?? [:]
                let title = data["title"]! as! String
                let description = data["description"]! as! String
                let history = data["history"]! as! String
                let examination = data["examination"]! as! String
                let speciality = data["speciality"]! as! String
                let date = data["date"]! as! String
                let userid = data["user"]! as! String
                ref.child("Users/\(userid)").observeSingleEvent(of: .value, with: { snapshot
                    in
                    let dict = snapshot.value as? [String : AnyObject] ?? [:]
                    let username = dict["username"]! as! String
                    let fullname = dict["fullname"]! as! String
                    var color = UIColor.init()
                    for s in specialities {
                        if s.name == speciality {
                            color = s.color!
                        }
                    }
                    self.cases.append(Case(id: childDict.key, title: title, description: description, history: history, examination: examination, date: date, speciality: Speciality(name: speciality, color: color), user: User(id: userid, fullname: fullname, username: username)))
                    let sortedCases = self.cases.sorted {
                        $0.date > $1.date
                    }
                    self.cases = sortedCases
                    self.cases_timeline.reloadData()
                    self.stopAnimation()
                })
            }
        }
    }
    
    @IBAction func didTapMenu(_ sender: Any) {
        swipeMenu()
    }
    
    func getCases() {
        let ref = Database.database().reference()
        ref.child("Cases").observeSingleEvent(of: .value, with: { snapshot in
            if (snapshot.children.allObjects.count == 0) {
                self.cases_timeline.setEmptyView(title: "No case has been posted yet")
            } else {
                self.cases_timeline.restore()
                self.loopCases(ref: ref, snapshot: snapshot)
            }
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cases_timeline.deselectRow(at: indexPath, animated: false)
        let selected_case = cases[indexPath.row]
        let show_case_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ShowCaseVC") as? ShowCaseVC
        show_case_vc!.clinical_case = selected_case
        navigationController?.pushViewController(show_case_vc!, animated: false)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? casesMatched.count : cases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entry = searchController.isActive ? casesMatched[indexPath.row] : cases[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? DataCell
        cell?.data_title.text = entry.title
        cell?.data_speciality.text = entry.speciality.name
        cell?.speciality_color = entry.speciality.color
        if entry.user.id == uid! {
            cell?.data_user.text =  "Me on \(self.getFormattedDate(date: entry.date))"
        } else {
            cell?.data_user.text =  "\(entry.user.username) on \(self.getFormattedDate(date: entry.date))"
        }
        return cell!
    }
    
    @IBAction func didTapSearchButton(_ sender: Any) {
        if searchBarIsHidden {
            setSearchBar()
            searchBarIsHidden = false
        } else {
            searchController.isActive = false
            cases_timeline.tableHeaderView = nil
            searchBarIsHidden = true
        }
    }
}
