import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class CreateCaseVC2: UIViewController, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var history_view: UITextView!
    @IBOutlet weak var examination_view: UITextView!
    @IBOutlet weak var speciality_box: UIView!
    @IBOutlet weak var speciality_textfield: UITextField!
    var speciality: String = ""
    var case_title: String = ""
    var case_description: String = ""
    var selectedSpeciality: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setHeader(largeTitles: false, gray: false)
        setMenu()
        examination_view.delegate = self
        history_view.delegate = self
        speciality_textfield.delegate = self
        examination_view.setBorder()
        history_view.setBorder()
        speciality_box.setBorder()
        history_view.customTextView(view_text:"History",view_color:UIColor.gray, view_font: UIFont.boldSystemFont(ofSize: 20.0), view_scroll: true)
        examination_view.customTextView(view_text:"Examination",view_color:UIColor.gray, view_font: UIFont.boldSystemFont(ofSize: 20.0), view_scroll: true)
        speciality_textfield.text = specialities[specialities.count / 2].name
        speciality_textfield.textColor = UIColor.gray
        createPickerView()
        dismissPickerView()
    }
    
    @objc func action() {
        speciality_textfield.textColor = UIColor.black
        view.endEditing(true)
    }
    
    func createPickerView() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.backgroundColor = UIColor.white
        pickerView.selectRow(specialities.count / 2, inComponent: 0, animated: false)
        speciality_textfield.inputView = pickerView
    }
    
    func dismissPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        toolBar.barTintColor = UIColor.white
        toolBar.isTranslucent = false
        let button = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.action))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([space, button], animated: true)
        toolBar.isUserInteractionEnabled = true
        speciality_textfield.inputAccessoryView = toolBar
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return specialities.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return specialities[row].name
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedSpeciality = specialities[row].name
        speciality_textfield.text = selectedSpeciality
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 300
    }
    
    @IBAction func askPost(_ sender: Any) {
        var error = ""
        if (history_view.textColor == UIColor.gray || history_view.text.isEmpty) {
            error += "Write a history\n"
        }
        if (examination_view.textColor == UIColor.gray || examination_view.text.isEmpty) {
            error += "Write examination\n"
        }
        if (speciality_textfield.textColor == UIColor.gray) {
            error += "Choose a speciality"
        }
        if (error == "") {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            alert.title = "Do you want to post the clinical case?"
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
                action in
                let user = Auth.auth().currentUser?.uid
                let now = Date().description
                let path = "Cases/\(now)::\(user!)"
                self.postCase(path: path, title: self.case_title, description: self.case_description, history: self.history_view.text!, examination: self.examination_view.text!, speciality: self.speciality_textfield.text!, user: user!, date: now)
                self.presentVC(segue: "MyCasesVC")
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            showAlert(title: "Error", message: error)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.gray {
            textView.customTextView(view_text:"",view_color:UIColor.black, view_font: UIFont.boldSystemFont(ofSize: 20.0), view_scroll: true)
        }
    }
    
}
