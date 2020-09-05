import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class MyNewsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating {

    @IBOutlet weak var news_timeline: UITableView!
    var news = [News]()
    var newsMatched = [News]()
    var searchController = UISearchController()
    @IBOutlet weak var editButton: UIBarButtonItem!
    var edit = false
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.shadowImage = UIImage()
        setMenu()
        ref = Database.database().reference()
        news_timeline.delegate = self
        news_timeline.dataSource = self
        news_timeline.separatorColor = UIColor.clear
        news_timeline.rowHeight = UITableView.automaticDimension
        getNews()
        turnEditState(enabled: false, title: "")
        if news.count > 0 {
             turnEditState(enabled: true, title: "Select to delete")
        }
        searchController.searchBar.delegate = self
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        news_timeline.addSubview(refreshControl)
        news_timeline.allowsMultipleSelection = true
    }
    
    func turnEditState(enabled: Bool, title: String) {
        editButton.isEnabled = enabled
        editButton.title = title
    }
    
    @IBAction func didTapSearchButton(_ sender: Any) {
         setSearchBar()
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
        news_timeline.tableHeaderView = searchController.searchBar
    }
    
    @objc func refresh(_ sender: AnyObject) {
        news = [News]()
        getNews()
        refreshControl.endRefreshing()
    }
    
    func filterContent(for searchText: String) {
        newsMatched = news.filter({ (n) -> Bool in
            let match = n.title.lowercased().range(of: searchText.lowercased()) != nil ||
                n.speciality.name.lowercased().range(of: searchText.lowercased()) != nil
            return match
        })
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if !searchController.isActive {
            news_timeline.tableHeaderView = nil
            news_timeline.reloadData()
        } else {
            if let searchText = searchController.searchBar.text {
                if (searchController.searchBar.text?.count)! > 2  {
                    filterContent(for: searchText)
                    news_timeline.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 330
    }
    
    func loopSnapshotChildren(ref: DatabaseReference, snapshot: DataSnapshot) {
        for child in snapshot.children.allObjects as! [DataSnapshot] {
            self.setActivityIndicator()
            let dict = child.value as? [String : AnyObject] ?? [:]
            let storageRef = Storage.storage().reference().child("News/\(child.key)")
            storageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) -> Void in
                let title = dict["title"]! as! String
                let speciality = dict["speciality"]! as! String
                let date = dict["date"]! as! String
                let final_date = self.getFormattedDate(date: date)
                let body = dict["body"]! as! String
                let pic = UIImage(data: data!)
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
                        self.news.append(News(id: child.key, image: pic!, date: final_date, title: title, speciality: Speciality(name: speciality, color: color), body: body, user: User(id: userid, name: username)))
                        let sortedNews = self.news.sorted {
                            $0.date > $1.date
                        }
                        self.news = sortedNews
                        self.news_timeline.reloadData()
                        self.stopAnimation()
                    })
                } else {
                    self.stopAnimation()
                }
            }
        }
    }
    
    func getNews() {
        ref.child("News").observeSingleEvent(of: .value, with: { snapshot in
            if (snapshot.children.allObjects.count == 0) {
                self.news_timeline.setEmptyView(title: "You have not post a news yet\n\n:(")
                self.turnEditState(enabled: false, title: "")
            } else {
                self.news_timeline.restore()
                self.turnEditState(enabled: true, title: "Select to delete")
            }
            self.loopSnapshotChildren(ref: self.ref, snapshot: snapshot)
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (!edit) {
            cancelSelections()
            let selected_news = news[indexPath.row]
            let show_news_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ShowNewsVC") as? ShowNewsVC
            show_news_vc!.news = selected_news
            navigationController?.pushViewController(show_news_vc!, animated: false)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? newsMatched.count : news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entry = searchController.isActive ? newsMatched[indexPath.row] : news[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? HomeCell
        cell?.news_date.text = entry.date
        cell?.news_title.text = entry.title
        cell?.image_header.image = entry.image
        cell?.news_speciality.text = entry.speciality.name
        cell?.news_speciality.backgroundColor = entry.speciality.color
        return cell!
    }
    
    func cancelSelections() {
        let selectedRows = self.news_timeline.indexPathsForSelectedRows
        if selectedRows != nil {
            for var selectionIndex in selectedRows! {
                while selectionIndex.item >= news.count {
                    selectionIndex.item -= 1
                }
                self.news_timeline.deselectRow(at: selectionIndex, animated: true)
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
    
    @IBAction func didTapEditButton(_ sender: Any) {
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            news.remove(at: indexPath.item)
            news_timeline.reloadData()
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        news_timeline.setEditing(editing, animated: true)
    }
    
    @objc func didPressDelete() {
        setToolbarDelete(hide: true)
        let selectedRows = self.news_timeline.indexPathsForSelectedRows
        if selectedRows != nil {
            for var selectionIndex in selectedRows! {
                removeNewsDB(news: news[selectionIndex.item])
                while selectionIndex.item >= news.count {
                    selectionIndex.item -= 1
                }
                tableView(news_timeline, commit: .delete, forRowAt: selectionIndex)
            }
        }
        if (news.count == 0) {
            turnEditState(enabled: false, title: "")
            news_timeline.setEmptyView(title: "You have not post a news yet\n\n:(")
        } else {
            turnEditState(enabled: true, title: "Select to delete")
        }
    }
}
