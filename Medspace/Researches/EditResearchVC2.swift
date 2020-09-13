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
    var needsUpdate: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setHeader(largeTitles: false, gray: false)
        research_description.delegate = self
        ref = Database.database().reference()
        research_description.customTextView(view_text:research!.description,view_color:UIColor.black, view_font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body), view_scroll: true)
    }
    
    func storeDocumentStorage(path: String) {
        self.startAnimation()
        Storage.storage().reference().child(path).putFile(from: research!.pdf, metadata: nil) { metadata, error in
            self.stopAnimation()
            if error != nil {
                self.showAlert(title: "Error", message: (error?.localizedDescription)!)
            }
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
        var error = ""
        if research_description.text.isEmpty {
            error = "Write a description"
        }
        if research!.description == research_description.text && !needsUpdate! {
            error = "There is no data that needs to be updated"
        }
        if error == "" {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            alert.title = "Do you want to update the research?"
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
                action in
                self.postResearch()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            showAlert(title: "Error", message: error)
        }
    }
}
