import UIKit
import Firebase
import FirebaseAuth

var side_menu : SideMenuVC!
var uid: String!
var usertype: String!
var username: String!
var fullname: String!
let specialities = [
    Speciality(name: "Allergy and Inmunology", color: UIColor.init(hexString: "#daf0ff")), // blue
    Speciality(name: "Anesthesiology", color: UIColor.init(hexString: "#ff6961")), // red
    Speciality(name: "Dermatology", color: UIColor.init(hexString: "#339933")), // green
    Speciality(name: "Diagnostic Radiology", color: UIColor.init(hexString: "#8fd3fe")), // blue
    Speciality(name: "Emergency Medicine", color: UIColor.init(hexString: "#74B72E")),
    Speciality(name: "Family Medicine", color: UIColor.init(hexString: "#f98d8d")), // pink
    Speciality(name: "Internal Medicine", color: UIColor.init(hexString: "#6ac5fe")), // blue
    Speciality(name: "Medical Genetics", color: UIColor.init(hexString: "#ffffbf")), // yellow
    Speciality(name: "Neurology", color: UIColor.init(hexString: "#f8abba")), // pink
    Speciality(name: "Nuclear Medicine",  color: UIColor.init(hexString: "#66b366")), // green
    Speciality(name: "Opthalmology", color: UIColor.init(hexString: "#d8c7ff")), // violet
    Speciality(name: "Pathology", color: UIColor.init(hexString: "#efde7b")), // yellow
    Speciality(name: "Pediatrics", color: UIColor.init(hexString: "#f2b8c6")), // pink
    Speciality(name: "Preventive Medicine", color: UIColor.init(hexString: "#99cc99")), // green
    Speciality(name: "Radiation Oncology", color: UIColor.init(hexString: "#d1bea8")), // vainilla
    Speciality(name: "Psychiatry", color: UIColor.init(hexString: "#b3cfdd")), // blue
    Speciality(name: "Surgery", color: UIColor.init(hexString: "#fff4c6")), // yellow
    Speciality(name: "Urology", color: UIColor.init(hexString: "#b99aff"))] // violet

var refreshControl = UIRefreshControl()

class ViewController: UIViewController {
    var vc: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if UserDefaults.standard.bool(forKey: "isUserLoggedIn") {
                self.presentVC(segue: "NewsVC")
            } else {
                self.presentVC(segue: "LoginVC")
            }
        }
    }
}

extension UITextField {
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
    
