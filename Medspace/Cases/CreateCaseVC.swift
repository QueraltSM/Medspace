import UIKit

class CreateCaseVC: UIViewController, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var titleview: UITextView!
    @IBOutlet weak var description_view: UITextView!
    @IBOutlet weak var history: UITextView!
    @IBOutlet weak var examination: UITextView!
    @IBOutlet weak var speciality: UITextField!
    @IBOutlet weak var scrollview: UIScrollView!
    var selectedSpeciality: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMenu()
        titleview.delegate = self
        description_view.delegate = self
        history.delegate = self
        examination.delegate = self
        titleview.text = "Headache"
        titleview.textColor = UIColor.gray
        description_view.text = "This young man has been brought in unconscious having been well less than 24h previously. The most likely diagnoses are related to drugs or a neurological event. The first part of the care should be to ensure that he is stable from a cardiac and respiratory point of view."
        description_view.textColor = UIColor.gray
        history.text = "A 24-year-old man presents to an emergency department complaining of a severe headache. The headache started 24 h previously and has rapidly become more intense. He describes the headache as generalized in his head. He has vomited twice and appears to be developing drowsiness and confusion."
        history.textColor = UIColor.gray
        examination.text = "He looks flushed and unwell. His temperature is 39.2°C. He has stiffness on passive flexion of his neck. There is no rash. His sinuses are not tender and his eardrums appear normal. His pulse rate is 120/min and blood pressure 98/74 mmHg"
        examination.textColor = UIColor.gray
        speciality.text = "Allergy and Inmunology"
        speciality.textColor = UIColor.gray
        let disclosure = UITableViewCell()
        disclosure.frame = speciality.bounds
        disclosure.accessoryType = .disclosureIndicator
        disclosure.isUserInteractionEnabled = false
        disclosure.tintColor = UIColor.darkGray
        speciality.addSubview(disclosure)
        scrollview.contentLayoutGuide.bottomAnchor.constraint(equalTo: examination.bottomAnchor).isActive = true
        scrollview.backgroundColor = UIColor.white
        createPickerView()
        dismissPickerView()
    }
    
    func createPickerView() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.backgroundColor = UIColor.white
        pickerView.selectRow(specialities.count / 2, inComponent: 0, animated: false)
        speciality.inputView = pickerView
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
        speciality.inputAccessoryView = toolBar
    }
    
    @objc func action() {
        if selectedSpeciality == nil {
            selectedSpeciality = specialities[specialities.count / 2].name
            speciality.text = specialities[specialities.count / 2].name
        }
        speciality.textColor = UIColor.black
        view.endEditing(true)
    }
    
    @IBAction func didTapMenuButton(_ sender: Any) {
        swipeMenu()
    }
    
    @IBAction func savePost(_ sender: Any) {
        var error = ""
        if speciality.textColor == UIColor.gray {
            error += "Choose a speciality\n"
        }
        if titleview.textColor == UIColor.gray || titleview.text.isEmpty {
            error += "Write a title\n"
        }
        if description_view.textColor == UIColor.gray || description_view.text.isEmpty {
            error += "Write a description\n"
        }
        if history.textColor == UIColor.gray || history.text.isEmpty {
            error += "Write a history\n"
        }
        if examination.textColor == UIColor.gray || examination.text.isEmpty {
            error += "Write a history\n"
        }
        if error == "" {
            askPost()
        } else {
            showAlert(title: "Error", message: error)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.gray {
            textView.textColor = UIColor.black
            textView.text = ""
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 100
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
        speciality.text = selectedSpeciality
    }
    
    func askPost(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Do you want to finally share this?"
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            let user = uid
            let now = Date().description
            let path = "Cases/\(now)::\(uid!)"
            self.postCase(path: path, title: self.titleview.text!, description: self.description_view.text!, history: self.history.text!, examination: self.examination.text!, speciality:self.speciality.text!, user: user!, date: now)
            self.presentVC(segue: "MyCasesVC")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
