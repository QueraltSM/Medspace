import UIKit
import MobileCoreServices
import FirebaseStorage

class EditResearchVC: UIViewController, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIDocumentPickerDelegate,UINavigationControllerDelegate  {

    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var speciality_textfield: UITextField!
    @IBOutlet weak var research_title: UITextView!
    @IBOutlet weak var research_description: UITextView!
    @IBOutlet weak var research_document: UILabel!
    @IBOutlet weak var documentButton: UIButton!
    var invalid_document: Bool = false
    var research: Research?
    var documentURL: URL!
    var selectedSpeciality: String?
    var file_is_updated = false
    var needsUpdate: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        research_title.delegate = self
        research_description.delegate = self
        research_title.text = research!.title
        research_description.text = research!.description
        research_title.textColor = UIColor.black
        research_description.textColor = UIColor.black
        speciality_textfield.text = research!.speciality.name
        speciality_textfield.textColor = UIColor.black
        let disclosure = UITableViewCell()
        disclosure.frame = speciality_textfield.bounds
        disclosure.accessoryType = .disclosureIndicator
        disclosure.isUserInteractionEnabled = false
        disclosure.tintColor = UIColor.darkGray
        speciality_textfield.addSubview(disclosure)
        scrollview.contentLayoutGuide.bottomAnchor.constraint(equalTo: research_document.bottomAnchor).isActive = true
        scrollview.backgroundColor = UIColor.white
        research_document.text = "Press + to upload new document"
        createPickerView()
        dismissPickerView()
        documentURL = research!.pdf
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
    
    @IBAction func viewDocument(_ sender: Any) {
        let document_viewer_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DocumentViewerVC") as? DocumentViewerVC
        document_viewer_vc!.document = documentURL
        navigationController?.pushViewController(document_viewer_vc!, animated: false)
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let myURL = urls.first else {
            return
        }
        documentURL = myURL
        research_document.text = documentURL.lastPathComponent
        invalid_document = false
        file_is_updated = true
    }
    
    public func documentMenu(didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        invalid_document = true
        research_document.text = "No document has been selected"
        present(documentPicker, animated: false, completion: nil)
    }
    
    
    @IBAction func selectDocument(_ sender: Any) {
        let documentpicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF)], in: .import)
        documentpicker.delegate = self
        documentpicker.allowsMultipleSelection = false
        present(documentpicker, animated: true, completion: nil)
    }
    
    @IBAction func addDocument(_ sender: Any) {
        let documentpicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF)], in: .import)
        documentpicker.delegate = self
        documentpicker.allowsMultipleSelection = false
        present(documentpicker, animated: true, completion: nil)
    }
    
    @IBAction func nextDescription(_ sender: Any) {
        var error = ""
        if research_title.text.isEmpty {
            error += "Write a title\n"
        }
        if research_description.text.isEmpty {
            error += "Write a description\n"
        }
        if invalid_document {
            error += "Upload a document\n"
        }
        if (speciality_textfield.text == research!.speciality.name && research_title.text == research!.title && research_description.text == research!.description && research!.pdf.lastPathComponent == documentURL.lastPathComponent) {
            error = "You have not modified the previous data"
        }
        if error == "" {
            askPost()
        } else {
            showAlert(title: "Error", message: error)
        }
    }
    
    func savePDF() {
        self.startAnimation()
        let user = uid
        let now = Date().description
        let path = "Researches/\(now)::\(user!)"
        Storage.storage().reference().child(path).putFile(from: self.documentURL!, metadata: nil) { metadata, error in
            self.stopAnimation()
            if error == nil {
                self.presentVC(segue: "MyResearchesVC")
            } else {
                self.showAlert(title: "Error", message: error!.localizedDescription)
            }
        }
    }
    
    func askPost(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Do you want to update the research?"
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            let user = uid
            let now = self.research!.date
            let path = "Researches/\(now)::\(uid!)"
            self.postResearch(path: path, title: self.research_title.text!, description: self.research_description.text!, speciality:self.speciality_textfield.text!, user: user!, date: now)
            self.savePDF()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 100
    }
}
