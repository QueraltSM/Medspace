import UIKit
import FirebaseAuth
import FirebaseDatabase

class ShowCaseVC: UIViewController {

    var clinical_case: Case?
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var examination: UILabel!
    @IBOutlet weak var history: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var speciality: UILabel!
    @IBOutlet weak var case_description: UILabel!
    @IBOutlet weak var case_title: UILabel!
    @IBOutlet weak var user: UILabel!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var description_label: UILabel!
    @IBOutlet weak var history_label: UILabel!
    @IBOutlet weak var examination_label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMenu()
        setHeader(largeTitles: false, gray: false)
        scrollview.contentLayoutGuide.bottomAnchor.constraint(equalTo: examination.bottomAnchor).isActive = true
        case_title.text = clinical_case!.title
        case_description.text = clinical_case!.description
        description_label.setLabelBorders()
        history_label.setLabelBorders()
        examination_label.setLabelBorders()
        history.text = clinical_case!.history
        examination.text = clinical_case!.examination
        date.text = clinical_case!.date
        user.text = "Posted by \(clinical_case!.user.name)"
        user.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline).italic()
        speciality.text = clinical_case!.speciality.name.description
        speciality.backgroundColor = clinical_case!.speciality.color
        speciality.textColor = UIColor.black
        speciality.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
        speciality.round(corners: .allCorners, cornerRadius: 10)
        speciality.textAlignment = .center
        if (clinical_case?.user.id == Auth.auth().currentUser?.uid) {
            configCase(enabled: true)
        }
    }
    
    func configCase(enabled: Bool) {
        editButton.isEnabled = enabled
        deleteButton.isEnabled = enabled
        if enabled {
            editButton.title = "Edit"
            deleteButton.title = "Delete"
        }
    }

    @IBAction func deleteCase(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Are you sure you want delete it?"
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            let path = "Cases/\(self.clinical_case!.id)"
            self.removeDataDB(path: path)
            self.presentVC(segue: "MyCasesVC")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func editCase(_ sender: Any) {
        let edit_case_vc1 = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EditCaseVC1") as? EditCaseVC1
        edit_case_vc1!.clinical_case = self.clinical_case
        navigationController?.pushViewController(edit_case_vc1!, animated: false)
    }

    @IBAction func showComments(_ sender: Any) {
        print("show comments")
    }
}
