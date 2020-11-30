import UIKit
import WebKit

class DocumentViewerVC: UIViewController {

    var document: URL? = nil
    //@IBOutlet weak var viewer: WKWebView!
    //private var webView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let webview = WKWebView()
        webview.frame  = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            webview.load(URLRequest(url: document!))
            self.view.addSubview(webview)
        //viewer.backgroundColor = UIColor.clear
        //viewer.load(URLRequest(url: document!))
    }
}
