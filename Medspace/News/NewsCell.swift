import UIKit

class NewsCell: UITableViewCell {
    @IBOutlet weak var image_header: UIImageView!
    @IBOutlet weak var labels_container: UIView!
    @IBOutlet weak var news_title: UILabel!
    @IBOutlet weak var news_date: UILabel!
    @IBOutlet weak var news_speciality: UILabel!
    var speciality_color: UIColor?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        news_speciality.textColor = UIColor.black
        news_speciality.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        news_speciality.round(corners: .allCorners, cornerRadius: 10)
        news_speciality.textAlignment = .center
        news_date.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
        news_title.numberOfLines = 0
        news_title.lineBreakMode = .byWordWrapping
        selectedBackgroundView = {
            let view = UIView.init()
            view.backgroundColor = UIColor.clear
            return view
        }()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        news_speciality.backgroundColor = speciality_color!
        labels_container.backgroundColor = UIColor.init(hexString: "#f2f2f2")
        if selected {
            labels_container.layer.borderColor = UIColor.init(hexString: "#2a9df4").cgColor
            labels_container.layer.borderWidth = 2
        } else {
            labels_container.layer.borderWidth = 0.5
            labels_container.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
}
