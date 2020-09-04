import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class CreateResearchVC2: UIViewController, UITextViewDelegate {

    @IBOutlet weak var content: UIView!
    var title_research: String = ""
    var document_research: URL? = nil
    var speciality: String = ""
    @IBOutlet weak var research_description: UITextView!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        research_description.delegate = self
        navigationController?.navigationBar.shadowImage = UIImage()
        ref = Database.database().reference()
        research_description.customTextView(view_text:"Write a description of the research...",view_color:UIColor.gray, view_font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body), view_scroll: true)
    }
    
    func storeDocumentStorage(path: String) {
        self.setActivityIndicator()
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let ref = storageRef.child(path)
        ref.putFile(from: document_research!, metadata: nil) { metadata, error in
            self.stopAnimation()
            if error == nil {
                self.performSegue(withIdentifier: "MyResearchesVC", sender: nil)
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
        if (research_description.textColor == UIColor.gray || research_description.text.isEmpty) {
            showAlert(title: "Error in saving the research", message: "Write a description")
        } else {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            alert.title = "Do you want to post \(document_research!.lastPathComponent)?"
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
                action in
                self.postResearch()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
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
}
