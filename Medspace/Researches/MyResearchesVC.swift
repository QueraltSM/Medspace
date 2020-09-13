import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class MyResearchesVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating {

    @IBOutlet weak var researches_timeline: UITableView!
    var researches = [Research]()
    var researchesMatched = [Research]()
    var searchController = UISearchController()
    var edit = false
    var ref: DatabaseReference!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMenu()
        setHeader(largeTitles: true, gray: false)
        ref = Database.database().reference()
        researches_timeline.delegate = self
        researches_timeline.dataSource = self
        researches_timeline.separatorColor = UIColor.clear
        researches_timeline.rowHeight = UITableView.automaticDimension
        getResearches()
        searchController.searchBar.delegate = self
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        researches_timeline.addSubview(refreshControl)
        researches_timeline.allowsMultipleSelection = true
    }
    
    func turnEditState(enabled: Bool, title: String) {
        editButton.isEnabled = enabled
        editButton.title = title
    }
    
    @IBAction func didTapMenuButton(_ sender: Any) {
        swipeMenu()
    }
    
    func setSearchBar() {
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search by title or speciality"
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.barTintColor = UIColor.white
        searchController.searchResultsUpdater = self
        researches_timeline.tableHeaderView = searchController.searchBar
    }
    
    @objc func refresh(_ sender: AnyObject) {
        researches = [Research]()
        getResearches()
        refreshControl.endRefreshing()
    }
    
    func filterContent(for searchText: String) {
        researchesMatched = researches.filter({ (n) -> Bool in
            let match = n.title.lowercased().range(of: searchText.lowercased()) != nil ||
                n.speciality.name.lowercased().range(of: searchText.lowercased()) != nil
            return match
        })
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if !searchController.isActive {
            researches_timeline.tableHeaderView = nil
            researches_timeline.reloadData()
        } else {
            if let searchText = searchController.searchBar.text {
                if (searchController.searchBar.text?.count)! > 2  {
                    filterContent(for: searchText)
                    researches_timeline.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func loopResearches(ref: DatabaseReference, snapshot: DataSnapshot) {
        self.startAnimation()
        for child in snapshot.children.allObjects as! [DataSnapshot] {
            let dict = child.value as? [String : AnyObject] ?? [:]
            let title = dict["title"]! as! String
            let speciality = dict["speciality"]! as! String
            let date = dict["date"]! as! String
            let description = dict["description"]! as! String
            let userid = dict["user"]! as! String
            if (userid == Auth.auth().currentUser!.uid) {
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
                    let storageRef = Storage.storage().reference().child("Researches/\(child.key)")
                    storageRef.downloadURL { (url, error) in
                        self.stopAnimation()
                        if error == nil {
                            self.researches.append(Research(id: child.key, pdf: url!, date: date, title: title, speciality: Speciality(name: speciality, color: color), description: description, user: User(id: userid, name: username)))
                            let sortedResearches = self.researches.sorted {
                                $0.date > $1.date
                            }
                            self.researches = sortedResearches
                            self.researches_timeline.reloadData()
                            self.turnEditState(enabled: true, title: "Edit")
                        } else {
                            self.showAlert(title: "Error", message: error!.localizedDescription)
                        }
                    }
                })
            } else {
                self.stopAnimation()
            }
        }
    }
    
    func getResearches() {
        ref.child("Researches").observeSingleEvent(of: .value, with: { snapshot in
            if (snapshot.children.allObjects.count == 0) {
                self.researches_timeline.setEmptyView(title: "You have not post a research yet\n\n:(")
                self.turnEditState(enabled: false, title: "")
            } else {
                self.researches_timeline.restore()
                self.loopResearches(ref: self.ref, snapshot: snapshot)
            }
            
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (!edit) {
            cancelSelections()
            let selected_research = researches[indexPath.row]
            let show_research_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ShowResearchVC") as? ShowResearchVC
            show_research_vc!.research = selected_research
            navigationController?.pushViewController(show_research_vc!, animated: false)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? researchesMatched.count : researches.count
    }
    
    @IBAction func didTapEditButton(_ sender: Any) {
        if !edit {
            editButton.title = "Cancel"
            edit = true
            setToolbarDelete(hide: false)
        } else {
            editButton.title = "Edit"
            edit = false
            setToolbarDelete(hide: true)
            cancelSelections()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entry = searchController.isActive ? researchesMatched[indexPath.row] : researches[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? DataCell
        cell?.data_date.text = self.getFormattedDate(date: entry.date)
        cell?.data_title.text = entry.title
        cell?.data_speciality.text = entry.speciality.name
        cell?.speciality_color = entry.speciality.color
        cell?.data_user.text = "Posted by \(entry.user.name)"
        return cell!
    }
    
    func cancelSelections() {
        let selectedRows = self.researches_timeline.indexPathsForSelectedRows
        if selectedRows != nil {
            for var selectionIndex in selectedRows! {
                while selectionIndex.item >= researches.count {
                    selectionIndex.item -= 1
                }
                self.researches_timeline.deselectRow(at: selectionIndex, animated: true)
            }
        }
    }
    
    func setToolbarDelete(hide: Bool) {
        let flexible1 = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        let selectAllButton: UIBarButtonItem = UIBarButtonItem(title: "Select All", style: .plain, target: self, action: #selector(didPressSelectAll))
        let deleteButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didPressDelete))
        let flexible2 = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        self.toolbarItems = [flexible1, selectAllButton, deleteButton, flexible2]
        self.navigationController?.toolbar.barTintColor = UIColor.white
        self.navigationController?.setToolbarHidden(hide, animated: false)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            researches.remove(at: indexPath.item)
            researches_timeline.reloadData()
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        researches_timeline.setEditing(editing, animated: true)
    }
    
    func deleteSelectedRows() {
        setToolbarDelete(hide: true)
        if let selectedRows = researches_timeline.indexPathsForSelectedRows {
            var items = [Research]()
            for indexPath in selectedRows  {
                items.append(researches[indexPath.row])
            }
            for _ in items {
                let index = researches.index(where: { (item) -> Bool in
                    item.id == item.id
                })
                let path = "Researches/\(researches[index!].id)"
                removeDataDB(path: path)
                removeDataStorage(path: path)
                researches.remove(at: index!)
            }
            researches_timeline.beginUpdates()
            researches_timeline.deleteRows(at: selectedRows, with: .automatic)
            researches_timeline.endUpdates()
        }
        if (researches.count == 0) {
            turnEditState(enabled: false, title: "")
            researches_timeline.setEmptyView(title: "You have not post a research yet\n\n:(")
        } else {
            edit = false
            turnEditState(enabled: true, title: "Edit")
        }
    }
    
    @objc func didPressDelete() {
        if self.researches_timeline.indexPathsForSelectedRows == nil {
            showAlert(title: "Error", message: "You have not selected any research")
        } else {
            let selected_researches = self.researches_timeline.indexPathsForSelectedRows!.count
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            var r = "research"
            if selected_researches > 1 {
                r += "es"
            }
            alert.title = "Are you sure you want to delete the \(selected_researches) selected \(r)?"
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
                self.deleteSelectedRows()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func didPressSelectAll() {
        let totalRows = researches_timeline.numberOfRows(inSection: 0)
        for row in 0..<totalRows {
            researches_timeline.selectRow(at: NSIndexPath(row: row, section: 0) as IndexPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
        }
    }
}
