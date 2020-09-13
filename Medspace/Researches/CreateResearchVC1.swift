import UIKit
import MobileCoreServices

class CreateResearchVC1: UIViewController, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIDocumentPickerDelegate,UINavigationControllerDelegate  {

    @IBOutlet weak var titleview: UITextView!
    @IBOutlet weak var speciality_box: UIView!
    @IBOutlet weak var speciality_textfield: UITextField!
    var selectedSpeciality: String?
    @IBOutlet weak var documentButton: UIButton!
    @IBOutlet weak var document_box: UIView!
    var documentURL: URL!
    var invalid_document: Bool!
    @IBOutlet weak var document_name: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMenu()
        setHeader(largeTitles: false, gray: false)
        invalid_document = true
        titleview.delegate = self
        speciality_textfield.delegate = self
        speciality_box.setBorder()
        document_box.setBorder()
        titleview.setBorder()
        titleview.customTextView(view_text:"Title",view_color:UIColor.gray, view_font: UIFont.boldSystemFont(ofSize: 20.0), view_scroll: true)
        speciality_textfield.text = specialities[specialities.count / 2].name
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
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let myURL = urls.first else {
            return
        }
        documentButton.titleLabel?.text = "Edit"
        documentURL = myURL
        document_name.text = myURL.lastPathComponent
        invalid_document = false
    }
    
    public func documentMenu(documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        invalid_document = true
        present(documentPicker, animated: false, completion: nil)
    }
    
    @IBAction func selectDocument(_ sender: Any) {
        let documentpicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF)], in: .import)
        documentpicker.delegate = self
        documentpicker.allowsMultipleSelection = false
        present(documentpicker, animated: true, completion: nil)
    }
    
    
    @objc func action() {
        speciality_textfield.textColor = UIColor.black
        view.endEditing(true)
    }
    
    @IBAction func savePost(_ sender: Any) {
        var error = ""
        if (titleview.textColor == UIColor.gray || titleview.text.isEmpty) {
            error += "Write a title\n"
        }
        if (speciality_textfield.textColor == UIColor.gray) {
            error += "Select a speciality\n"
        }
        if (invalid_document) {
            error += "Upload a document\n"
        }
        if (error == "" && titleview.textColor == UIColor.black && !titleview.text.isEmpty) {
            let create_research_vc2 = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CreateResearchVC2") as? CreateResearchVC2
            create_research_vc2!.title_research = titleview.text
            create_research_vc2!.document_research = documentURL
            create_research_vc2!.speciality = speciality_textfield.text!
            navigationController?.pushViewController(create_research_vc2!, animated: false)
        }
        if (error != "") {
            showAlert(title: "Error", message: error)
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
            textView.customTextView(view_text:"Title",view_color:UIColor.gray, view_font: UIFont.boldSystemFont(ofSize: 20.0), view_scroll: false)
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
