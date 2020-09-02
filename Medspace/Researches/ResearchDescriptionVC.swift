import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import MobileCoreServices

class ResearchDescriptionVC: UIViewController, UITextViewDelegate, UIDocumentMenuDelegate,UIDocumentPickerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var content: UIView!
    var title_research: String = ""
    var image_research: UIImage? = nil
    var speciality: String = ""
    var documentURL: URL!
     var invalid_document: Bool!
    @IBOutlet weak var research_description: UITextView!
    @IBOutlet weak var upload_button: UIButton!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        invalid_document = true
        upload_button.round(corners: .allCorners, cornerRadius: Double(upload_button.frame.height / 2.0))
        research_description.delegate = self
        navigationController?.navigationBar.shadowImage = UIImage()
        ref = Database.database().reference()
        research_description.customTextView(view_text:"Write a description of the research...",view_color:UIColor.gray, view_font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body), view_scroll: true)
        setMenu()
        upload_button.titleLabel?.textAlignment = .center
        if (!invalid_document) {
            upload_button.setTitle("Edit document", for: .normal)
        } else {
            upload_button.setTitle("Upload document", for: .normal)
        }
    }
    
    @IBAction func didTapMenuButton(_ sender: Any) {
        swipeMenu()
    }
    
    @IBAction func uploadDocument(_ sender: Any) {
        let documentpicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF)], in: .import)
        documentpicker.delegate = self
        documentpicker.allowsMultipleSelection = false
        present(documentpicker, animated: true, completion: nil)
    }
    
    func storeDocumentStorage(path: String) {
        self.setActivityIndicator()
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let ref = storageRef.child(path)
        ref.putFile(from: documentURL, metadata: nil) { metadata, error in
            self.stopAnimation()
            if error == nil {
                self.performSegue(withIdentifier: "ResearchesVC", sender: nil)
            } else {
                self.showAlert(title: "Could't publish the research", message: (error?.localizedDescription)!)
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.gray {
            textView.customTextView(view_text:"",view_color:UIColor.black, view_font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body), view_scroll: true)
        } else if (textView.textColor == UIColor.red) {
            textView.customTextView(view_text:"",view_color:UIColor.black, view_font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body), view_scroll: true)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.customTextView(view_text:"Write a description of the research...",view_color:UIColor.gray, view_font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body), view_scroll: true)
        }
    }
    
    @IBAction func askPost(_ sender: Any) {
        var error = ""
        if (research_description.textColor == UIColor.gray || research_description.text.isEmpty) {
            error += "Write a description\n"
        }
        if (invalid_document) {
            error += "Upload a document"
        }
        if (error == "" && research_description.textColor == UIColor.black && !research_description.text.isEmpty) {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            alert.title = "Do you want to post \(documentURL.lastPathComponent)?"
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
                action in
                self.postResearch()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        if (error != "") {
            showAlert(title: "Error in saving the research", message: error)
        }
    }
    
    func postResearch() {
        self.setActivityIndicator()
        let user = Auth.auth().currentUser?.uid
        let now = Date().description
        let path = "Researches/\(now)::\(user!)"
        self.ref.child("\(path)/title").setValue(title_research)
        self.ref.child("\(path)/description").setValue(research_description.text!)
        self.ref.child("\(path)/speciality").setValue(speciality)
        self.ref.child("\(path)/user").setValue(user)
        self.ref.child("\(path)/date").setValue(now)
        self.storeDocumentStorage(path: path)
    }

    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let myURL = urls.first else {
            return
        }
        upload_button.titleLabel?.text = "Edit document"
        documentURL = myURL
        invalid_document = false
    }
    
    public func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        invalid_document = true
        present(documentPicker, animated: false, completion: nil)
    }
}
