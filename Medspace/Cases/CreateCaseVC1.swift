import UIKit

class CreateCaseVC1: UIViewController, UITextViewDelegate {

    @IBOutlet weak var title_view: UITextView!
    @IBOutlet weak var description_view: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.shadowImage = UIImage()
        setMenu()
        title_view.delegate = self
        description_view.delegate = self
        title_view.setBorder()
        description_view.setBorder()
        title_view.customTextView(view_text:"Write a title...",view_color:UIColor.gray, view_font: UIFont.boldSystemFont(ofSize: 20.0), view_scroll: true)
        description_view.customTextView(view_text:"Description",view_color:UIColor.gray, view_font: UIFont.boldSystemFont(ofSize: 20.0), view_scroll: true)
    }
    
    @IBAction func didTapMenuButton(_ sender: Any) {
        swipeMenu()
    }
    
    @IBAction func savePost(_ sender: Any) {
        var error = ""
        if (title_view.textColor == UIColor.gray || title_view.text.isEmpty) {
            error += "Write a title\n"
        }
        if (description_view.textColor == UIColor.gray || description_view.text.isEmpty) {
            error += "Write a description\n"
        }
        if (error == "") {
            let case_description_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CreateCaseVC2") as? CreateCaseVC2
            case_description_vc!.case_title = title_view.text
            case_description_vc!.case_description = description_view.text
            navigationController?.pushViewController(case_description_vc!, animated: false)
        } else {
            showAlert(title: "Error saving the clinical case", message: error)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.gray {
            textView.customTextView(view_text:"",view_color:UIColor.black, view_font: UIFont.boldSystemFont(ofSize: 20.0), view_scroll: true)
        }
    }
}
