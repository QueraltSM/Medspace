import UIKit
import FirebaseAuth

class ShowResearchVC: UIViewController {

   
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var user: UILabel!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var speciality: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var research_title: UILabel!
    @IBOutlet weak var research_description: UILabel!
    var research: Research?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMenu()
        setHeader(largeTitles: false, gray: false)
        scrollview.contentLayoutGuide.bottomAnchor.constraint(equalTo: research_description.bottomAnchor).isActive = true
        research_title.text = research!.title
        research_description.text = research!.description
        date.text = research!.date
        user.text = "Posted by \(research!.user.name)"
        user.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline).italic()
        speciality.text = research!.speciality.name.description
        speciality.backgroundColor = research!.speciality.color
        speciality.textColor = UIColor.black
        speciality.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
        speciality.round(corners: .allCorners, cornerRadius: 10)
        speciality.textAlignment = .center
        if (research!.user.id == Auth.auth().currentUser!.uid) {
            configResearch(enabled: true)
        }
    }
    
    func configResearch(enabled: Bool) {
        editButton.isEnabled = enabled
        deleteButton.isEnabled = enabled
        if enabled {
            editButton.title = "Edit"
            deleteButton.title = "Delete"
        }
    }
    
    @IBAction func editResearch(_ sender: Any) {
        let edit_research_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EditResearchVC1") as? EditResearchVC1
        edit_research_vc!.research = self.research
        navigationController?.pushViewController(edit_research_vc!, animated: false)
    }
    
    @IBAction func deleteResearch(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Are you sure you want delete it?"
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            let path = "Researches/\(self.research!.id)"
            self.removeDataDB(path: path)
            self.removeDataStorage(path: path)
            self.presentVC(segue: "MyResearchesVC")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func showComments(_ sender: Any) {
        print("all comments")
    }
    
    @IBAction func showDocument(_ sender: Any) {
        let document_viewer_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DocumentViewerVC") as? DocumentViewerVC
        document_viewer_vc!.document = research!.pdf
        navigationController?.pushViewController(document_viewer_vc!, animated: false)
    }
}
