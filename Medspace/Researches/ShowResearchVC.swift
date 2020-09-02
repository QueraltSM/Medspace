import UIKit

class ShowResearchVC: UIViewController {

    @IBOutlet weak var speciality: UILabel!
    @IBOutlet weak var research_title: UILabel!
    @IBOutlet weak var research_date: UILabel!
    @IBOutlet weak var research_description: UILabel!
    var research: Research?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.shadowImage = UIImage()
        setMenu()
        research_title.text = research!.title
        research_description.text = research!.description
        research_date.text = research!.date
        speciality.text = research!.speciality.name.description
        speciality.backgroundColor = research!.speciality.color
        speciality.textColor = UIColor.white
        speciality.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
        speciality.round(corners: .allCorners, cornerRadius: 10)
        speciality.textAlignment = .center
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    
    @IBAction func viewDocument(_ sender: Any) {
        let document_viewer_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DocumentViewerVC") as? DocumentViewerVC
        document_viewer_vc!.document = research!.pdf
        navigationController?.pushViewController(document_viewer_vc!, animated: false)
    }
    
    @IBAction func didTapMenuButton(_ sender: Any) {
        swipeMenu()
    }
    
    
}
