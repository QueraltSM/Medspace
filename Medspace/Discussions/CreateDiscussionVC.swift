import UIKit
import FirebaseAuth

class CreateDiscussionVC: UIViewController, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var discussion_title: UITextView!
    @IBOutlet weak var speciality_textfield: UITextField!
    var selectedSpeciality: String?
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var discussion_description: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMenu()
        setHeader(largeTitles: false, gray: true)
        discussion_title.delegate = self
        discussion_description.delegate = self
        discussion_title.text = "Anaphylaxis: Emergency treatment"
        discussion_title.textColor = UIColor.gray
        discussion_description.text = "Anaphylaxis is a potentially fatal disorder that is under-recognized and undertreated. This may partly be due to failure to appreciate that anaphylaxis is a much broader syndrome than 'anaphylactic shock' and the goal of therapy should be early recognition and treatment with epinephrine to prevent progression to life-threatening respiratory and/or cardiovascular symptoms and signs, including shock."
        discussion_description.textColor = UIColor.gray
        speciality_textfield.text = "Allergy and Inmunology"
        speciality_textfield.textColor = UIColor.gray
        let disclosure = UITableViewCell()
        disclosure.frame = speciality_textfield.bounds
        disclosure.accessoryType = .disclosureIndicator
        disclosure.isUserInteractionEnabled = false
        disclosure.tintColor = UIColor.darkGray
        speciality_textfield.addSubview(disclosure)
        scrollview.contentLayoutGuide.bottomAnchor.constraint(equalTo: discussion_description.bottomAnchor).isActive = true
        scrollview.backgroundColor = UIColor.init(hexString: "#f2f2f2")
        createPickerView()
        dismissPickerView()
    }
    
    @IBAction func saveDiscussion(_ sender: Any) {
        var error = ""
        if speciality_textfield.textColor == UIColor.gray {
            error += "Choose a speciality\n"
        }
        if discussion_title.textColor == UIColor.gray || discussion_title.text.isEmpty {
            error += "Write a title\n"
        }
        if discussion_description.textColor == UIColor.gray || discussion_description.text.isEmpty {
            error += "Write a description\n"
        }
        if error == "" {
            askPost()
        } else {
            showAlert(title: "Error", message: error)
        }
    }
    
    func askPost(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Do you want to post the discussion?"
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            let user = uid
            let now = Date().description
            let path = "Discussions/\(now)::\(uid!)"
            self.postDiscussion(path: path, title: self.discussion_title.text!, description: self.discussion_description.text!, speciality:self.speciality_textfield.text!, user: user!, date: now)
            self.presentVC(segue: "MyDiscussionsVC")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.gray {
            textView.textColor = UIColor.black
            textView.text = ""
        }
    }
    
    @IBAction func didTapMenu(_ sender: Any) {
        swipeMenu()
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
        return newText.count <= 100
    }
    
    @objc func action() {
        if selectedSpeciality == nil {
            selectedSpeciality = specialities[specialities.count / 2].name
            speciality_textfield.text = specialities[specialities.count / 2].name
        }
        speciality_textfield.textColor = UIColor.black
        view.endEditing(true)
    }
}
