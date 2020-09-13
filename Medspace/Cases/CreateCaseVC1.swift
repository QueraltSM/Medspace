import UIKit

class CreateCaseVC1: UIViewController, UITextViewDelegate {

    @IBOutlet weak var title_view: UITextView!
    @IBOutlet weak var description_view: UITextView!
    @IBOutlet weak var content: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setHeader(largeTitles: false, gray: true)
        setMenu()
        title_view.delegate = self
        description_view.delegate = self
        title_view.setBorder()
        description_view.setBorder()
        title_view.customTextView(view_text:"Title",view_color:UIColor.gray, view_font: UIFont.boldSystemFont(ofSize: 20.0), view_scroll: true)
        description_view.customTextView(view_text:"Description",view_color:UIColor.gray, view_font: UIFont.boldSystemFont(ofSize: 20.0), view_scroll: true)
        
        content.backgroundColor = UIColor.init(hexString: "#f2f2f2")
        navigationController?.navigationBar.backgroundColor = UIColor.init(hexString: "#f2f2f2")
        navigationController?.navigationBar.tintColor = UIColor.init(hexString: "#f2f2f2")
        navigationController?.navigationBar.barTintColor = UIColor.init(hexString: "#f2f2f2")
        navigationController?.navigationBar.isTranslucent = true
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
            let create_case_vc2 = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CreateCaseVC2") as? CreateCaseVC2
            create_case_vc2!.case_title = title_view.text
            create_case_vc2!.case_description = description_view.text
            navigationController?.pushViewController(create_case_vc2!, animated: false)
        } else {
            showAlert(title: "Error", message: error)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.gray {
            textView.customTextView(view_text:"",view_color:UIColor.black, view_font: UIFont.boldSystemFont(ofSize: 20.0), view_scroll: true)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 100
    }
}
