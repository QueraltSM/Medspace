import UIKit
import FirebaseDatabase

class MyDiscussionsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating{

    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var discussions_timeline: UITableView!
    var searchController = UISearchController()
    var discussions = [Discussion]()
    var discussionsMatched = [Discussion]()
    var edit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setHeader(largeTitles: true)
        setMenu()
        discussions_timeline.delegate = self
        discussions_timeline.dataSource = self
        discussions_timeline.separatorColor = UIColor.clear
        discussions_timeline.rowHeight = UITableView.automaticDimension
        getDiscussions()
        searchController.searchBar.delegate = self
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        discussions_timeline.addSubview(refreshControl)
    }
    
    func getDiscussions() {
        let ref = Database.database().reference()
        ref.child("Discussions").observeSingleEvent(of: .value, with: { snapshot in
            if (snapshot.children.allObjects.count == 0) {
                self.turnEditState(enabled: false, title: "")
                self.discussions_timeline.setEmptyView(title: "There is no discussion posted yet\n\n:(")
            } else {
                self.turnEditState(enabled: true, title: "Select to delete")
                self.discussions_timeline.restore()
            }
            self.loopSnapshotChildren(ref: ref, snapshot: snapshot)
        })
    }
    
    func loopSnapshotChildren(ref: DatabaseReference, snapshot: DataSnapshot) {
        for child in snapshot.children.allObjects as! [DataSnapshot] {
            let dict = child.value as? [String : AnyObject] ?? [:]
            let title = dict["title"]! as! String
            let description = dict["description"]! as! String
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
                self.discussions.append(Discussion(id: child.key, title: title, description: description, date: final_date, speciality: Speciality(name: speciality, color: color), user: User(id: userid, name: username)))
                let sortedDiscussions = self.discussions.sorted {
                    $0.date > $1.date
                }
                self.discussions = sortedDiscussions
                self.stopAnimation()
                self.discussions_timeline.reloadData()
            })
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
                n.speciality.name.lowercased().range(of: searchText.lowercased()) != nil ||
                n.user.name.lowercased().range(of: searchText.lowercased()) != nil
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
        return 250
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
        cell?.data_date.text = entry.date
        cell?.data_title.text = entry.title
        cell?.data_speciality.text = entry.speciality.name
        cell?.data_user.text = entry.user.name
        cell?.data_speciality.backgroundColor = entry.speciality.color
        cell?.data_view.layer.borderColor = entry.speciality.color?.cgColor
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
        let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        let deleteButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didPressDelete))
        self.toolbarItems = [flexible, deleteButton]
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
    
    @objc func didPressDelete() {
        setToolbarDelete(hide: true)
        let selectedRows = self.discussions_timeline.indexPathsForSelectedRows
        if selectedRows != nil {
            for var selectionIndex in selectedRows! {
                removeDataDB(path: "Discussions/\(discussions[selectionIndex.item].id)")
                while selectionIndex.item >= discussions.count {
                    selectionIndex.item -= 1
                }
                tableView(discussions_timeline, commit: .delete, forRowAt: selectionIndex)
            }
        }
        if (discussions.count == 0) {
            turnEditState(enabled: false, title: "")
            discussions_timeline.setEmptyView(title: "You have not post a discussion yet\n\n:(")
        } else {
            edit = false
            turnEditState(enabled: true, title: "Select to delete")
        }
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
}
