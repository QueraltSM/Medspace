import UIKit

class CollapsableViewModel {
    let label: String
    let image: UIImage?
    let children: [CollapsableViewModel]
    var isCollapsed: Bool
    var needsSeparator: Bool = true
    let segue: String?
    
    init(label: String, image: UIImage? = nil, children: [CollapsableViewModel] = [], isCollapsed: Bool = true, segue: String? = nil) {
        self.label = label
        self.image = image
        self.children = children
        self.isCollapsed = isCollapsed
        self.segue = segue
        for child in self.children {
            child.needsSeparator = false
        }
    }
}

class CollapsibleTableViewCell: UITableViewCell {
    let separator = UIView(frame: .zero)
    func configure(withViewModel viewModel: CollapsableViewModel) {
        self.imageView?.image = viewModel.image
        backgroundColor = UIColor.clear
        layoutMargins = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
        if viewModel.children.count == 0 {
            accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        }
        var attributs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .bold)]
        if !viewModel.needsSeparator {
            attributs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .regular)]
        }
        let option = NSMutableAttributedString(string: viewModel.label, attributes:attributs)
        self.textLabel?.attributedText = option
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let separatorHeight = 10 / UIScreen.main.scale
        separator.frame = CGRect(x: separatorInset.left,
                                 y: contentView.bounds.height - separatorHeight,
                                 width: contentView.bounds.width-separatorInset.left-separatorInset.right,
                                 height: separatorHeight)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
