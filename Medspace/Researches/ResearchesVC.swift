import UIKit
import FirebaseDatabase
import FirebaseStorage

class ResearchesVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating {
    
    var researches = [Research]()
    var researchesMatched = [Research]()
    @IBOutlet weak var researches_timeline: UITableView!
    var searchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.shadowImage = UIImage()
        setMenu()
        researches_timeline.delegate = self
        researches_timeline.dataSource = self
        researches_timeline.separatorColor = UIColor.clear
        researches_timeline.rowHeight = UITableView.automaticDimension
        getResearches()
        searchController.searchBar.delegate = self
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        researches_timeline.addSubview(refreshControl)
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
                n.user.name.lowercased().range(of: searchText.lowercased()) != nil
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
    
    @IBAction func didTapMenuButton(_ sender: Any) {
        swipeMenu()
    }
    
    func loopSnapshotChildren(ref: DatabaseReference, snapshot: DataSnapshot) {
        for child in snapshot.children.allObjects as! [DataSnapshot] {
            self.setActivityIndicator()
            let dict = child.value as? [String : AnyObject] ?? [:]
            let title = dict["title"]! as! String
            let speciality = dict["speciality"]! as! String
            let date = dict["date"]! as! String
            let final_date = self.getFormattedDate(date: date)
            let description = dict["description"]! as! String
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
                print("Researches/\(child.key)")
                let storageRef = Storage.storage().reference().child("Researches/\(child.key)")
                storageRef.downloadURL { (url, error) in
                    self.stopAnimation()
                    if error == nil {
                        self.researches.append(Research(id: child.key, pdf: url!, date: final_date, title: title, speciality: Speciality(name: speciality, color: color), description: description, user: User(id: userid, name: username)))
                        let sortedResearches = self.researches.sorted {
                            $0.date > $1.date
                        }
                        self.researches = sortedResearches
                        self.researches_timeline.reloadData()
                    } else {
                        self.showAlert(title: "Error", message: (error?.localizedDescription)!)
                    }
                }
            })
        }
    }
    
    func getResearches() {
        let ref = Database.database().reference()
        ref.child("Researches").observeSingleEvent(of: .value, with: { snapshot in
            if (snapshot.children.allObjects.count == 0) {
                self.researches_timeline.setEmptyView(title: "There is no research publish yet\n\n:(")
            } else {
                self.researches_timeline.restore()
            }
            self.loopSnapshotChildren(ref: ref, snapshot: snapshot)
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    
    @IBAction func didTapMenu(_ sender: Any) {
        swipeMenu()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
        cell?.data_date.text = entry.date
        cell?.data_title.text = entry.title
        cell?.data_speciality.text = entry.speciality.name
        cell?.data_user.text = entry.user.name
        cell?.data_speciality.backgroundColor = entry.speciality.color
        cell?.data_view.layer.borderColor = entry.speciality.color?.cgColor
        return cell!
    }
    
    @IBAction func didTapSearch(_ sender: Any) {
        setSearchBar()
    }
    
}
