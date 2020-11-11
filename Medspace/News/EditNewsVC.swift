import UIKit

class EditNewsVC: UIViewController, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var image_header: UIImageView!
    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var speciality_label: UILabel!
    @IBOutlet weak var titleview: UITextView!
    @IBOutlet weak var speciality_textfield: UITextField!
    var image_header_invalid = false
    var selectedSpeciality: String?
    var news: News?
    var needsUpdate: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMenu()
        scrollview.contentLayoutGuide.bottomAnchor.constraint(equalTo: speciality_textfield.bottomAnchor).isActive = true
        scrollview.backgroundColor = UIColor.white
        titleview.delegate = self
        speciality_textfield.delegate = self
        speciality_textfield.textColor = UIColor.black
        speciality_textfield.text = news!.speciality.name
        titleview.text = news!.title
        titleview.textColor = UIColor.black
        image_header.image = news!.image
        let disclosure = UITableViewCell()
        disclosure.frame = speciality_textfield.bounds
        disclosure.accessoryType = .disclosureIndicator
        disclosure.isUserInteractionEnabled = false
        disclosure.tintColor = UIColor.darkGray
        speciality_textfield.addSubview(disclosure)
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
    
    @IBAction func choosePhoto(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {
            action in
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)
        }))
        if (!image_header_invalid) {
            alert.addAction(UIAlertAction(title: "Remove Photo", style: .default, handler: {
                action in
                self.image_header.image = UIImage(named: "Medspace-News.png")
                self.image_header_invalid = true
                alert.dismiss(animated: true, completion: nil)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
    
    @IBAction func showDescription(_ sender: Any) {
        var error = ""
        if (image_header_invalid) {
            error += "Choose a valid image\n"
        }
        if (titleview.text.isEmpty) {
            error += "Write a title\n"
        }
        if (error == "" && !titleview.text.isEmpty) {
            showEditNewsVC2()
        } else {
            showAlert(title: "Error", message: error)
        }
    }
    
    func showEditNewsVC2(){
        let edit_news_vc2 = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EditNewsVC2") as? EditNewsVC2
        var color = UIColor.init()
        for s in specialities {
            if s.name == speciality_textfield.text! {
                color = s.color!
            }
        }
        if (news!.image != image_header.image || news!.title != titleview.text || news!.speciality.name != speciality_textfield.text) {
            needsUpdate = true
        }
        let final_news = News(id: news!.id, image: image_header.image!, date: news!.date, title: titleview.text!, speciality: Speciality(name: speciality_textfield.text!, color: color), description: news!.description, user: news!.user)
        edit_news_vc2!.news = final_news
        edit_news_vc2!.needsUpdate = needsUpdate
        navigationController?.pushViewController(edit_news_vc2!, animated: false)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 100
    }
    
}

extension EditNewsVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image_header.contentMode = .scaleToFill
            image_header.image = pickedImage
            image_header_invalid = false
        }
        dismiss(animated: false, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        dismiss(animated: false, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: false, completion: nil)
    }
}
