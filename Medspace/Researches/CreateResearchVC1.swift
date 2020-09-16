import UIKit
import MobileCoreServices

class CreateResearchVC1: UIViewController, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIDocumentPickerDelegate,UINavigationControllerDelegate  {
    
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var titleview: UITextView!
    @IBOutlet weak var speciality_textfield: UITextField!
    var selectedSpeciality: String?
    @IBOutlet weak var documentButton: UIButton!
    @IBOutlet weak var document_box: UIView!
    var documentURL: URL!
    @IBOutlet weak var document_name: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMenu()
        setHeader(largeTitles: false, gray: true)
        documentURL = nil
        scrollview.contentLayoutGuide.bottomAnchor.constraint(equalTo: document_box.bottomAnchor).isActive = true
        scrollview.backgroundColor = UIColor.init(hexString: "#f2f2f2")
        titleview.delegate = self
        speciality_textfield.delegate = self
        document_box.setBorder()
        titleview.textColor = UIColor.gray
        titleview.text = "Research needs in allergy: an EAACI position paper, in collaboration with EFA"
        speciality_textfield.text = "Allergy and Inmunology"
        speciality_textfield.textColor = UIColor.gray
        let disclosure = UITableViewCell()
        disclosure.frame = speciality_textfield.bounds
        disclosure.accessoryType = .disclosureIndicator
        disclosure.isUserInteractionEnabled = false
        disclosure.tintColor = UIColor.darkGray
        speciality_textfield.addSubview(disclosure)
        createPickerView()
        dismissPickerView()
        documentButton.titleLabel?.textAlignment = .center
        if (documentURL != nil) {
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
    }
    
    public func documentMenu(documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        documentURL = nil
        present(documentPicker, animated: false, completion: nil)
    }
    
    @IBAction func selectDocument(_ sender: Any) {
        let documentpicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF)], in: .import)
        documentpicker.delegate = self
        documentpicker.allowsMultipleSelection = false
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
        if titleview.textColor == UIColor.gray || titleview.text.isEmpty {
            error += "Write a title\n"
        }
        if speciality_textfield.textColor == UIColor.gray {
            error += "Select a speciality\n"
        }
        if documentURL == nil {
            error += "Upload a document\n"
        }
        if error == "" {
            let create_research_vc2 = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CreateResearchVC2") as? CreateResearchVC2
            create_research_vc2!.title_research = titleview.text
            create_research_vc2!.document_research = documentURL
            create_research_vc2!.speciality = speciality_textfield.text!
            navigationController?.pushViewController(create_research_vc2!, animated: false)
        } else {
            showAlert(title: "Error", message: error)
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
