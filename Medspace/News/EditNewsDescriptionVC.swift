import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class EditNewsDescriptionVC: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var news_body: UITextView!
    var ref: DatabaseReference!
    var news: News?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        news_body.delegate = self
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.prefersLargeTitles = false
        news_body.text = news?.body
        news_body.textColor = UIColor.gray
        ref = Database.database().reference()
        news_body.customTextView(view_text:(news?.body)!,view_color:UIColor.gray, view_font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body), view_scroll: true)
        setMenu()
    }
    
    func saveNewsDB() {
        self.ref.child("News/\(news!.id)/title").setValue(news?.title)
        self.ref.child("News/\(news!.id)/body").setValue(news_body.text!)
        self.ref.child("News/\(news!.id)/speciality").setValue(news?.speciality.name)
        self.ref.child("News/\(news!.id)/user").setValue(news?.user.id)
        self.ref.child("News/\(news!.id)/date").setValue(news?.date)
    }
    
    func postNews() {
        self.setActivityIndicator()
        guard let imageData: Data = news?.image.jpegData(compressionQuality: 0.1) else {
            return
        }
        let metaDataConfig = StorageMetadata()
        metaDataConfig.contentType = "image/jpg"
        let storageRef = Storage.storage().reference(withPath: "News/\(news!.id)")
        storageRef.putData(imageData, metadata: metaDataConfig){ (metaData, error) in
            self.stopAnimation()
            if let error = error {
                self.showAlert(title: "Could't saving the news", message: error.localizedDescription)
                return
            } else {
                self.saveNewsDB()
                self.performSegue(withIdentifier: "MyNewsVC", sender: nil)
            }
        }
    }
    
    @IBAction func askPost(_ sender: Any) {
        if (!news_body.text.isEmpty) {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            alert.title = "Do you want to save the news?"
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
                action in
                self.postNews()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            showAlert(title: "Error in editing the news", message: "Body can not be empty")
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.gray {
            textView.customTextView(view_text:"",view_color:UIColor.black, view_font: UIFont.boldSystemFont(ofSize: 20.0), view_scroll: true)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.customTextView(view_text:(news?.body)!,view_color:UIColor.gray, view_font: UIFont.boldSystemFont(ofSize: 20.0), view_scroll: false)
        }
    }
}
