import UIKit
import FirebaseDatabase
import FirebaseAuth

class CreateDiscussionVC1: UIViewController, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var discussion_title: UITextView!
    @IBOutlet weak var speciality_box: UIView!
    @IBOutlet weak var speciality_textfield: UITextField!
    var selectedSpeciality: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMenu()
        setHeader(largeTitles: false)
        discussion_title.delegate = self
        discussion_title.setBorder()
        speciality_box.setBorder()
        discussion_title.customTextView(view_text:"Title",view_color:UIColor.gray, view_font: UIFont.boldSystemFont(ofSize: 20.0), view_scroll: true)
        speciality_textfield.text = specialities[specialities.count / 2].name
        speciality_textfield.textColor = UIColor.gray
        createPickerView()
        dismissPickerView()
    }
    
    @IBAction func saveDiscussion(_ sender: Any) {
        var error = ""
        if (discussion_title.textColor == UIColor.gray || discussion_title.text.isEmpty) {
            error += "Write a title\n"
        }
        if (speciality_textfield.textColor == UIColor.gray) {
            error += "Choose a speciality\n"
        }
        if (error == "") {
            let create_discussion_vc2 = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CreateDiscussionVC2") as? CreateDiscussionVC2
            create_discussion_vc2!.title_discussion = discussion_title.text!
            create_discussion_vc2!.speciality = speciality_textfield.text!
            navigationController?.pushViewController(create_discussion_vc2!, animated: false)
        } else {
            showAlert(title: "Error", message: error)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.gray {
            textView.customTextView(view_text:"",view_color:UIColor.black, view_font: UIFont.boldSystemFont(ofSize: 20.0), view_scroll: true)
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
        speciality_textfield.textColor = UIColor.black
        view.endEditing(true)
    }
}
