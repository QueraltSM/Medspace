import UIKit
import FirebaseAuth
import FirebaseStorage

class CreateNewsVC2: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var description_news: UITextView!
    var title_news: String = ""
    var image_news: UIImage? = nil
    var speciality: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setHeader(largeTitles: false)
        description_news.delegate = self
        description_news.customTextView(view_text:"Write the description of the news...",view_color:UIColor.gray, view_font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body), view_scroll: true)
        setMenu()
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
            textView.customTextView(view_text:"Write the description of the news...",view_color:UIColor.gray, view_font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body), view_scroll: true)
        }
    }

    @IBAction func didTapMenuButton(_ sender: Any) {
        swipeMenu()
    }
    
    @IBAction func askPost(_ sender: Any) {
        if (description_news.textColor == UIColor.gray || description_news.text.isEmpty) {
            showAlert(title: "Error", message: "Write a description")
        } else {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            alert.title = "Do you want to post the news?"
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
                action in
                self.postNews()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func postNews() {
        self.startAnimation()
        let user = Auth.auth().currentUser?.uid
        let now = Date()
        let final_date = self.getFormattedDate(date: now.description)
        let path = "News/\(now)::\(user!)"
        guard let imageData: Data = image_news!.jpegData(compressionQuality: 0.1) else {
            return
        }
        let metaDataConfig = StorageMetadata()
        metaDataConfig.contentType = "image/jpg"
        let storageRef = Storage.storage().reference(withPath: path)
        storageRef.putData(imageData, metadata: metaDataConfig){ (metaData, error) in
            self.stopAnimation()
            if error == nil {
                self.postNewsDB(path: path, title: self.title_news, description: self.description_news.text!, speciality: self.speciality, user: user!, date: final_date)
                self.presentVC(segue: "MyNewsVC")
            } else {
                self.showAlert(title: "Error", message: error!.localizedDescription)
            }
        }
    }
}
