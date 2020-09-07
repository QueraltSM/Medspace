import UIKit
import FirebaseDatabase
import FirebaseAuth

class EditDiscussionVC: UIViewController, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var discussion_title: UITextView!
    @IBOutlet weak var discussion_description: UITextView!
    @IBOutlet weak var speciality_box: UIView!
    @IBOutlet weak var speciality_textfield: UITextField!
    var selectedSpeciality: String?
    var discussion: Discussion?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideToolbar()
        setHeader(largeTitles: false)
        discussion_title.delegate = self
        discussion_description.delegate = self
        speciality_box.setBorder()
        discussion_title.setBorder()
        discussion_description.setBorder()
        speciality_textfield.text = discussion!.speciality.name
        speciality_textfield.textColor = UIColor.gray
        discussion_title.customTextView(view_text:discussion!.title,view_color:UIColor.gray, view_font: UIFont.boldSystemFont(ofSize: 20.0), view_scroll: true)
        discussion_description.customTextView(view_text:discussion!.description,view_color:UIColor.gray, view_font: UIFont.boldSystemFont(ofSize: 20.0), view_scroll: true)
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.gray {
            textView.customTextView(view_text:"",view_color:UIColor.black, view_font: UIFont.boldSystemFont(ofSize: 20.0), view_scroll: true)
        }
    }
    
    func postDiscussion() {
        let ref = Database.database().reference()
        let path = "Discussions/\(discussion!.id)"
        ref.child("\(path)/title").setValue(discussion_title.text!)
        ref.child("\(path)/description").setValue(discussion_description.text!)
        ref.child("\(path)/speciality").setValue(speciality_textfield.text!)
        ref.child("\(path)/user").setValue(discussion!.user.id)
        ref.child("\(path)/date").setValue(discussion!.date)
    }
    
    @IBAction func saveDiscussion(_ sender: Any) {
        var error = ""
        if discussion_title.text.isEmpty {
            error += "Write a title\n"
        }
        if discussion_description.text.isEmpty {
            error += "Write a description"
        }
        if (error == "") {
            postDiscussion()
            presentVC(segue: "MyDiscussionsVC")
        } else {
            showAlert(title: "Error saving the discussion", message: error)
        }
    }
    
    
}
