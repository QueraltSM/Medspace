import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class NewsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var news_timeline: UITableView!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    var searchController = UISearchController()
    var news = [News]()
    var newsMatched = [News]()
    var searchBarIsHidden: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
    }
    
    func initComponents(){
        uid = Auth.auth().currentUser!.uid
        usertype = UserDefaults.standard.string(forKey: "usertype")
        fullname = UserDefaults.standard.string(forKey: "fullname")
        username = UserDefaults.standard.string(forKey: "username")
        news = [News]()
        newsMatched = [News]()
        setMenu()
        news_timeline.delegate = self
        news_timeline.dataSource = self
        news_timeline.separatorColor = UIColor.clear
        news_timeline.rowHeight = UITableView.automaticDimension
        getNews()
        searchController.searchBar.delegate = self
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        news_timeline.addSubview(refreshControl)
        UserDefaults.standard.set("NewsVC", forKey: "back")
    }
    
    func filterContent(for searchText: String) {
        newsMatched = news.filter({ (n) -> Bool in
            let match = n.title.lowercased().range(of: searchText.lowercased()) != nil ||
                n.speciality.name.lowercased().range(of: searchText.lowercased()) != nil
            return match
        })
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
    
    func setSearchBar() {
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search by title or speciality"
        searchController.searchBar.barTintColor = UIColor.white
        searchController.searchResultsUpdater = self
        news_timeline.tableHeaderView = searchController.searchBar
    }
    
    @objc func refresh(_ sender: AnyObject) {
        news = [News]()
        getNews()
        refreshControl.endRefreshing()
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
    
    @IBAction func didTapMenu(_ sender: Any) {
        swipeMenu()
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
                })
            }
        }
    }
    
    func getNews() {
        let ref = Database.database().reference()
        ref.child("News").observeSingleEvent(of: .value, with: { snapshot in
            if (snapshot.children.allObjects.count == 0) {
                self.news_timeline.setEmptyView(title: "No news has been posted yet")
            } else {
                self.news_timeline.restore()
                self.loopNews(ref: ref, snapshot: snapshot)
            }
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        news_timeline.deselectRow(at: indexPath, animated: false)
        let selected_news = news[indexPath.row]
        let show_news_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ShowNewsVC") as? ShowNewsVC
        show_news_vc!.news = selected_news
        navigationController?.pushViewController(show_news_vc!, animated: false)
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
}