    func setUnderline(color: UIColor) {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1.5)
        bottomLine.backgroundColor = color.cgColor
        borderStyle = .none
        layer.addSublayer(bottomLine)
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension UIViewController {
    
    func presentVC(segue: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: segue)
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: false, completion: nil)
    }
    
    func startAnimation() {
        let window = UIApplication.shared.keyWindow
        container.frame = UIScreen.main.bounds
        container.backgroundColor = UIColor(hue: 0/360, saturation: 0/100, brightness: 0/100, alpha: 0.5)
        let loadingView: UIView = UIView()
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = container.center
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 40
        spinningActivityIndicator.frame =  CGRect(x: 0, y: 0, width: 40, height: 40)
        spinningActivityIndicator.hidesWhenStopped = true
        spinningActivityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        spinningActivityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        loadingView.addSubview(spinningActivityIndicator)
        container.addSubview(loadingView)
        window!.addSubview(container)
        spinningActivityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func stopAnimation() {
        spinningActivityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        container.removeFromSuperview()
    }
    
    func getFormattedDate(date: String) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM d, HH:mm a"
        if let date = dateFormatterGet.date(from: date) {
            return dateFormatterPrint.string(from: date)
        }
        return ""
    }
    
    func customNavBar() {
        self.view.backgroundColor = UIColor.white
        self.view.tintColor = UIColor.white
        navigationController!.navigationBar.backgroundColor = UIColor.white
        navigationController!.navigationBar.barTintColor = UIColor.white
        UINavigationBar.appearance().shadowImage = UIImage()
    }
    
    func setMenu() {
        customNavBar()
        side_menu = storyboard!.instantiateViewController(withIdentifier: "SideMenuVC") as? SideMenuVC
    }
    
    func getMenuView() -> UIViewController {
        AppDelegate.menu_bool = false
        return side_menu
    }
    
    func closeMenu() {
        getMenuView().view.removeFromSuperview()
        AppDelegate.menu_bool = true
    }
    
    func openMenu() {
        let menu_view = getMenuView()
        self.addChild(menu_view)
        self.navigationController?.navigationBar.isTranslucent = false
        self.view.addSubview(menu_view.view)
        menu_view.view.backgroundColor = UIColor(hue: 0/360, saturation: 0/100, brightness: 0/100, alpha: 0.5)
    }
    
    @objc func swipeMenu() {
        if AppDelegate.menu_bool {
            openMenu()
        } else {
            closeMenu()
        }
    }
    
    func logout() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            setUserData(fullname: "", usertype: "", username: "", isUserLoggedIn: false)
        } catch let signOutError as NSError {
            showAlert(title: "Error signing out", message: signOutError.description)
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: false)
    }
    
    func validateTxtView(_ textView: UITextView) -> Bool {
        guard let text = textView.text,
            !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
            return false
        }
        if textView.textColor == UIColor.gray {
            return false
        }
        return true
    }
    
    func validateTxtfield(_ textField: UITextField) -> Bool {
        guard let text = textField.text,
            !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
            return false
        }
        if textField.textColor == UIColor.gray {
            return false
        }
        return true
    }
    
    func postNews(path: String, title: String, description: String, speciality: String, user: String, date: String) {
        let ref = Database.database().reference()
        ref.child("\(path)/title").setValue(title)
        ref.child("\(path)/description").setValue(description)
        ref.child("\(path)/speciality").setValue(speciality)
        ref.child("\(path)/user").setValue(user)
        ref.child("\(path)/date").setValue(date)
    }
    
    func postCase(path: String, title: String, description: String, history: String, examination: String, speciality: String, user: String, date: String) {
        let ref = Database.database().reference()
        ref.child("\(path)/title").setValue(title)
        ref.child("\(path)/description").setValue(description)
        ref.child("\(path)/history").setValue(history)
        ref.child("\(path)/examination").setValue(examination)
        ref.child("\(path)/speciality").setValue(speciality)
        ref.child("\(path)/user").setValue(user)
        ref.child("\(path)/date").setValue(date)
    }
    
    func postDiscussion(path: String, title: String, description: String, speciality: String, user: String, date: String) {
        let ref = Database.database().reference()
        ref.child("\(path)/title").setValue(title)
        ref.child("\(path)/description").setValue(description)
        ref.child("\(path)/speciality").setValue(speciality)
        ref.child("\(path)/user").setValue(user)
        ref.child("\(path)/date").setValue(date)
    }
    
    func postResearch(path: String, title: String, description: String, speciality: String, user: String, date: String) {
        let ref = Database.database().reference()
        ref.child("\(path)/title").setValue(title)
        ref.child("\(path)/description").setValue(description)
        ref.child("\(path)/speciality").setValue(speciality)
        ref.child("\(path)/user").setValue(user)
        ref.child("\(path)/date").setValue(date)
    }
    
    func postComment(path: String, message: String, user: String, date: String) {
        let ref = Database.database().reference()
        ref.child("\(path)/message").setValue(message)
        ref.child("\(path)/user").setValue(user)
        ref.child("\(path)/date").setValue(date)
    }
    
    func removeDataDB(path: String) {
        Database.database().reference().child(path).removeValue { error, _ in
            if error != nil {
                self.showAlert(title: "Error", message: (error?.localizedDescription)!)
            }
        }
    }
    
    func removeDataStorage(path: String) {
        Storage.storage().reference().child(path).delete { error in
            if error != nil {
                self.showAlert(title: "Error", message: (error?.localizedDescription)!)
            }
        }
    }
    
    func setUserData(fullname: String, usertype: String, username: String, isUserLoggedIn: Bool) {
        UserDefaults.standard.set(usertype, forKey: "usertype")
        UserDefaults.standard.set(fullname, forKey: "fullname")
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(isUserLoggedIn, forKey: "isUserLoggedIn")
        var segue = "LoginVC"
        if isUserLoggedIn {
            segue = "NewsVC"
        }
        self.presentVC(segue: segue)
    }
}

extension UITableView {
    func setEmptyView(title: String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.textAlignment = .center
        emptyView.addSubview(titleLabel)
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        titleLabel.text = title
        self.backgroundView = emptyView
        self.separatorStyle = .none
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}

extension UITextView {
    func customTextView(view_text: String, view_color: UIColor, view_font: UIFont, view_scroll: Bool) {
        text = view_text
        textColor = view_color
        font = view_font
        isScrollEnabled = view_scroll
    }
}

extension UIView {
    func round(corners: UIRectCorner, cornerRadius: Double) {
        let size = CGSize(width: cornerRadius, height: cornerRadius)
        let bezierPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: size)
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = self.bounds
        shapeLayer.path = bezierPath.cgPath
        self.layer.mask = shapeLayer
    }
    
    enum ViewSide {
        case left, right, top, bottom
    }
    
    func addBorder(toSide side: ViewSide, withColor color: CGColor, andThickness thickness: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color
        switch side {
        case .left: border.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: thickness, height: self.frame.size.height)
        case .right: border.frame = CGRect(x: self.frame.size.width - thickness, y: self.frame.origin.y, width: thickness, height: self.frame.size.height)
        case .top: border.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: thickness)
        case .bottom: border.frame = CGRect(x: self.frame.origin.x, y: self.frame.size.height - thickness, width: self.frame.size.width, height: thickness)
        }
        self.layer.addSublayer(border)
    }
    
    func setBorder(color: UIColor) {
        layer.borderColor = color.cgColor
        layer.borderWidth = 1.0
    }
}

extension UIFont {
    func withTraits(traits:UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0) //size 0 means keep the size as it is
    }
    
    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }
    
    func italic() -> UIFont {
        return withTraits(traits: .traitItalic)
    }
}

extension UILabel {
    func setLabelBorders() {
        let lineViewTop = UIView(frame: CGRect(x: 0, y: -10, width: self.frame.width, height: 0.5))
        let lineViewBottom = UIView(frame: CGRect(x: 0, y: self.frame.height + 10, width: self.frame.width, height: 0.5))
        lineViewTop.backgroundColor = UIColor.lightGray
        lineViewBottom.backgroundColor = UIColor.lightGray
        self.addSubview(lineViewTop)
        self.addSubview(lineViewBottom)
    }
}
