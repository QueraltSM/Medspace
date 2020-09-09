import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class EditResearchVC2: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var research_description: UITextView!
    var research: Research?
    var file_is_updated: Bool?
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
        Storage.storage().reference().child(path).putFile(from: research!.pdf, metadata: nil) { metadata, error in
            self.stopAnimation()
            if error != nil {
                self.showAlert(title: "Could't upload the research paper", message: (error?.localizedDescription)!)
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
        if (file_is_updated!) {
            self.storeDocumentStorage(path: path)
        }
        self.ref.child("\(path)/title").setValue(research!.title)
        self.ref.child("\(path)/description").setValue(research_description.text!)
        self.ref.child("\(path)/speciality").setValue(research!.speciality.name)
        presentVC(segue: "MyResearchesVC")
    }
    
    @IBAction func askPost(_ sender: Any) {
        if (research_description.text.isEmpty) {
            showAlert(title: "Error in saving the research", message: "Write a description")
        } else {
            self.postResearch()
        }
    }
}
