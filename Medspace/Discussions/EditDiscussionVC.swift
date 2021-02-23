import UIKit
import FirebaseDatabase
import FirebaseAuth

class EditDiscussionVC: UIViewController, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var speciality_textfield: UITextField!
    @IBOutlet weak var discussion_title: UITextView!
    @IBOutlet weak var discussion_description: UITextView!
    var selectedSpeciality: String?
    var discussion: Discussion?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
        customNavBar()
    }
    
    func initComponents(){
        discussion_title.delegate = self
        discussion_description.delegate = self
        speciality_textfield.delegate = self
        discussion_title.text = discussion!.title
        discussion_title.textColor = UIColor.darkGray
        discussion_description.text = discussion!.description
        discussion_description.textColor = UIColor.darkGray
        speciality_textfield.text = discussion!.speciality.name
        speciality_textfield.textColor = UIColor.darkGray
        let disclosure = UITableViewCell()
        disclosure.frame = speciality_textfield.bounds
        disclosure.accessoryType = .disclosureIndicator
        disclosure.isUserInteractionEnabled = false
        disclosure.tintColor = UIColor.darkGray
        speciality_textfield.addSubview(disclosure)
        if #available(iOS 11.0, *) {
            scrollview.contentLayoutGuide.bottomAnchor.constraint(equalTo: discussion_description.bottomAnchor).isActive = true
        } else {
            scrollview.bottomAnchor.constraint(equalTo: discussion_description.bottomAnchor).isActive = true
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
    
    @IBAction func saveDiscussion(_ sender: Any) {
        var error = ""
        if !validateTxtView(discussion_title) || !validateTxtView(discussion_description) {
            error = "Fill out all required fields\n"
        }
        if (speciality_textfield.text == discussion!.speciality.name && discussion_title.text == discussion!.title && discussion_description.text == discussion!.description) {
            error = "You have not modified the previous data"
        }
        if error == "" {
            askPost()
        } else {
            showAlert(title: "Error", message: error)
        }
    }
    
    func presentShowDiscussion() {
        var color = UIColor.init()
        for s in specialities {
            if s.name == self.speciality_textfield.text {
                color = s.color!
            }
        }
        let discussionUpdated = Discussion(id: self.discussion!.id, title: self.discussion_title.text, description: self.discussion_description.text, date: self.discussion!.date, speciality: Speciality(name: self.speciality_textfield.text!, color: color), user: self.discussion!.user)
        let show_discussion_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ShowDiscussionVC") as? ShowDiscussionVC
        show_discussion_vc!.discussion = discussionUpdated
        navigationController?.pushViewController(show_discussion_vc!, animated: false)
    }
    
    func askPost(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Do you want to update this?"
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            let path = "Discussions/\(uid!)/\(self.discussion!.id)"
            self.postDiscussion(path: path, title: self.discussion_title.text!, description: self.discussion_description.text!, speciality:self.speciality_textfield.text!, user: uid!, date: self.discussion!.date)
            self.presentShowDiscussion()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textView.textColor = UIColor.black
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.resignFirstResponder()
        return false
    }
    
    @IBAction func goBack(_ sender: Any) {
        let discussion_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ShowDiscussionVC") as? ShowDiscussionVC
        discussion_vc!.discussion = discussion
        self.navigationController?.pushViewController(discussion_vc!, animated: false)
    }
}
