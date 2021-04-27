import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class ResearchesVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var researches_timeline: UITableView!
    var researches = [Research]()
    var researchesMatched = [Research]()
    var searchController = UISearchController()
    var searchBarIsHidden: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMenu()
        initComponents()
    }
    
    func initComponents(){
        researches_timeline.delegate = self
        researches_timeline.dataSource = self
        researches_timeline.separatorColor = UIColor.clear
        researches_timeline.rowHeight = UITableView.automaticDimension
        getResearches()
        searchController.searchBar.delegate = self
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        researches_timeline.addSubview(refreshControl)
        UserDefaults.standard.set("ResearchesVC", forKey: "back")
    }
    
    func setSearchBar() {
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search by title, doctor or speciality"
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
                n.speciality.name.lowercased().range(of: searchText.lowercased()) != nil ||
                n.user.username.lowercased().range(of: searchText.lowercased()) != nil ||
                n.user.fullname.lowercased().range(of: searchText.lowercased()) != nil
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
    
    func loopResearches(ref: DatabaseReference, snapshot: DataSnapshot) {
        for child in snapshot.children.allObjects as! [DataSnapshot] {
            self.startAnimation()
            let dict = child.value as? [String : AnyObject] ?? [:]
            for childDict in dict {
                let data = childDict.value as? [String : AnyObject] ?? [:]
                let title = data["title"]! as! String
                let speciality = data["speciality"]! as! String
                let date = data["date"]! as! String
                let description = data["description"]! as! String
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
                    let storageRef = Storage.storage().reference().child("Researches/\(child.key)/\(childDict.key)")
                    storageRef.downloadURL { (url, error) in
                        if error == nil {
                            self.researches.append(Research(id: childDict.key, pdf: url!, date: date, title: title, speciality: Speciality(name: speciality, color: color), description: description, user: User(id: userid, fullname: fullname, username: username)))
                            let sortedResearches = self.researches.sorted {
                                $0.date > $1.date
                            }
                            self.researches = sortedResearches
                            self.researches_timeline.reloadData()
                            self.stopAnimation()
                        } else {
                            self.showAlert(title: "Error", message: (error?.localizedDescription)!)
                        }
                    }
                })
            }
        }
    }
    
    func getResearches() {
        let ref = Database.database().reference()
        ref.child("Researches").observeSingleEvent(of: .value, with: { snapshot in
            if (snapshot.children.allObjects.count == 0) {
                self.researches_timeline.setEmptyView(title: "No research has been posted yet")
            } else {
                self.researches_timeline.restore()
                self.loopResearches(ref: ref, snapshot: snapshot)
            }
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        researches_timeline.deselectRow(at: indexPath, animated: false)
        let selected_research = researches[indexPath.row]
        let show_research_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ShowResearchVC") as? ShowResearchVC
        show_research_vc!.research = selected_research
        navigationController?.pushViewController(show_research_vc!, animated: false)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? researchesMatched.count : researches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entry = searchController.isActive ? researchesMatched[indexPath.row] : researches[indexPath.row]
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
    
    @IBAction func didTapSearch(_ sender: Any) {
        if searchBarIsHidden {
            setSearchBar()
            searchBarIsHidden = false
        } else {
            searchController.isActive = false
            researches_timeline.tableHeaderView = nil
            searchBarIsHidden = true
        }
    }
    
    @IBAction func didTapMenu(_ sender: Any) {
        swipeMenu()
    }
}
