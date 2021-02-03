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
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var description_label: UILabel!
    @IBOutlet weak var history_label: UILabel!
    @IBOutlet weak var examination_label: UILabel!
    @IBOutlet weak var user: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
        customNavBar()
    }
    
    func initComponents(){
        if #available(iOS 11.0, *) {
            scrollview.contentLayoutGuide.bottomAnchor.constraint(equalTo: examination.bottomAnchor).isActive = true
        } else {
            scrollview.bottomAnchor.constraint(equalTo: examination.bottomAnchor).isActive = true
        }
        user.text = "Posted by \(clinical_case!.user.username)"
        case_title.text = clinical_case!.title
        case_description.text = clinical_case!.description
        history.text = clinical_case!.history
        examination.text = clinical_case!.examination
        date.text = self.getFormattedDate(date: clinical_case!.date)
        speciality.text = clinical_case!.speciality.name.description
        speciality.backgroundColor = self.clinical_case!.speciality.color
        speciality.round(corners: .allCorners, cornerRadius: 10)
        speciality.textAlignment = .center
        if clinical_case!.user.id != uid {
            editButton.tintColor = UIColor.white
            deleteButton.tintColor =  UIColor.white
        }
        editButton.isEnabled = clinical_case!.user.id == uid
        deleteButton.isEnabled = clinical_case!.user.id == uid
    }
    
    @IBAction func deleteCase(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Are you sure you want delete it?"
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            let path = "Cases/\(uid!)/\(self.clinical_case!.id)"
            self.removeDataDB(path: path)
            self.removeDataDB(path: "Comments/\(path)")
            self.back()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func editCase(_ sender: Any) {
        let edit_case_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EditCaseVC") as? EditCaseVC
        edit_case_vc!.clinical_case = self.clinical_case
        navigationController?.pushViewController(edit_case_vc!, animated: false)
    }

    @IBAction func showComments(_ sender: Any) {
        let comments_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CommentsVC") as? CommentsVC
        comments_vc!.clinical_case = clinical_case
        navigationController?.pushViewController(comments_vc!, animated: false)
    }

    @IBAction func goBack(_ sender: Any) {
        back()
    }
}
