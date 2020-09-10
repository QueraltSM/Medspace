import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class EditNewsVC2: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var news_description: UITextView!
    var ref: DatabaseReference!
    var news: News?
    var needsUpdate: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setHeader(largeTitles: false)
        news_description.delegate = self
        news_description.text = news!.description
        news_description.textColor = UIColor.gray
        ref = Database.database().reference()
        news_description.customTextView(view_text:news!.description,view_color:UIColor.black, view_font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body), view_scroll: true)
        setMenu()
    }
    
    func postNews() {
        self.startAnimation()
        guard let imageData: Data = news?.image.jpegData(compressionQuality: 0.1) else {
            return
        }
        let metaDataConfig = StorageMetadata()
        metaDataConfig.contentType = "image/jpg"
        let storageRef = Storage.storage().reference(withPath: "News/\(news!.id)")
        storageRef.putData(imageData, metadata: metaDataConfig){ (metaData, error) in
            self.stopAnimation()
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            } else {
                self.postNewsDB(path: "News/\(self.news!.id)", title: self.news!.title, description: self.news_description.text!, speciality: self.news!.speciality.name, user: self.news!.user.id, date: self.news!.date)
                self.presentVC(segue: "MyNewsVC")
            }
        }
    }
    
    @IBAction func askPost(_ sender: Any) {
        var error = ""
        if news_description.text.isEmpty {
            error = "Write a description"
        }
        if news!.description == news_description.text && !needsUpdate! {
            error = "There is no data that needs to be updated"
        }
        if error == "" {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            alert.title = "Do you want to update the news?"
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
                action in
                self.postNews()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            showAlert(title: "Error", message: error)
        }
    }
}
