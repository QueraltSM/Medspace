import UIKit
import MobileCoreServices

class EditResearchVC1: UIViewController, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIDocumentMenuDelegate,UIDocumentPickerDelegate,UINavigationControllerDelegate  {

    @IBOutlet weak var document_box: UIView!
    @IBOutlet weak var speciality_box: UIView!
    @IBOutlet weak var speciality_textfield: UITextField!
    @IBOutlet weak var research_title: UITextView!
    @IBOutlet weak var documentButton: UIButton!
    var invalid_document: Bool!
    var research: Research?
    var documentURL: URL!
    var selectedSpeciality: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.shadowImage = UIImage()
        documentURL = research!.pdf
        setMenu()
        invalid_document = false
        research_title.delegate = self
        speciality_textfield.delegate = self
        speciality_textfield.text = research!.speciality.name
        speciality_box.setBorder()
        document_box.setBorder()
        research_title.setBorder()
        research_title.customTextView(view_text:research!.title,view_color:UIColor.gray, view_font: UIFont.boldSystemFont(ofSize: 20.0), view_scroll: true)
        speciality_textfield.textColor = UIColor.gray
        createPickerView()
        dismissPickerView()
        documentButton.titleLabel?.textAlignment = .center
        if (!invalid_document) {
            documentButton.setTitle("Edit", for: .normal)
        } else {
            documentButton.setTitle("Add", for: .normal)
        }
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
        documentButton.titleLabel?.text = "Edit"
        documentURL = myURL
        invalid_document = false
    }
    
    public func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        invalid_document = true
        present(documentPicker, animated: false, completion: nil)
    }
    
    @objc func action() {
        speciality_textfield.textColor = UIColor.black
        view.endEditing(true)
    }
    
    @IBAction func selectDocument(_ sender: Any) {
        let documentpicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF)], in: .import)
        documentpicker.delegate = self
        documentpicker.allowsMultipleSelection = false
        present(documentpicker, animated: true, completion: nil)
    }
    
    @IBAction func nextDescription(_ sender: Any) {
        var error = ""
        if (research_title.text.isEmpty) {
            error += "Write a title\n"
        }
        if (invalid_document) {
            error += "Upload a document\n"
        }
        if (error == "") {
            let research_description_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EditResearchVC2") as? EditResearchVC2
            var color = UIColor.init()
            for s in specialities {
                if s.name == speciality_textfield.text {
                    color = s.color!
                }
            }
            let final_research = Research(id: research!.id, pdf: documentURL, date: research!.date, title: research_title.text, speciality: Speciality(name: speciality_textfield!.text!, color:color), description: research!.description, user: User(id: research!.user.id, name:research!.user.name))
            research_description_vc!.research = final_research
            navigationController?.pushViewController(research_description_vc!, animated: false)
        }
        if (error != "") {
            showAlert(title: "Error in saving the research", message: error)
        }
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
