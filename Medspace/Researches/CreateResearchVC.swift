import UIKit

class CreateResearchVC: UIViewController, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var titleview: UITextView!
    @IBOutlet weak var speciality_box: UIView!
    @IBOutlet weak var image_header: UIImageView!
    @IBOutlet weak var speciality_textfield: UITextField!
    var image_header_invalid = true
    var selectedSpeciality: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.shadowImage = UIImage()
        setMenu()
        titleview.delegate = self
        speciality_textfield.delegate = self
        speciality_box.layer.borderColor = UIColor.lightGray.cgColor
        speciality_box.layer.borderWidth = 1.0
        titleview.layer.borderColor = UIColor.lightGray.cgColor
        titleview.layer.borderWidth = 1.0
        titleview.customTextView(view_text:"Write a title...",view_color:UIColor.gray, view_font: UIFont.boldSystemFont(ofSize: 20.0), view_scroll: true)
        speciality_textfield.text = specialities[specialities.count / 2].name
        speciality_textfield.textColor = UIColor.gray
        createPickerView()
        dismissPickerView()
    }
    
    @objc func action() {
        speciality_textfield.textColor = UIColor.black
        view.endEditing(true)
    }
    
    @IBAction func choosePhoto(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {
            action in
            picker.sourceType = .camera
            self.present(picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {
            action in
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)
        }))
        if (!image_header_invalid) {
            alert.addAction(UIAlertAction(title: "Remove Photo", style: .default, handler: {
                action in
                self.image_header.image = UIImage(named: "Medspace-Research.png")
                self.image_header_invalid = true
                alert.dismiss(animated: true, completion: nil)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func savePost(_ sender: Any) {
        var error = ""
        if (image_header_invalid) {
            error += "Choose a valid image\n"
        }
        if (titleview.textColor == UIColor.gray || titleview.text.isEmpty) {
            error += "Write a title\n"
        }
        if (speciality_textfield.textColor == UIColor.gray) {
            error += "Select a speciality"
        }
        if (error == "" && titleview.textColor == UIColor.black && !titleview.text.isEmpty) {
            let research_description_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ResearchDescriptionVC") as? ResearchDescriptionVC
            research_description_vc!.title_research = titleview.text
            research_description_vc!.image_research = image_header.image
            research_description_vc!.speciality = speciality_textfield.text!
            navigationController?.pushViewController(research_description_vc!, animated: false)
        }
        if (error != "") {
            showAlert(title: "Error in saving the research", message: error)
        }
    }
    
    @IBAction func didTapMenuButton(_ sender: Any) {
        swipeMenu()
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.gray {
            textView.customTextView(view_text:"",view_color:UIColor.black, view_font: UIFont.boldSystemFont(ofSize: 20.0), view_scroll: true)
        } 
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.customTextView(view_text:"Write a title...",view_color:UIColor.gray, view_font: UIFont.boldSystemFont(ofSize: 20.0), view_scroll: false)
        }
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
        return newText.count <= 80
    }
}

extension CreateResearchVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
