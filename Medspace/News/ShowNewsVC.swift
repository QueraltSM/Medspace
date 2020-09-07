import UIKit
import FirebaseAuth

class ShowNewsVC: UIViewController {

    @IBOutlet weak var image_header: UIImageView!
    @IBOutlet weak var news_title: UILabel!
    @IBOutlet weak var speciality: UILabel!
    @IBOutlet weak var news_body: UILabel!
    @IBOutlet weak var news_date: UILabel!
    @IBOutlet weak var scrollview: UIScrollView!
    var news: News?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.shadowImage = UIImage()
        setMenu()
        image_header.image = news!.image
        news_title.text = news!.title
        news_body.text = news!.body
        news_date.text = news!.date
        speciality.text = news!.speciality.name.description
        speciality.backgroundColor = news!.speciality.color
        speciality.textColor = UIColor.white
        speciality.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
        speciality.round(corners: .allCorners, cornerRadius: 10)
        speciality.textAlignment = .center
        self.navigationController?.navigationBar.prefersLargeTitles = false
        if (news?.user.id == Auth.auth().currentUser?.uid) {
            setConfigDataToolbar()
        }
    }

    func setConfigDataToolbar() {
        self.navigationController?.isToolbarHidden = false
        var items = [UIBarButtonItem]()
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        items.append(UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deteleNews)))
        items.append(UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editNews)))
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        self.navigationController?.toolbar.barTintColor = UIColor.white
        self.toolbarItems = items
    }
    
    @objc func editNews() {
        let show_news_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EditNewsVC1") as? EditNewsVC1
        show_news_vc!.news = self.news
        navigationController?.pushViewController(show_news_vc!, animated: false)
    }
    
    @objc func deteleNews(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Are you sure you want delete it?"
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            let path = "News/\(self.news!.id)"
            self.removeDataDB(path: path)
            self.removeDataStorage(path: path)
            self.presentVC(segue: "HomeVC")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
