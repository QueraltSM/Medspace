import UIKit
import FirebaseDatabase
import FirebaseAuth

class EditDiscussionVC1: UIViewController, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var discussion_title: UITextView!
    @IBOutlet weak var speciality_textfield: UITextField!
    @IBOutlet weak var speciality_box: UIView!
    var selectedSpeciality: String?
    var discussion: Discussion?
    var needsUpdate: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setHeader(largeTitles: false, gray: false)
        discussion_title.delegate = self
        speciality_box.setBorder()
        discussion_title.setBorder()
        speciality_textfield.text = discussion!.speciality.name
        speciality_textfield.textColor = UIColor.black
        discussion_title.customTextView(view_text:discussion!.title,view_color:UIColor.black, view_font: UIFont.boldSystemFont(ofSize: 20.0), view_scroll: true)
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
    
    @IBAction func saveDiscussion(_ sender: Any) {
        var error = ""
        if discussion_title.text.isEmpty {
            error += "Write a title\n"
        }
        if (error == "") {
            showEditDiscussionVC2()
        } else {
            showAlert(title: "Error saving the discussion", message: error)
        }
    }
    
    func showEditDiscussionVC2(){
        let edit_discussion_vc2 = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EditDiscussionVC2") as? EditDiscussionVC2
        var color = UIColor.init()
        for s in specialities {
            if s.name == speciality_textfield.text {
                color = s.color!
            }
        }
        if discussion!.title != discussion_title.text || discussion!.speciality.name != speciality_textfield.text {
            needsUpdate = true
        }
        let final_discussion = Discussion(id: discussion!.id, title: discussion_title.text, description: discussion!.description, date: discussion!.date, speciality: Speciality(name: speciality_textfield!.text!, color:color), user: User(id: discussion!.user.id, fullname:discussion!.user.fullname, username:discussion!.user.username))
        edit_discussion_vc2!.discussion = final_discussion
        edit_discussion_vc2?.needsUpdate = needsUpdate
        navigationController?.pushViewController(edit_discussion_vc2!, animated: false)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 100
    }
}
