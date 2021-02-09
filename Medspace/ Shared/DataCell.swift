import UIKit

class DataCell: UITableViewCell {

    @IBOutlet weak var data_view: UIView!
    @IBOutlet weak var data_title: UILabel!
    @IBOutlet weak var data_speciality: UILabel!
    @IBOutlet weak var data_user: UILabel!
    var speciality_color: UIColor?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        data_speciality.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
        data_speciality.round(corners: .allCorners, cornerRadius: 10)
        data_speciality.textColor = UIColor.black
        data_speciality.textAlignment = .center
        data_title.numberOfLines = 0
        data_title.lineBreakMode = .byWordWrapping
        data_user.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.footnote)
        selectedBackgroundView = {
            let view = UIView.init()
            view.backgroundColor = UIColor.clear
            return view
        }()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        data_speciality.backgroundColor = speciality_color!
        data_view.backgroundColor = UIColor.init(hexString: "#f2f2f2")
        if selected {
            data_view.layer.borderColor = UIColor.init(hexString: "#C0392B").cgColor
            data_view.layer.borderWidth = 2
        } else {
            data_view.layer.borderWidth = 0.5
            data_view.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
}
