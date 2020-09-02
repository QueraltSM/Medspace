import UIKit
import WebKit

class DocumentViewerVC: UIViewController {

    var document: URL? = nil
    @IBOutlet weak var viewer: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.shadowImage = UIImage()
        viewer.backgroundColor = UIColor.clear
        viewer.load(URLRequest(url: document!))
    }
}
