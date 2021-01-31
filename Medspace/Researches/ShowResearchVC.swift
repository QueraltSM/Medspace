import UIKit
import FirebaseAuth

class ShowResearchVC: UIViewController {

    var research: Research?
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var speciality: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var research_title: UILabel!
    @IBOutlet weak var research_description: UILabel!
    @IBOutlet weak var user: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
        customNavBar()
    }
    
    func initComponents(){
        if #available(iOS 11.0, *) {
            scrollview.contentLayoutGuide.bottomAnchor.constraint(equalTo: research_description.bottomAnchor).isActive = true
        } else {
            scrollview.bottomAnchor.constraint(equalTo: research_description.bottomAnchor).isActive = true
        }
        user.text = "Posted by \(research!.user.username)"
        research_title.text = research!.title
        research_description.text = research!.description
        date.text = self.getFormattedDate(date: research!.date)
        speciality.text = research!.speciality.name.description
        speciality.backgroundColor = self.research!.speciality.color
        speciality.round(corners: .allCorners, cornerRadius: 10)
        speciality.textAlignment = .center
        if research!.user.id != uid {
            editButton.tintColor = UIColor.white
            deleteButton.tintColor =  UIColor.white
        }
        editButton.isEnabled = research!.user.id == uid
        deleteButton.isEnabled = research!.user.id == uid
    }

    
    @IBAction func editResearch(_ sender: Any) {
        let edit_research_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EditResearchVC") as? EditResearchVC
        edit_research_vc!.research = self.research
        navigationController?.pushViewController(edit_research_vc!, animated: false)
    }
    
    @IBAction func deleteResearch(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Are you sure you want delete it?"
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            let path = "Researches/\(uid!)/\(self.research!.id)"
            self.removeDataDB(path: path)
            self.removeDataStorage(path: path)
            self.removeDataDB(path: "Comments/\(path)")
            self.back()
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func showComments(_ sender: Any) {
        let comments_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CommentsVC") as? CommentsVC
        comments_vc!.research = research
        navigationController?.pushViewController(comments_vc!, animated: false)
    }
    
    @IBAction func showDocument(_ sender: Any) {
        let document_viewer_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DocumentViewerVC") as? DocumentViewerVC
        document_viewer_vc!.document = research!.pdf
        navigationController?.pushViewController(document_viewer_vc!, animated: false)
    }
    
    @IBAction func goBack(_ sender: Any) {
        back()
    }
}
