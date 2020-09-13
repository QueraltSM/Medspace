import UIKit
import FirebaseAuth

class ShowNewsVC: UIViewController {

    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var image_header: UIImageView!
    @IBOutlet weak var news_title: UILabel!
    @IBOutlet weak var speciality: UILabel!
    @IBOutlet weak var news_description: UILabel!
    @IBOutlet weak var news_date: UILabel!
    @IBOutlet weak var scrollview: UIScrollView!
    var news: News?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMenu()
        setHeader(largeTitles: false, gray: false)
        scrollview.contentLayoutGuide.bottomAnchor.constraint(equalTo: news_description.bottomAnchor).isActive = true
        image_header.image = news!.image
        news_title.text = news!.title
        news_description.text = news!.description
        news_date.text = self.getFormattedDate(date: news!.date)
        speciality.text = news!.speciality.name.description
        speciality.backgroundColor = news!.speciality.color
        speciality.textColor = UIColor.black
        speciality.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
        speciality.round(corners: .allCorners, cornerRadius: 10)
        speciality.textAlignment = .center
        if (news?.user.id == Auth.auth().currentUser?.uid) {
            configNews(enabled: true)
        }
    }

    func configNews(enabled: Bool) {
        editButton.isEnabled = enabled
        deleteButton.isEnabled = enabled
        if enabled {
            editButton.title = "Edit"
            deleteButton.title = "Delete"
        }
    }
    
    @IBAction func editNews(_ sender: Any) {
        let edit_news_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EditNewsVC1") as? EditNewsVC1
        edit_news_vc!.news = self.news
        navigationController?.pushViewController(edit_news_vc!, animated: false)
    }
    
    @IBAction func deleteNews(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Are you sure you want delete it?"
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            let path = "News/\(self.news!.id)"
            self.removeDataDB(path: path)
            self.removeDataStorage(path: path)
            self.presentVC(segue: "MyNewsVC")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func viewComments(_ sender: Any) {
        print("view comments")
    }
}
