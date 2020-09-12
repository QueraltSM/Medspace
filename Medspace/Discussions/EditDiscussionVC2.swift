import UIKit
import FirebaseDatabase
import FirebaseAuth

class EditDiscussionVC2: UIViewController, UITextViewDelegate {

    @IBOutlet weak var discussion_description: UITextView!
    var discussion: Discussion?
    var needsUpdate: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setHeader(largeTitles: false)
        discussion_description.delegate = self
        discussion_description.customTextView(view_text:discussion!.description,view_color:UIColor.black, view_font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body), view_scroll: true)
    }
    
    @IBAction func askPost(_ sender: Any) {
        var error = ""
        if discussion_description.text.isEmpty {
            error = "Write a description"
        }
        if discussion!.description == discussion_description.text && !needsUpdate! {
            error = "There is no data that needs to be updated"
        }
        if error == "" {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            alert.title = "Do you want to update the discussion?"
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
                action in
                self.postDiscussion()
                self.presentVC(segue: "MyDiscussionsVC")
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            showAlert(title: "Error", message: error)
        }
    }
    
    func postDiscussion() {
        let ref = Database.database().reference()
        let path = "Discussions/\(discussion!.id)"
        ref.child("\(path)/title").setValue(discussion!.title)
        ref.child("\(path)/description").setValue(discussion_description.text!)
        ref.child("\(path)/speciality").setValue(discussion!.speciality.name)
    }
}
