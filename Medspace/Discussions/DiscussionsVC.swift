import UIKit
import FirebaseDatabase

class DiscussionsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var discussions_timeline: UITableView!
    var searchController = UISearchController()
    var discussions = [Discussion]()
    var discussionsMatched = [Discussion]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.shadowImage = UIImage()
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

    @IBAction func didTapMenu(_ sender: Any) {
        swipeMenu()
    }
    
    func loopSnapshotChildren(ref: DatabaseReference, snapshot: DataSnapshot) {
        for child in snapshot.children.allObjects as! [DataSnapshot] {
            self.setActivityIndicator()
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
    
    func getDiscussions() {
        let ref = Database.database().reference()
        ref.child("Discussions").observeSingleEvent(of: .value, with: { snapshot in
            if (snapshot.children.allObjects.count == 0) {
                self.discussions_timeline.setEmptyView(title: "There is no discussion publish yet\n\n:(")
            } else {
                self.discussions_timeline.restore()
            }
            self.loopSnapshotChildren(ref: ref, snapshot: snapshot)
        })
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
        /*let selected_case = cases[indexPath.row]
         let show_discussion_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ShowDiscussionVC") as? ShowDiscussionVC
         show_discussion_vc!.discussion = selected_discussion
         navigationController?.pushViewController(show_discussion_vc!, animated: false)*/
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
    
}
