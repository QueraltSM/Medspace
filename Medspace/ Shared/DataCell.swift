import UIKit

class DataCell: UITableViewCell {

    @IBOutlet weak var data_view: UIView!
    @IBOutlet weak var data_title: UILabel!
    @IBOutlet weak var data_date: UILabel!
    @IBOutlet weak var data_speciality: UILabel!
    @IBOutlet weak var data_user: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        data_view.layer.borderWidth = 0.5
        //data_view.layer.borderColor = UIColor.lightGray.cgColor
        data_speciality.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
        data_speciality.round(corners: .allCorners, cornerRadius: 10)
        data_speciality.textAlignment = .center
        data_title.numberOfLines = 0
        data_title.lineBreakMode = .byWordWrapping
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
