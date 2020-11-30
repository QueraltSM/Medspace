import UIKit
import FirebaseStorage

class CreateNewsVC: UIViewController, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var image_header: UIImageView!
    @IBOutlet weak var titleview: UITextView!
    @IBOutlet weak var news_description: UITextView!
    var image_header_invalid = true
    var selectedSpeciality: String?
    @IBOutlet weak var speciality_textfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMenu()
        if #available(iOS 11.0, *) {
            scrollview.contentLayoutGuide.bottomAnchor.constraint(equalTo: news_description.bottomAnchor).isActive = true
        } else {
            scrollview.bottomAnchor.constraint(equalTo: news_description.bottomAnchor).isActive = true
        }
        scrollview.backgroundColor = UIColor.white
        titleview.delegate = self
        news_description.delegate = self
        speciality_textfield.delegate = self
        titleview.textColor = UIColor.gray
        news_description.textColor = UIColor.gray
        titleview.text = "For example: Researchers develop highly scalable, accurate antibody test for covid-19"
        news_description.text = "The UT Austin research team, led by Jason Lavinder, a research associate in the Cockrell School of Engineering, and Greg Ippolito, assistant professor in the College of Natural Sciences and Dell Medical School, developed the new antibody test for SARS-CoV-2 and provided the viral antigens for this study via their UT Austin colleague and collaborator, associate professor Jason McLellan."
        scrollview.backgroundColor = UIColor.white
        speciality_textfield.textColor = UIColor.gray
        speciality_textfield.text = "Allergy and Inmunology"
        let disclosure = UITableViewCell()
        disclosure.frame = speciality_textfield.bounds
        disclosure.accessoryType = .disclosureIndicator
        disclosure.isUserInteractionEnabled = false
        disclosure.tintColor = UIColor.darkGray
        speciality_textfield.addSubview(disclosure)
        createPickerView()
        dismissPickerView()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.gray {
            textView.text = ""
            textView.textColor = UIColor.black
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
    
    @IBAction func choosePhoto(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
        }
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {
            action in
            picker.sourceType = .photoLibrary
            picker.modalPresentationStyle = .currentContext
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 100
    }
    
    @IBAction func savePost(_ sender: Any) {
        var error = ""
        if image_header_invalid {
            error += "Choose a valid image\n"
        }
        if speciality_textfield.textColor == UIColor.gray {
            error += "Select a speciality\n"
        }
        if titleview.textColor == UIColor.gray || titleview.text.isEmpty {
            error += "Write a title\n"
        }
        if news_description.textColor == UIColor.gray || news_description.text.isEmpty {
            error += "Write a description\n"
        }
        if error == "" {
            askPost()
        } else {
            showAlert(title: "Error", message: error)
        }
    }
    
    func saveNews(){
        self.startAnimation()
        let user = uid
        let now = Date().description
        let path = "News/\(now)::\(uid!)"
        guard let imageData: Data = image_header.image!.jpegData(compressionQuality: 0.1) else {
            return
        }
        let metaDataConfig = StorageMetadata()
        metaDataConfig.contentType = "image/jpg"
        let storageRef = Storage.storage().reference(withPath: path)
        storageRef.putData(imageData, metadata: metaDataConfig){ (metaData, error) in
            self.stopAnimation()
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            } else {
                self.postNews(path: path, title: self.titleview.text!, description: self.news_description.text!, speciality: self.speciality_textfield.text!, user: user!, date: now)
                self.presentVC(segue: "MyNewsVC")
            }
        }
    }
    
    func askPost() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Do you want to share this?"
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            self.saveNews()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func didTapMenuButton(_ sender: Any) {
        swipeMenu()
    }
}

extension CreateNewsVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image_header.contentMode = .scaleToFill
            image_header.image = pickedImage
            image_header_invalid = false
            image_header.isHidden = false
            image_header.heightAnchor.constraint(equalToConstant: CGFloat(241)).isActive = true
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
