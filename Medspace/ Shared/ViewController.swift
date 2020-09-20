import UIKit
import Firebase
import FirebaseAuth

var admin_menu : AdminMenuVC!
var doctor_menu: DoctorMenuVC!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if UserDefaults.standard.bool(forKey: "isUserLoggedIn") {
                self.presentVC(segue: "NewsVC")
            } else {
                self.presentVC(segue: "LoginVC")
            }
        }
    }
}

extension UITextField {
    func setBorderColor(color: UIColor) {
        self.layer.borderWidth = 1.5
        self.layer.borderColor = color.cgColor
        self.layer.cornerRadius = self.frame.size.height / 2.0
        self.layer.masksToBounds = true
    }
}

/*
 Thanks to this library for floating textField:
 https://github.com/hasnine/iOSUtilitiesSource
 */

enum placeholderDirection: String {
    case placeholderUp = "up"
    case placeholderDown = "down"
    
}
public class IuFloatingTextFiledPlaceHolder: UITextField {
    var enableMaterialPlaceHolder : Bool = true
    var placeholderAttributes = NSDictionary()
    var lblPlaceHolder = UILabel()
    var defaultFont = UIFont()
    var difference: CGFloat = 22.0
    var directionMaterial = placeholderDirection.placeholderUp
    var isUnderLineAvailabe : Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Initialize ()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Initialize ()
    }
    
    func setUnderline(color: UIColor) {
        let underLine = UIImageView()
        underLine.backgroundColor = color
        underLine.frame = CGRect(x: 0, y: self.frame.size.height-1, width : self.frame.size.width, height : 1)
        underLine.layer.cornerRadius = self.frame.size.height / 2.0
        underLine.clipsToBounds = true
        self.addSubview(underLine)
    }
    
    func Initialize(){
        self.clipsToBounds = false
        self.addTarget(self, action: #selector(IuFloatingTextFiledPlaceHolder.textFieldDidChange), for: .editingChanged)
        self.enableMaterialPlaceHolder(enableMaterialPlaceHolder: true)
        if isUnderLineAvailabe {
            setUnderline(color: UIColor.darkGray)
        }
        defaultFont = self.font!
        
    }
    @IBInspectable var placeHolderColor: UIColor? = UIColor.black {
        didSet {
            self.attributedPlaceholder = NSAttributedString(string: self.placeholder! as String ,
                                                            attributes:[NSAttributedString.Key.foregroundColor: placeHolderColor!])
        }
    }
    override public var placeholder:String?  {
        didSet {
            //  NSLog("placeholder = \(placeholder)")
        }
        willSet {
            let atts  = [NSAttributedString.Key.foregroundColor.rawValue: UIColor.black, NSAttributedString.Key.font: UIFont.labelFontSize] as! [NSAttributedString.Key : Any]
            self.attributedPlaceholder = NSAttributedString(string: newValue!, attributes:atts)
            self.enableMaterialPlaceHolder(enableMaterialPlaceHolder: self.enableMaterialPlaceHolder)
        }
        
    }
    override public var attributedText:NSAttributedString?  {
        didSet {
            //  NSLog("text = \(text)")
        }
        willSet {
            if (self.placeholder != nil) && (self.text != "")
            {
                let string = NSString(string : self.placeholder!)
                self.placeholderText(string)
            }
            
        }
    }
    @objc func textFieldDidChange(){
        if self.enableMaterialPlaceHolder {
            if (self.text == nil) || (self.text?.count)! > 0 {
                self.lblPlaceHolder.alpha = 1
                self.attributedPlaceholder = nil
                self.lblPlaceHolder.textColor = self.placeHolderColor
                self.lblPlaceHolder.frame.origin.x = 0 ////\\
                let fontSize = self.font!.pointSize;
                self.lblPlaceHolder.font = UIFont.init(name: (self.font?.fontName)!, size: fontSize-3)
            }
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {() -> Void in
                if (self.text == nil) || (self.text?.count)! <= 0 {
                    self.lblPlaceHolder.font = self.defaultFont
                    self.lblPlaceHolder.frame = CGRect(x: self.lblPlaceHolder.frame.origin.x+10, y : 0, width :self.frame.size.width, height : self.frame.size.height)
                }
                else {
                    if self.directionMaterial == placeholderDirection.placeholderUp {
                        self.lblPlaceHolder.frame = CGRect(x : self.lblPlaceHolder.frame.origin.x, y : -self.difference, width : self.frame.size.width, height : self.frame.size.height)
                    }else{
                        self.lblPlaceHolder.frame = CGRect(x : self.lblPlaceHolder.frame.origin.x, y : self.difference, width : self.frame.size.width, height : self.frame.size.height)
                    }
                    
                }
            }, completion: {(finished: Bool) -> Void in
            })
        }
    }
    func enableMaterialPlaceHolder(enableMaterialPlaceHolder: Bool){
        self.enableMaterialPlaceHolder = enableMaterialPlaceHolder
        self.lblPlaceHolder = UILabel()
        self.lblPlaceHolder.frame = CGRect(x: 0, y : 0, width : 0, height :self.frame.size.height)
        self.lblPlaceHolder.font = UIFont.systemFont(ofSize: 10)
        self.lblPlaceHolder.alpha = 0
        self.lblPlaceHolder.clipsToBounds = true
        self.addSubview(self.lblPlaceHolder)
        self.lblPlaceHolder.attributedText = self.attributedPlaceholder
        //self.lblPlaceHolder.sizeToFit()
    }
    func placeholderText(_ placeholder: NSString){
        let atts  = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.labelFontSize] as [NSAttributedString.Key : Any]
        self.attributedPlaceholder = NSAttributedString(string: placeholder as String , attributes:atts)
        self.enableMaterialPlaceHolder(enableMaterialPlaceHolder: self.enableMaterialPlaceHolder)
    }
    override public func becomeFirstResponder()->(Bool){
        let returnValue = super.becomeFirstResponder()
        return returnValue
    }
    override public func resignFirstResponder()->(Bool){
        let returnValue = super.resignFirstResponder()
        return returnValue
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
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
    
    func setMenu() {
        if (usertype! == "Admin") {
            admin_menu = self.storyboard?.instantiateViewController(withIdentifier: "AdminMenuVC") as? AdminMenuVC
        } else {
            doctor_menu = self.storyboard?.instantiateViewController(withIdentifier: "DoctorMenuVC") as? DoctorMenuVC
        }
    }
    
    func getMenuView() -> UIViewController {
        AppDelegate.menu_bool = false
        if (usertype! == "Admin") {
            return admin_menu
        }
        return doctor_menu
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
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: false)
    }
    
    func presentVC(segue: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: segue)
        let navigationController = UINavigationController(rootViewController: vc)
        self.present(navigationController, animated: false, completion: nil)
    }
    
    func postNewsDB(path: String, title: String, description: String, speciality: String, user: String, date: String) {
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
    
    func setHeader(largeTitles: Bool, gray: Bool){
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.prefersLargeTitles = largeTitles
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = UIColor.black
        var color = UIColor.white
        if gray {
            color = UIColor.init(hexString: "#f2f2f2")
        }
        navigationController?.navigationBar.barTintColor = color
        navigationController?.navigationBar.backgroundColor = color
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
    
    func presentUserProfileVC(user: User) {
        let profile_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC
        profile_vc!.user = user
        navigationController?.pushViewController(profile_vc!, animated: false)
    }
}

extension UITableView {
    func setEmptyView(title: String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
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
    
    func setBorder() {
        layer.borderColor = UIColor.lightGray.cgColor
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
