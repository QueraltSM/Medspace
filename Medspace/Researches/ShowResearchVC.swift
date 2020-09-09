import UIKit
import FirebaseAuth

class ShowResearchVC: UIViewController {

    @IBOutlet weak var speciality: UILabel!
    @IBOutlet weak var research_title: UILabel!
    @IBOutlet weak var research_date: UILabel!
    @IBOutlet weak var research_description: UILabel!
    var research: Research?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.shadowImage = UIImage()
        setMenu()
        research_title.text = research!.title
        research_description.text = research!.description
        research_date.text = research!.date
        speciality.text = research!.speciality.name.description
        speciality.backgroundColor = research!.speciality.color
        speciality.textColor = UIColor.white
        speciality.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
        speciality.round(corners: .allCorners, cornerRadius: 10)
        speciality.textAlignment = .center
        self.navigationController?.navigationBar.prefersLargeTitles = false
        if (research?.user.id == Auth.auth().currentUser?.uid) {
            setConfigDataToolbar()
        }
    }
    
    @IBAction func viewDocument(_ sender: Any) {
        let document_viewer_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DocumentViewerVC") as? DocumentViewerVC
        document_viewer_vc!.document = research!.pdf
        navigationController?.pushViewController(document_viewer_vc!, animated: false)
    }
    
    func setConfigDataToolbar() {
        self.navigationController?.isToolbarHidden = false
        var items = [UIBarButtonItem]()
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        items.append(UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deteleResearch)))
        items.append(UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editResearch)))
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        self.navigationController?.toolbar.barTintColor = UIColor.white
        self.toolbarItems = items
    }
    
    @objc func editResearch() {
        let show_research_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EditResearchVC1") as? EditResearchVC1
        show_research_vc!.research = self.research
        navigationController?.pushViewController(show_research_vc!, animated: false)
    }
    
    @objc func deteleResearch(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Are you sure you want delete it?"
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            let path = "Researches/\(self.research!.id)"
            self.removeDataDB(path: path)
            self.removeDataStorage(path: path)
            self.presentVC(segue: "ResearchesVC")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
