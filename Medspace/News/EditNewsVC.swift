import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

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
    var imageUpdated: Bool = false
    @IBOutlet weak var descriptionview: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
        customNavBar()
    }
    
    func initComponents(){
        if #available(iOS 11.0, *) {
            scrollview.contentLayoutGuide.bottomAnchor.constraint(equalTo: descriptionview.bottomAnchor).isActive = true
        } else {
            scrollview.bottomAnchor.constraint(equalTo: descriptionview.bottomAnchor).isActive = true
        }
        scrollview.backgroundColor = UIColor.white
        titleview.delegate = self
        descriptionview.delegate = self
        speciality_textfield.delegate = self
        speciality_textfield.textColor = UIColor.gray
        descriptionview.textColor = UIColor.gray
        speciality_textfield.text = news!.speciality.name
        descriptionview.text = news!.description
        titleview.text = news!.title
        titleview.textColor = UIColor.gray
        image_header.image = news!.image
        image_header.contentMode = .scaleToFill
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
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
        }
        alert.addAction(UIAlertAction(title: "Import photo", style: .default, handler: {
            action in
            picker.sourceType = .photoLibrary
            picker.modalPresentationStyle = .fullScreen
            self.present(picker, animated: true, completion: nil)
        }))
        if (!image_header_invalid) {
            alert.addAction(UIAlertAction(title: "Remove Photo", style: .destructive, handler: {
                action in
                self.image_header.image = UIImage(named: "Medspace-News.png")
                self.image_header_invalid = true
                self.image_header.heightAnchor.constraint(equalToConstant: CGFloat(241)).isActive = true
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
    
    func shareNews() {
        self.postNews(path: "News/\(uid!)/\(self.news!.id)", title: self.titleview.text, description: self.descriptionview.text!, speciality: self.speciality_textfield.text!, user: self.news!.user.id, date: self.news!.date)
        if imageUpdated {
            self.startAnimation()
            guard let imageData: Data = self.image_header.image!.jpegData(compressionQuality: 0.1) else {
                return
            }
            let metaDataConfig = StorageMetadata()
            metaDataConfig.contentType = "image/jpg"
            let storageRef = Storage.storage().reference(withPath: "News/\(uid!)/\(news!.id)")
            storageRef.putData(imageData, metadata: metaDataConfig){ (metaData, error) in
                self.stopAnimation()
                if let error = error {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                    return
                } else {
                    self.presentShowNews()
                }
            }
        } else {
            self.presentShowNews()
        }
    }
    
    func presentShowNews() {
        var color = UIColor.init()
        for s in specialities {
            if s.name == self.speciality_textfield.text {
                color = s.color!
            }
        }
        let newsUpdated = News(id: self.news!.id, image: self.image_header.image!, date: self.news!.date, title: self.titleview.text, speciality: Speciality(name: self.speciality_textfield.text!, color: color), description: self.descriptionview.text, user: self.news!.user)
        
        let show_news_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ShowNewsVC") as? ShowNewsVC
        show_news_vc!.news = newsUpdated
        navigationController?.pushViewController(show_news_vc!, animated: false)
    }
    
    @IBAction func saveNews(_ sender: Any) {
        var error = ""
        if (image_header_invalid) {
            error += "Choose a valid image\n"
        }
        if (titleview.text.isEmpty) {
            error += "Write a title\n"
        }
        if (descriptionview.text.isEmpty) {
            error += "Write a description\n"
        }
        if (!imageUpdated && titleview.text == news!.title && descriptionview.text == news!.description) {
            error = "You have not modified the previous data"
        }
        if (error == "") {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            alert.title = "Do you want to update this?"
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
                action in
                self.shareNews()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            showAlert(title: "Error", message: error)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textView.textColor = UIColor.black
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.resignFirstResponder()
        return false
    }
    
    @IBAction func goBack(_ sender: Any) {
        let news_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ShowNewsVC") as? ShowNewsVC
        news_vc!.news = news
        self.navigationController?.pushViewController(news_vc!, animated: false)
    }
}

extension EditNewsVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image_header.contentMode = .scaleToFill
            image_header.image = pickedImage
            image_header_invalid = false
            imageUpdated = true
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
