import UIKit
import MobileCoreServices
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class CreateResearchVC: UIViewController, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIDocumentPickerDelegate,UINavigationControllerDelegate  {
    
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var titleview: UITextView!
    @IBOutlet weak var speciality_textfield: UITextField!
    var selectedSpeciality: String?
    var documentURL: URL!
    @IBOutlet weak var document_name: UILabel!
    @IBOutlet weak var research_description: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMenu()
        documentURL = nil
        if #available(iOS 11.0, *) {
            scrollview.contentLayoutGuide.bottomAnchor.constraint(equalTo: document_name.bottomAnchor).isActive = true
        } else {
            scrollview.bottomAnchor.constraint(equalTo: document_name.bottomAnchor).isActive = true
        }
        scrollview.backgroundColor = UIColor.white
        titleview.delegate = self
        research_description.delegate = self
        speciality_textfield.delegate = self
        titleview.textColor = UIColor.gray
        titleview.text = "Research needs in allergy: an EAACI position paper, in collaboration with EFA"
        speciality_textfield.text = "Allergy and Inmunology"
        speciality_textfield.textColor = UIColor.gray
        research_description.text = "In less than half a century, allergy, originally perceived as a rare disease, has become a major public health threat, today affecting the lives of more than 60 million people in Europe, and probably close to one billion worldwide, thereby heavily impacting the budgets of public health systems."
        research_description.textColor = UIColor.gray
        document_name.textColor = UIColor.gray
        scrollview.backgroundColor = UIColor.white
        let disclosure = UITableViewCell()
        disclosure.frame = speciality_textfield.bounds
        disclosure.accessoryType = .disclosureIndicator
        disclosure.isUserInteractionEnabled = false
        disclosure.tintColor = UIColor.darkGray
        speciality_textfield.addSubview(disclosure)
        createPickerView()
        dismissPickerView()
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let myURL = urls.first else {
            return
        }
        documentURL = myURL
        document_name.text = myURL.lastPathComponent
        document_name.textColor = UIColor.black
    }
    
    public func documentMenu(documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        documentURL = nil
        present(documentPicker, animated: false, completion: nil)
    }
    
    @IBAction func selectDocument(_ sender: Any) {
        let documentpicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF)], in: .import)
        documentpicker.delegate = self
        if #available(iOS 11.0, *) {
            documentpicker.allowsMultipleSelection = false
        }
        present(documentpicker, animated: true, completion: nil)
    }
    
    @objc func action() {
        if selectedSpeciality == nil {
            selectedSpeciality = specialities[specialities.count / 2].name
            speciality_textfield.text = specialities[specialities.count / 2].name
        }
        speciality_textfield.textColor = UIColor.black
        view.endEditing(true)
    }
    
    @IBAction func savePost(_ sender: Any) {
        var error = ""
        if documentURL == nil {
            error += "Upload a document\n"
        }
        if speciality_textfield.textColor == UIColor.gray {
            error += "Select a speciality\n"
        }
        if titleview.textColor == UIColor.gray || titleview.text.isEmpty {
            error += "Write a title\n"
        }
        if research_description.textColor == UIColor.gray || research_description.text.isEmpty {
            error += "Write a description\n"
        }
        if error == "" {
            askPost();
        } else {
            showAlert(title: "Error", message: error)
        }
    }
    
    func askPost() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Do you want to post \(documentURL!.lastPathComponent)?"
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            self.postResearch()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func postResearch() {
        self.startAnimation()
        let user = uid
        let now = Date().description
        let path = "Researches/\(now)::\(user!)"
        Storage.storage().reference().child(path).putFile(from: self.documentURL!, metadata: nil) { metadata, error in
            self.stopAnimation()
            if error == nil {
                self.postResearch(path: path, title: self.titleview.text!, description: self.research_description.text!, speciality: self.speciality_textfield.text!, user: user!, date: now)
                let vc: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyResearchesVC") as! MyResearchesVC
                self.present(vc, animated: false, completion: nil)
            } else {
                self.showAlert(title: "Error", message: error!.localizedDescription)
            }
        }
    }
    
    @IBAction func didTapMenuButton(_ sender: Any) {
        swipeMenu()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.gray {
            textView.textColor = UIColor.black
            textView.text = ""
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
        print("ENTROOOO")
        selectedSpeciality = specialities[row].name
        speciality_textfield.text = selectedSpeciality
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 100
    }
}
