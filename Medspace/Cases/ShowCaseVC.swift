import UIKit
import FirebaseAuth
import FirebaseDatabase

class ShowCaseVC: UIViewController {

    var clinical_case: Case?
    
    @IBOutlet weak var examination: UILabel!
    @IBOutlet weak var history: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var speciality: UILabel!
    @IBOutlet weak var case_description: UILabel!
    @IBOutlet weak var case_title: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.shadowImage = UIImage()
        setMenu()
        case_title.text = clinical_case!.title
        case_description.text = clinical_case!.description
        history.text = clinical_case!.history
        examination.text = clinical_case!.examination
        date.text = clinical_case!.date
        speciality.text = clinical_case!.speciality.name.description
        speciality.backgroundColor = clinical_case!.speciality.color
        speciality.textColor = UIColor.white
        speciality.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
        speciality.round(corners: .allCorners, cornerRadius: 10)
        speciality.textAlignment = .center
        self.navigationController?.navigationBar.prefersLargeTitles = false
        if (clinical_case?.user.id == Auth.auth().currentUser?.uid) {
            setConfigDataToolbar()
        }
    }
    
    func setConfigDataToolbar() {
        self.navigationController?.isToolbarHidden = false
        var items = [UIBarButtonItem]()
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        items.append(UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deteleCase)))
        items.append(UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editCase)))
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        self.navigationController?.toolbar.barTintColor = UIColor.white
        self.toolbarItems = items
    }
    
    @objc func editCase() {
        let show_case_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EditCaseVC1") as? EditCaseVC1
        show_case_vc!.clinical_case = self.clinical_case
        navigationController?.pushViewController(show_case_vc!, animated: false)
    }

    @objc func deteleCase(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Are you sure you want delete it?"
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            self.removeCaseDB(clinical_case: self.clinical_case!)
            self.presentVC(segue: "CasesVC")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
