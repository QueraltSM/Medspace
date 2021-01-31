import UIKit
import FirebaseAuth

class ShowNewsVC: UIViewController {

    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var image_header: UIImageView!
    @IBOutlet weak var news_title: UILabel!
    @IBOutlet weak var news_description: UILabel!
    @IBOutlet weak var scrollview: UIScrollView!
    var news: News?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
        customNavBar()
    }
    
    func initComponents(){
        if #available(iOS 11.0, *) {
            scrollview.contentLayoutGuide.bottomAnchor.constraint(equalTo: news_description.bottomAnchor).isActive = true
        } else {
            scrollview.bottomAnchor.constraint(equalTo: news_description.bottomAnchor).isActive = true
        }
        image_header.image = news!.image
        news_title.text = news!.title
        news_description.text = news!.description
        if news!.user.id != uid {
            editButton.tintColor = UIColor.white
            deleteButton.tintColor =  UIColor.white
        }
        editButton.isEnabled = news!.user.id == uid
        deleteButton.isEnabled = news!.user.id == uid
    }

    @IBAction func editNews(_ sender: Any) {
        let edit_news_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EditNewsVC") as? EditNewsVC
        edit_news_vc!.news = self.news
        navigationController?.pushViewController(edit_news_vc!, animated: false)
    }
    
    @IBAction func deleteNews(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Do you want to delete this?"
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            let path = "News/\(uid!)/\(self.news!.id)"
            self.removeDataDB(path: path)
            self.removeDataDB(path: "Comments/\(path)")
            self.removeDataStorage(path: path)
            self.back()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func goBack(_ sender: Any) {
        back()
    }
    
    @IBAction func viewComments(_ sender: Any) {
        let comments_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CommentsVC") as? CommentsVC
        comments_vc!.news = news
        navigationController?.pushViewController(comments_vc!, animated: false)
    }
}
