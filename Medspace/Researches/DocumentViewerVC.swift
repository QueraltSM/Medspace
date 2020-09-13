import UIKit
import WebKit

class DocumentViewerVC: UIViewController {

    var document: URL? = nil
    @IBOutlet weak var viewer: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("HOLIP=\(document!.absoluteString)")
        setHeader(largeTitles: false, gray: false)
        viewer.backgroundColor = UIColor.clear
        viewer.load(URLRequest(url: document!))
    }
}
