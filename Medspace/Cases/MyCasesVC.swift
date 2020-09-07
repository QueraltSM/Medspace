import UIKit
import FirebaseDatabase
import FirebaseAuth

class MyCasesVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating {

    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var cases_timeline: UITableView!
    var searchController = UISearchController()
    var cases = [Case]()
    var casesMatched = [Case]()
    var edit = false
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.shadowImage = UIImage()
        setMenu()
        ref = Database.database().reference()
        cases_timeline.delegate = self
        cases_timeline.dataSource = self
        cases_timeline.separatorColor = UIColor.clear
        cases_timeline.rowHeight = UITableView.automaticDimension
        getCases()
        turnEditState(enabled: false, title: "")
        if cases.count > 0 {
            turnEditState(enabled: true, title: "Select to delete")
        }
        searchController.searchBar.delegate = self
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        cases_timeline.addSubview(refreshControl)
        cases_timeline.allowsMultipleSelection = true
    }
    
    @objc func refresh(_ sender: AnyObject) {
        cases = [Case]()
        getCases()
        refreshControl.endRefreshing()
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
    
    @IBAction func didTapSearch(_ sender: Any) {
        setSearchBar()
    }
    
    @IBAction func didTapMenu(_ sender: Any) {
        swipeMenu()
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 330
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (!edit) {
            cancelSelections()
            let selected_case = cases[indexPath.row]
            let show_case_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ShowCaseVC") as? ShowCaseVC
            show_case_vc!.clinical_case = selected_case
            navigationController?.pushViewController(show_case_vc!, animated: false)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? casesMatched.count : cases.count
    }
    
    func cancelSelections() {
        let selectedRows = self.cases_timeline.indexPathsForSelectedRows
        if selectedRows != nil {
            for var selectionIndex in selectedRows! {
                while selectionIndex.item >= cases.count {
                    selectionIndex.item -= 1
                }
                self.cases_timeline.deselectRow(at: selectionIndex, animated: true)
            }
        }
    }
    
    func setToolbarDelete(hide: Bool) {
        let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        let deleteButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didPressDelete))
        self.toolbarItems = [flexible, deleteButton]
        self.navigationController?.toolbar.barTintColor = UIColor.white
        self.navigationController?.setToolbarHidden(hide, animated: false)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            cases.remove(at: indexPath.item)
            cases_timeline.reloadData()
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        cases_timeline.setEditing(editing, animated: true)
    }
    
    @objc func didPressDelete() {
        setToolbarDelete(hide: true)
        let selectedRows = self.cases_timeline.indexPathsForSelectedRows
        if selectedRows != nil {
            for var selectionIndex in selectedRows! {
                removeDataDB(path: "Cases/\(cases[selectionIndex.item].id)")
                while selectionIndex.item >= cases.count {
                    selectionIndex.item -= 1
                }
                tableView(cases_timeline, commit: .delete, forRowAt: selectionIndex)
            }
        }
        if (cases.count == 0) {
            turnEditState(enabled: false, title: "")
            cases_timeline.setEmptyView(title: "You have not post a case yet\n\n:(")
        } else {
            turnEditState(enabled: true, title: "Select to delete")
        }
    }
    
    func turnEditState(enabled: Bool, title: String) {
        editButton.isEnabled = enabled
        editButton.title = title
    }
    
    func loopSnapshotChildren(ref: DatabaseReference, snapshot: DataSnapshot) {
        for child in snapshot.children.allObjects as! [DataSnapshot] {
            self.setActivityIndicator()
            let dict = child.value as? [String : AnyObject] ?? [:]
            let title = dict["title"]! as! String
            let description = dict["description"]! as! String
            let history = dict["history"]! as! String
            let examination = dict["examination"]! as! String
            let speciality = dict["speciality"]! as! String
            let date = dict["date"]! as! String
            let final_date = self.getFormattedDate(date: date)
            let userid = dict["user"]! as! String
            ref.child("Users/\(userid)").observeSingleEvent(of: .value, with: { snapshot
                in
                let dict = snapshot.value as? [String : AnyObject] ?? [:]
                let username = dict["fullname"]! as! String
                var color = UIColor.init()
                for s in specialities {
                    if s.name == speciality {
                        color = s.color!
                    }
                }
                self.cases.append(Case(id: child.key, title: title, description: description, history: history, examination: examination, date: final_date, speciality: Speciality(name: speciality, color: color), user: User(id: userid, name: username)))
                let sortedResearches = self.cases.sorted {
                    $0.date > $1.date
                }
                self.cases = sortedResearches
                self.stopAnimation()
                self.cases_timeline.reloadData()
            })
        }
    }
    
    func getCases() {
        ref.child("Cases").observeSingleEvent(of: .value, with: { snapshot in
            if (snapshot.children.allObjects.count == 0) {
                self.cases_timeline.setEmptyView(title: "You have not post a case yet\n\n:(")
                self.turnEditState(enabled: false, title: "")
            } else {
                self.cases_timeline.restore()
                self.turnEditState(enabled: true, title: "Select to delete")
            }
            self.loopSnapshotChildren(ref: self.ref, snapshot: snapshot)
        })
    }
    
    @IBAction func didTapEdit(_ sender: Any) {
        if !edit {
            editButton.title = "Cancel"
            edit = true
            setToolbarDelete(hide: false)
        } else {
            editButton.title = "Select to delete"
            edit = false
            setToolbarDelete(hide: true)
            cancelSelections()
        }
    }
    
    func filterContent(for searchText: String) {
        casesMatched = cases.filter({ (n) -> Bool in
            let match = n.title.lowercased().range(of: searchText.lowercased()) != nil ||
                n.speciality.name.lowercased().range(of: searchText.lowercased()) != nil ||
                n.user.name.lowercased().range(of: searchText.lowercased()) != nil
            return match
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entry = searchController.isActive ? casesMatched[indexPath.row] : cases[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? DataCell
        cell?.data_date.text = entry.date
        cell?.data_title.text = entry.title
        cell?.data_speciality.text = entry.speciality.name
        cell?.data_speciality.backgroundColor = entry.speciality.color
        return cell!
    }
    
}
