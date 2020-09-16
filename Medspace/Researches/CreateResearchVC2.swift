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
    @IBOutlet weak var scrollview: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setHeader(largeTitles: false, gray: false)
        scrollview.contentLayoutGuide.bottomAnchor.constraint(equalTo: research_description.bottomAnchor).isActive = true
        scrollview.backgroundColor = UIColor.init(hexString: "#f2f2f2")
        research_description.delegate = self
        ref = Database.database().reference()
        research_description.text = "In less than half a century, allergy, originally perceived as a rare disease, has become a major public health threat, today affecting the lives of more than 60 million people in Europe, and probably close to one billion worldwide, thereby heavily impacting the budgets of public health systems. More disturbingly, its prevalence and impact are on the rise, a development that has been associated with environmental and lifestyle changes accompanying the continuous process of urbanization and globalization. Therefore, there is an urgent need to prioritize and concert research efforts in the field of allergy, in order to achieve sustainable results on prevention, diagnosis and treatment of this most prevalent chronic disease of the 21st century."
        research_description.textColor = UIColor.gray
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.gray {
            textView.textColor = UIColor.black
            textView.text = ""
        }
    }
    
    
    @IBAction func askPost(_ sender: Any) {
        if research_description.textColor == UIColor.gray || research_description.text.isEmpty {
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
        let user = uid
        let now = Date().description
        let path = "Researches/\(now)::\(user!)"
        Storage.storage().reference().child(path).putFile(from: self.document_research!, metadata: nil) { metadata, error in
            self.stopAnimation()
            if error == nil {
                self.postResearch(path: path, title: self.title_research, description: self.research_description.text!, speciality: self.speciality, user: user!, date: now)
                self.presentVC(segue: "MyResearchesVC")
            } else {
                self.showAlert(title: "Error", message: error!.localizedDescription)
            }
        }
    }
}
