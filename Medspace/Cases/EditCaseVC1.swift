import UIKit

class EditCaseVC1: UIViewController, UITextViewDelegate {

    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var description_label: UILabel!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var case_title: UITextView!
    @IBOutlet weak var case_description: UITextView!
    var clinical_case: Case?
    var needsUpdate: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setHeader(largeTitles: false, gray: true)
        scrollview.backgroundColor = UIColor.init(hexString: "#f2f2f2")
        case_title.delegate = self
        case_description.delegate = self
        scrollview.contentLayoutGuide.bottomAnchor.constraint(equalTo: case_description.bottomAnchor).isActive = true
        title_label.setLabelBorders()
        description_label.setLabelBorders()
        //case_title.setTopBorder()
        //case_description.setTopBorder()
        //case_title.setBorder()
        //case_description.setBorder()
        case_title.text = clinical_case!.title
        case_description.text = clinical_case!.description
        //case_title.customTextView(view_text:clinical_case!.title,view_color:UIColor.black, view_font: UIFont.boldSystemFont(ofSize: 20.0), view_scroll: true)
        //case_description.customTextView(view_text:clinical_case!.description,view_color:UIColor.black, view_font: UIFont.boldSystemFont(ofSize: 20.0), view_scroll: true)
    }
    
    @IBAction func nextSegue(_ sender: Any) {
        var error = ""
        if (case_title.text.isEmpty) {
            error += "Write a title\n"
        }
        if (case_description.text.isEmpty) {
            error += "Write a description\n"
        }
        if clinical_case!.title != case_title.text || clinical_case!.description != case_description.text  {
            needsUpdate = true
        }
        if (error == "") {
            let edit_case_vc2 = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EditCaseVC2") as? EditCaseVC2
            let final_case = Case(id: clinical_case!.id, title: case_title.text!, description: case_description.text!, history: clinical_case!.history, examination: clinical_case!.examination, date: clinical_case!.date, speciality: clinical_case!.speciality, user: clinical_case!.user)
            edit_case_vc2!.clinical_case = final_case
            edit_case_vc2!.needsUpdate = needsUpdate
            navigationController?.pushViewController(edit_case_vc2!, animated: false)
        } else {
            showAlert(title: "Error", message: error)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 100
    }
}
