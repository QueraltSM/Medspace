import UIKit
import FirebaseDatabase
import FirebaseAuth

class EditCaseVC2: UIViewController, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var speciality_box: UIView!
    @IBOutlet weak var speciality_textfield: UITextField!
    @IBOutlet weak var case_examination: UITextView!
    @IBOutlet weak var case_history: UITextView!
    var selectedSpeciality: String?
    var clinical_case: Case?
    var needsUpdate: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setHeader(largeTitles: false, gray: false)
        case_examination.delegate = self
        case_history.delegate = self
        speciality_box.setBorder()
        case_examination.setBorder()
        case_history.setBorder()
        speciality_textfield.text = clinical_case!.speciality.name
        speciality_textfield.textColor = UIColor.black
        case_examination.customTextView(view_text:clinical_case!.examination,view_color:UIColor.black, view_font: UIFont.boldSystemFont(ofSize: 20.0), view_scroll: true)
        case_history.customTextView(view_text:clinical_case!.history,view_color:UIColor.black, view_font: UIFont.boldSystemFont(ofSize: 20.0), view_scroll: true)
        createPickerView()
        dismissPickerView()
    }
    
    @objc func action() {
        speciality_textfield.textColor = UIColor.black
        view.endEditing(true)
    }
    
    @IBAction func savePost(_ sender: Any) {
        var error = ""
        if case_history.text.isEmpty {
            error += "Write a history\n"
        }
        if case_examination.text.isEmpty {
            error += "Write a examination\n"
        }
        if clinical_case!.history == case_history.text && clinical_case!.examination == case_examination.text &&
            clinical_case!.speciality.name == speciality_textfield.text && !needsUpdate! {
            error = "There is no data that needs to be updated"
        }
        if error == "" {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            alert.title = "Do you want to update the case?"
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
                action in
                self.postCase()
                self.presentVC(segue: "MyCasesVC")
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            showAlert(title: "Error", message: error)
        }
    }
    
    func postCase() {
        let ref = Database.database().reference()
        let path = "Cases/\(clinical_case!.id)"
        ref.child("\(path)/title").setValue(clinical_case!.title)
        ref.child("\(path)/description").setValue(clinical_case!.description)
        ref.child("\(path)/history").setValue(case_history.text!)
        ref.child("\(path)/examination").setValue(case_examination.text!)
        ref.child("\(path)/speciality").setValue(speciality_textfield.text!)
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
}
