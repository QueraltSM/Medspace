import UIKit

class EditCaseVC1: UIViewController, UITextViewDelegate {

    @IBOutlet weak var case_title: UITextView!
    @IBOutlet weak var case_description: UITextView!
    var clinical_case: Case?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideToolbar()
        setHeader(largeTitles: false)
        case_title.delegate = self
        case_description.delegate = self
        case_title.setBorder()
        case_description.setBorder()
        case_title.customTextView(view_text:clinical_case!.title,view_color:UIColor.gray, view_font: UIFont.boldSystemFont(ofSize: 20.0), view_scroll: true)
        case_description.customTextView(view_text:clinical_case!.description,view_color:UIColor.gray, view_font: UIFont.boldSystemFont(ofSize: 20.0), view_scroll: true)
    }
    
    @IBAction func nextSegue(_ sender: Any) {
        var error = ""
        if (case_title.text.isEmpty) {
            error += "Write a title\n"
        }
        if (case_description.text.isEmpty) {
            error += "Write a description\n"
        }
        if (error == "") {
            let edit_case_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EditCaseVC2") as? EditCaseVC2
            let final_case = Case(id: clinical_case!.id, title: case_title.text!, description: case_description.text!, history: clinical_case!.history, examination: clinical_case!.examination, date: clinical_case!.date, speciality: clinical_case!.speciality, user: clinical_case!.user)
            edit_case_vc!.clinical_case = final_case
            navigationController?.pushViewController(edit_case_vc!, animated: false)
        }
        if (error != "") {
            showAlert(title: "Error in saving the research", message: error)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 80
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.gray {
            textView.customTextView(view_text:"",view_color:UIColor.black, view_font: UIFont.boldSystemFont(ofSize: 20.0), view_scroll: true)
        }
    }
}
