import UIKit

class EditCaseVC: UIViewController, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var speciality_textfield: UITextField!
    @IBOutlet weak var case_title: UITextView!
    @IBOutlet weak var case_description: UITextView!
    @IBOutlet weak var case_history: UITextView!
    @IBOutlet weak var case_examination: UITextView!
    var selectedSpeciality: String?
    var clinical_case: Case?
    var needsUpdate: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        case_title.delegate = self
        case_description.delegate = self
        case_title.text = clinical_case!.title
        case_title.textColor = UIColor.black
        case_description.text = clinical_case!.description
        case_description.textColor = UIColor.black
        case_history.text = clinical_case!.history
        case_history.textColor = UIColor.black
        case_examination.text = clinical_case!.examination
        case_examination.textColor = UIColor.black
        speciality_textfield.text = clinical_case!.speciality.name
        speciality_textfield.textColor = UIColor.black
        let disclosure = UITableViewCell()
        disclosure.frame = speciality_textfield.bounds
        disclosure.accessoryType = .disclosureIndicator
        disclosure.isUserInteractionEnabled = false
        disclosure.tintColor = UIColor.darkGray
        speciality_textfield.addSubview(disclosure)
        if #available(iOS 11.0, *) {
            scrollview.contentLayoutGuide.bottomAnchor.constraint(equalTo: case_examination.bottomAnchor).isActive = true
        } else {
            // Fallback on earlier versions
        }
        scrollview.backgroundColor = UIColor.white
        createPickerView()
        dismissPickerView()
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
    
    @objc func action() {
        if selectedSpeciality == nil {
            selectedSpeciality = specialities[specialities.count / 2].name
            speciality_textfield.text = specialities[specialities.count / 2].name
        }
        speciality_textfield.textColor = UIColor.black
        view.endEditing(true)
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
    

    @IBAction func saveCase(_ sender: Any) {
        var error = ""
        if (case_title.text.isEmpty) {
            error += "Write a title\n"
        }
        if (case_description.text.isEmpty) {
            error += "Write a description\n"
        }
        if (case_history.text.isEmpty) {
            error += "Write a history\n"
        }
        if (case_examination.text.isEmpty) {
            error += "Write a examination\n"
        }
        if clinical_case!.title == case_title.text && clinical_case!.description == case_description.text &&
            clinical_case!.history == case_history.text && clinical_case!.examination == case_examination.text {
            error = "You have not modified the previous data"
        }
        if (error == "") {
            askPost()
        } else {
            showAlert(title: "Error", message: error)
        }
    }
    
    func askPost(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Do you want to update the clinical case?"
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            let user = uid
            let now = self.clinical_case!.date
            let path = "Cases/\(now)::\(uid!)"
            self.postCase(path: path, title: self.case_title.text!, description: self.case_description.text!,
                          history: self.case_history.text!, examination: self.case_examination.text!,
                speciality:self.speciality_textfield.text!, user: user!, date: now)
            self.presentVC(segue: "MyCasesVC")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 100
    }
}
