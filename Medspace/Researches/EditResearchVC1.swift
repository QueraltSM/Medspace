import UIKit
import MobileCoreServices

class EditResearchVC1: UIViewController, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIDocumentPickerDelegate,UINavigationControllerDelegate  {

    @IBOutlet weak var document_box: UIView!
    @IBOutlet weak var speciality_box: UIView!
    @IBOutlet weak var speciality_textfield: UITextField!
    @IBOutlet weak var research_title: UITextView!
    @IBOutlet weak var documentButton: UIButton!
    var invalid_document: Bool = false
    var research: Research?
    var documentURL: URL!
    var selectedSpeciality: String?
    var file_is_updated = false
    var needsUpdate: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setHeader(largeTitles: false, gray: false)
        documentURL = research!.pdf
        setMenu()
        research_title.delegate = self
        speciality_textfield.delegate = self
        speciality_textfield.text = research!.speciality.name
        speciality_box.setBorder()
        document_box.setBorder()
        research_title.setBorder()
        research_title.customTextView(view_text:research!.title,view_color:UIColor.black, view_font: UIFont.boldSystemFont(ofSize: 20.0), view_scroll: true)
        speciality_textfield.textColor = UIColor.black
        documentButton.titleLabel?.textAlignment = .center
        if (!invalid_document) {
            documentButton.setTitle("Edit", for: .normal)
        } else {
            documentButton.setTitle("Add", for: .normal)
        }
        createPickerView()
        dismissPickerView()
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
        file_is_updated = true
    }
    
    public func documentMenu(didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        invalid_document = true
        documentButton.titleLabel?.text = "Add"
        present(documentPicker, animated: false, completion: nil)
    }
    
    @objc func action() {
        if selectedSpeciality == nil {
            selectedSpeciality = specialities[specialities.count / 2].name
            speciality_textfield.text = specialities[specialities.count / 2].name
        }
        speciality_textfield.textColor = UIColor.black
        view.endEditing(true)
    }
    
    @IBAction func selectDocument(_ sender: Any) {
        let documentpicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF)], in: .import)
        documentpicker.delegate = self
        documentpicker.allowsMultipleSelection = false
        present(documentpicker, animated: true, completion: nil)
    }
    
    func showEditResearchesVC2(){
        let edit_research_vc2 = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EditResearchVC2") as? EditResearchVC2
        var color = UIColor.init()
        for s in specialities {
            if s.name == speciality_textfield.text {
                color = s.color!
            }
        }
        if file_is_updated || research!.title != research_title.text || research!.speciality.name != speciality_textfield.text {
            needsUpdate = true
        }
        let final_research = Research(id: research!.id, pdf: documentURL, date: research!.date, title: research_title.text, speciality: Speciality(name: speciality_textfield!.text!, color:color), description: research!.description, user: User(id: research!.user.id, fullname: research!.user.fullname, username:research!.user.username))
        edit_research_vc2!.research = final_research
        edit_research_vc2?.file_is_updated = file_is_updated
        edit_research_vc2?.needsUpdate = needsUpdate
        navigationController?.pushViewController(edit_research_vc2!, animated: false)
    }
    
    @IBAction func nextDescription(_ sender: Any) {
        var error = ""
        if research_title.text.isEmpty {
            error += "Write a title\n"
        }
        if invalid_document {
            error += "Upload a document\n"
        }
        if error == "" {
            showEditResearchesVC2()
        } else {
            showAlert(title: "Error", message: error)
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
        return newText.count <= 100
    }
}
