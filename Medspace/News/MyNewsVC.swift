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
    var searchBarIsHidden: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMenu()
        initComponents()
    }
    
    func initComponents(){
        ref = Database.database().reference()
        news_timeline.delegate = self
        news_timeline.dataSource = self
        news_timeline.separatorColor = UIColor.clear
        news_timeline.rowHeight = UITableView.automaticDimension
        getNews()
        searchController.searchBar.delegate = self
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        news_timeline.addSubview(refreshControl)
        news_timeline.allowsMultipleSelection = true
        UserDefaults.standard.set("MyNewsVC", forKey: "back")
    }
    
    func turnEditState(enabled: Bool, title: String) {
        editButton.isEnabled = enabled
        editButton.title = title
    }
    
    @IBAction func didTapSearchButton(_ sender: Any) {
        if searchBarIsHidden {
            setSearchBar()
            searchBarIsHidden = false
        } else {
            searchController.isActive = false
            news_timeline.tableHeaderView = nil
            searchBarIsHidden = true
        }
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
         return UITableView.automaticDimension
    }
    
    func loopNews(ref: DatabaseReference, snapshot: DataSnapshot) {
        self.startAnimation()
        for child in snapshot.children.allObjects as! [DataSnapshot] {
            let dict = child.value as? [String : AnyObject] ?? [:]
            let storageRef = Storage.storage().reference().child("News/\(child.key)")
            storageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) -> Void in
                let title = dict["title"]! as! String
                let speciality = dict["speciality"]! as! String
                let date = dict["date"]! as! String
                let description = dict["description"]! as! String
                let pic = UIImage(data: data!)
                let userid = dict["user"]! as! String
                if (userid == uid) {
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
                        self.news.append(News(id: child.key, image: pic!, date: date, title: title, speciality: Speciality(name: speciality, color: color), description: description, user: User(id: userid, fullname: fullname, username: username)))
                        let sortedNews = self.news.sorted {
                            $0.date > $1.date
                        }
                        self.news = sortedNews
                        self.news_timeline.reloadData()
                        self.stopAnimation()
                        self.turnEditState(enabled: true, title: "Select")
                        self.news_timeline.restore()
                    })
                } else {
                    self.stopAnimation()
                }
            }
        }
    }
    
    func getNews() {
        ref.child("News/\(uid!)").observeSingleEvent(of: .value, with: { snapshot in
            if (snapshot.children.allObjects.count == 0) {
                self.news_timeline.setEmptyView(title: "You have not post a news yet")
            } else {
                self.news_timeline.restore()
                self.loopNews(ref: self.ref, snapshot: snapshot)
            }
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !edit {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? NewsCell
        cell?.news_date.text = self.getFormattedDate(date: entry.date)
        cell?.news_title.text = entry.title
        cell?.image_header.image = entry.image
        cell?.news_speciality.text = entry.speciality.name
        cell?.speciality_color = entry.speciality.color
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
        let flexible1 = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        let selectAllButton: UIBarButtonItem = UIBarButtonItem(title: "All", style: .plain, target: self, action: #selector(didPressSelectAll))
        let deleteButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didPressDelete))
        let flexible2 = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        self.toolbarItems = [flexible1, selectAllButton, deleteButton, flexible2]
        self.navigationController?.toolbar.barTintColor = UIColor.white
        self.navigationController?.setToolbarHidden(hide, animated: false)
    }
    
    @IBAction func didTapEditButton(_ sender: Any) {
        if !edit {
            editButton.title = "Cancel"
            edit = true
            setToolbarDelete(hide: false)
        } else {
            editButton.title = "Select"
            edit = false
            setToolbarDelete(hide: true)
            cancelSelections()
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        news_timeline.setEditing(editing, animated: true)
    }
    
    func deleteSelectedRows() {
        setToolbarDelete(hide: true)
        if let selectedRows = news_timeline.indexPathsForSelectedRows {
            var items = [News]()
            for indexPath in selectedRows  {
                items.append(news[indexPath.row])
            }
            for _ in items {
                let index = news.firstIndex(where: { (item) -> Bool in
                    item.id == item.id
                })
                let path = "News/\(uid!)/\(news[index!].id)"
                removeDataDB(path: path)
                removeDataStorage(path: path)
                removeDataDB(path: "Comments/\(path)")
                news.remove(at: index!)
            }
            news_timeline.beginUpdates()
            news_timeline.deleteRows(at: selectedRows, with: .automatic)
            news_timeline.endUpdates()
        }
        if (news.count == 0) {
            turnEditState(enabled: false, title: "")
            news_timeline.setEmptyView(title: "You have not post a news yet")
        } else {
            edit = false
            turnEditState(enabled: true, title: "Select")
        }
    }
    
    @objc func didPressDelete() {
        if self.news_timeline.indexPathsForSelectedRows == nil {
            showAlert(title: "Error", message: "You have not selected any news")
        } else {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            alert.title = "Are you sure you want to delete the \(self.news_timeline.indexPathsForSelectedRows!.count) selected news?"
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
                action in
                self.deleteSelectedRows()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func didPressSelectAll() {
        let totalRows = news_timeline.numberOfRows(inSection: 0)
        for row in 0..<totalRows {
            news_timeline.selectRow(at: NSIndexPath(row: row, section: 0) as IndexPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
        }
    }
}
