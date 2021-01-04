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
        initComponents()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
        target: self,action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func initComponents() {
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
        speciality.text = "Nuclear Medicine"
        speciality.textColor = UIColor.gray
        let disclosure = UITableViewCell()
        disclosure.frame = speciality.bounds
        disclosure.accessoryType = .disclosureIndicator
        disclosure.isUserInteractionEnabled = false
        disclosure.tintColor = UIColor.darkGray
        speciality.addSubview(disclosure)
        if #available(iOS 11.0, *) {
            scrollview.contentLayoutGuide.bottomAnchor.constraint(equalTo: examination.bottomAnchor).isActive = true
        } else {
            scrollview.bottomAnchor.constraint(equalTo: examination.bottomAnchor).isActive = true
        }
        scrollview.backgroundColor = UIColor.white
        createPickerView()
        dismissPickerView()
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
        view.frame.origin.y = 0
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if let scrollView = scrollview, let userInfo = notification.userInfo, let endValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey], let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey], let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] {
                       let endRect = view.convert((endValue as AnyObject).cgRectValue, from: view.window)
                       let keyboardOverlap = scrollView.frame.maxY - endRect.origin.y
                       scrollView.contentInset.bottom = keyboardOverlap
                       scrollView.scrollIndicatorInsets.bottom = keyboardOverlap
                       
                       let duration = (durationValue as AnyObject).doubleValue
                       let options = UIView.AnimationOptions(rawValue: UInt((curveValue as AnyObject).integerValue << 16))
                       UIView.animate(withDuration: duration!, delay: 0, options: options, animations: {
                           self.view.layoutIfNeeded()
                       }, completion: nil)
                   }
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        dismissKeyboard()
        textView.resignFirstResponder()
        return true
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
        if titleview.textColor == UIColor.gray || !validate(titleview) {
            error += "Write a title\n"
        }
        if description_view.textColor == UIColor.gray || !validate(description_view) {
            error += "Write a description\n"
        }
        if history.textColor == UIColor.gray || !validate(history) {
            error += "Write a history\n"
        }
        if examination.textColor == UIColor.gray || !validate(examination) {
            error += "Write a examination"
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
        alert.title = "Do you want to share this?"
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            let user = uid
            let now = Date().description
            let path = "Cases/\(uid!)/\(now)"
            self.postCase(path: path, title: self.titleview.text!, description: self.description_view.text!, history: self.history.text!, examination: self.examination.text!, speciality:self.speciality.text!, user: user!, date: now)
            self.presentVC(segue: "MyCasesVC")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
