import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class EditResearchVC2: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var research_description: UITextView!
    var research: Research?
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = false
        research_description.delegate = self
        navigationController?.navigationBar.shadowImage = UIImage()
        ref = Database.database().reference()
        research_description.customTextView(view_text:research!.description,view_color:UIColor.gray, view_font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body), view_scroll: true)
    }
    
    func storeDocumentStorage(path: String) {
        self.setActivityIndicator()
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let ref = storageRef.child(path)
        ref.putFile(from: research!.pdf, metadata: nil) { metadata, error in
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
            textView.customTextView(view_text:research!.description,view_color:UIColor.gray, view_font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body), view_scroll: true)
        }
    }
    
    func postResearch() {
        let path = "Researches/\(research!.id)"
        self.ref.child("\(path)/title").setValue(research!.title)
        self.ref.child("\(path)/description").setValue(research_description.text!)
        self.ref.child("\(path)/speciality").setValue(research!.speciality.name)
        self.ref.child("\(path)/user").setValue(research!.user.id)
        self.ref.child("\(path)/date").setValue(research!.date)
        self.storeDocumentStorage(path: path)
    }
    
    @IBAction func askPost(_ sender: Any) {
        if (research_description.text.isEmpty) {
            showAlert(title: "Error in saving the research", message: "Write a description")
        } else {
            self.postResearch()
        }
    }
    
    
}
