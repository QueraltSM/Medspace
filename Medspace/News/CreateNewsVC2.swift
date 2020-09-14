import UIKit
import FirebaseAuth
import FirebaseStorage

class CreateNewsVC2: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var description_news: UITextView!
    var title_news: String = ""
    var image_news: UIImage? = nil
    var speciality: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setHeader(largeTitles: false, gray: true)
        description_news.delegate = self
        scrollview.contentLayoutGuide.bottomAnchor.constraint(equalTo: description_news.bottomAnchor).isActive = true
        description_news.text = "An antibody test for the virus that causes COVID-19, developed by researchers at The University of Texas at Austin in collaboration with Houston Methodist and other institutions, is more accurate and can handle a much larger number of donor samples at lower overall cost than standard antibody tests currently in use. In the near term, the test can be used to accurately identify the best donors for convalescent plasma therapy and measure how well candidate vaccines and other therapies elicit an immune response..."
        description_news.textColor = UIColor.gray
        setMenu()
        scrollview.backgroundColor = UIColor.init(hexString: "#f2f2f2")
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.gray {
            textView.text = ""
            textView.textColor = UIColor.black
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
        let user = uid
        let now = Date().description
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
                self.postNewsDB(path: path, title: self.title_news, description: self.description_news.text!, speciality: self.speciality, user: user!, date: now)
                self.presentVC(segue: "MyNewsVC")
            } else {
                self.showAlert(title: "Error", message: error!.localizedDescription)
            }
        }
    }
}
