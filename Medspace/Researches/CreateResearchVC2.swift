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
        setHeader(largeTitles: false)
        research_description.delegate = self
        navigationController?.navigationBar.shadowImage = UIImage()
        ref = Database.database().reference()
        research_description.customTextView(view_text:"Write a description of the research...",view_color:UIColor.gray, view_font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body), view_scroll: true)
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
            showAlert(title: "Error", message: "Write a description")
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
        self.startAnimation()
        let user = Auth.auth().currentUser?.uid
        let now = Date()
        let final_date = self.getFormattedDate(date: now.description)
        let path = "Researches/\(now)::\(user!)"
        Storage.storage().reference().child(path).putFile(from: self.document_research!, metadata: nil) { metadata, error in
            self.stopAnimation()
            if error == nil {
                self.postResearch(path: path, title: self.title_research, description: self.research_description.text!, speciality: self.speciality, user: user!, date: final_date)
                self.presentVC(segue: "MyResearchesVC")
            } else {
                self.showAlert(title: "Error", message: error!.localizedDescription)
            }
        }
    }
}
