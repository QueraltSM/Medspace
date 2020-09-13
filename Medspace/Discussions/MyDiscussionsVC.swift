import UIKit
import FirebaseDatabase
import FirebaseAuth

class MyDiscussionsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating{

    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var discussions_timeline: UITableView!
    var searchController = UISearchController()
    var discussions = [Discussion]()
    var discussionsMatched = [Discussion]()
    var ref: DatabaseReference!
    var edit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setHeader(largeTitles: true, gray: false)
        setMenu()
        ref = Database.database().reference()
        discussions_timeline.delegate = self
        discussions_timeline.dataSource = self
        discussions_timeline.separatorColor = UIColor.clear
        discussions_timeline.rowHeight = UITableView.automaticDimension
        getDiscussions()
        searchController.searchBar.delegate = self
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        discussions_timeline.addSubview(refreshControl)
        discussions_timeline.allowsMultipleSelection = true
    }
    
    func getDiscussions() {
        ref.child("Discussions").observeSingleEvent(of: .value, with: { snapshot in
            if (snapshot.children.allObjects.count == 0) {
                self.turnEditState(enabled: false, title: "")
                self.discussions_timeline.setEmptyView(title: "You have not post a discussion yet\n\n:(")
            } else {
                self.discussions_timeline.restore()
                self.loopDiscussions(ref: self.ref, snapshot: snapshot)
            }
        })
    }
    
    func loopDiscussions(ref: DatabaseReference, snapshot: DataSnapshot) {
        self.startAnimation()
        for child in snapshot.children.allObjects as! [DataSnapshot] {
            let dict = child.value as? [String : AnyObject] ?? [:]
            let title = dict["title"]! as! String
            let description = dict["description"]! as! String
            let speciality = dict["speciality"]! as! String
            let date = dict["date"]! as! String
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
                    self.discussions.append(Discussion(id: child.key, title: title, description: description, date: date, speciality: Speciality(name: speciality, color: color), user: User(id: userid, name: username)))
                    let sortedDiscussions = self.discussions.sorted {
                        $0.date > $1.date
                    }
                    self.discussions = sortedDiscussions
                    self.discussions_timeline.reloadData()
                    self.turnEditState(enabled: true, title: "Edit")
                    self.stopAnimation()
                })
            } else {
                self.stopAnimation()
            }
        }
    }
    
    func setSearchBar() {
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search by title, doctor or speciality"
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.barTintColor = UIColor.white
        searchController.searchResultsUpdater = self
        discussions_timeline.tableHeaderView = searchController.searchBar
    }
    
    @IBAction func didTapSearch(_ sender: Any) {
        setSearchBar()
    }
    
    @IBAction func didTapMenu(_ sender: Any) {
        swipeMenu()
    }
    
    @objc func refresh(_ sender: AnyObject) {
        discussions = [Discussion]()
        getDiscussions()
        refreshControl.endRefreshing()
    }
    
    func filterContent(for searchText: String) {
        discussionsMatched = discussions.filter({ (n) -> Bool in
            let match = n.title.lowercased().range(of: searchText.lowercased()) != nil ||
                n.speciality.name.lowercased().range(of: searchText.lowercased()) != nil
            return match
        })
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if !searchController.isActive {
            discussions_timeline.tableHeaderView = nil
            discussions_timeline.reloadData()
        } else {
            if let searchText = searchController.searchBar.text {
                if (searchController.searchBar.text?.count)! > 2  {
                    filterContent(for: searchText)
                    discussions_timeline.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (!edit) {
            cancelSelections()
            let selected_discussion = discussions[indexPath.row]
            let show_discussion_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ShowDiscussionVC") as? ShowDiscussionVC
            show_discussion_vc!.discussion = selected_discussion
            navigationController?.pushViewController(show_discussion_vc!, animated: false)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? discussionsMatched.count : discussions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entry = searchController.isActive ? discussionsMatched[indexPath.row] : discussions[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? DataCell
        cell?.data_date.text = self.getFormattedDate(date: entry.date)
        cell?.data_title.text = entry.title
        cell?.data_speciality.text = entry.speciality.name
        cell?.speciality_color = entry.speciality.color
        cell?.data_user.text = "Posted by \(entry.user.name)"
        return cell!
    }
    
    func turnEditState(enabled: Bool, title: String) {
        editButton.isEnabled = enabled
        editButton.title = title
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            discussions.remove(at: indexPath.item)
            discussions_timeline.reloadData()
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

    func cancelSelections() {
        let selectedRows = self.discussions_timeline.indexPathsForSelectedRows
        if selectedRows != nil {
            for var selectionIndex in selectedRows! {
                while selectionIndex.item >= discussions.count {
                    selectionIndex.item -= 1
                }
                self.discussions_timeline.deselectRow(at: selectionIndex, animated: true)
            }
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        discussions_timeline.setEditing(editing, animated: true)
    }
    
    func deleteSelectedRows() {
        setToolbarDelete(hide: true)
        if let selectedRows = discussions_timeline.indexPathsForSelectedRows {
            var items = [Discussion]()
            for indexPath in selectedRows  {
                items.append(discussions[indexPath.row])
            }
            for _ in items {
                let index = discussions.index(where: { (item) -> Bool in
                    item.id == item.id
                })
                let path = "Discussions/\(discussions[index!].id)"
                removeDataDB(path: path)
                discussions.remove(at: index!)
            }
            discussions_timeline.beginUpdates()
            discussions_timeline.deleteRows(at: selectedRows, with: .automatic)
            discussions_timeline.endUpdates()
        }
        if (discussions.count == 0) {
            turnEditState(enabled: false, title: "")
            discussions_timeline.setEmptyView(title: "You have not post a discussion yet\n\n:(")
        } else {
            edit = false
            turnEditState(enabled: true, title: "Edit")
        }
    }
    
    @objc func didPressDelete() {
        if self.discussions_timeline.indexPathsForSelectedRows == nil {
            showAlert(title: "Error", message: "You have not selected any discussion")
        } else {
            let selected_discussions = self.discussions_timeline.indexPathsForSelectedRows!.count
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            var r = "discussion"
            if selected_discussions > 1 {
                r += "s"
            }
            alert.title = "Are you sure you want to delete the \(selected_discussions) selected \(r)?"
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
                action in
                self.deleteSelectedRows()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func didPressSelectAll() {
        let totalRows = discussions_timeline.numberOfRows(inSection: 0)
        for row in 0..<totalRows {
            discussions_timeline.selectRow(at: NSIndexPath(row: row, section: 0) as IndexPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
        }
    }
    
    @IBAction func didTapEdit(_ sender: Any) {
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
}
