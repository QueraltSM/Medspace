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
        if #available(iOS 11.0, *) {
            scrollview.contentLayoutGuide.bottomAnchor.constraint(equalTo: news_description.bottomAnchor).isActive = true
        } else {
            scrollview.bottomAnchor.constraint(equalTo: news_description.bottomAnchor).isActive = true
        }
        image_header.image = news!.image
        news_title.text = news!.title
        news_description.text = news!.description
        configNews(enabled: news!.user.id == uid)
    }

    func configNews(enabled: Bool) {
        print("Enabled=> \(enabled)")
        editButton.isEnabled = enabled
        deleteButton.isEnabled = enabled
        if enabled {
            editButton.title = "Edit"
            deleteButton.title = "Delete"
        }
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
            let path = "News/\(self.news!.id)"
            self.removeDataDB(path: path)
            self.removeDataDB(path: "Comments/\(path)")
            self.removeDataStorage(path: path)
            self.presentVC(segue: "MyNewsVC")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func goBack(_ sender: Any) {
        let newsVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "NewsVC") as? NewsVC
        navigationController?.pushViewController(newsVC!, animated: false)
    }
    
    @IBAction func viewComments(_ sender: Any) {
        let comments_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CommentsVC") as? CommentsVC
        comments_vc!.news = news
        navigationController?.pushViewController(comments_vc!, animated: false)
    }
}
