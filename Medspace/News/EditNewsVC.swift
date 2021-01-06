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
        alert.addAction(UIAlertAction(title: "Photo Library", style: .cancel, handler: {
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
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
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
        self.startAnimation()
        guard let imageData: Data = self.image_header.image!.jpegData(compressionQuality: 0.1) else {
            return
        }
        let metaDataConfig = StorageMetadata()
        metaDataConfig.contentType = "image/jpg"
        let storageRef = Storage.storage().reference(withPath: "News/\(news!.id)")
        storageRef.putData(imageData, metadata: metaDataConfig){ (metaData, error) in
            self.stopAnimation()
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            } else {
                self.postNews(path: "News/\(self.news!.id)", title: self.titleview.text, description: self.descriptionview.text!, speciality: self.speciality_textfield.text!, user: self.news!.user.id, date: self.news!.date)
                self.presentShowNews()
            }
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        textView.textColor = UIColor.black
        return newText.count <= 250
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textView.textColor = UIColor.black
    }
}

extension EditNewsVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image_header.contentMode = .scaleAspectFill
            image_header.image = pickedImage
            image_header_invalid = false
            imageUpdated = true
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
