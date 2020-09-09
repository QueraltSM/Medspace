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
        self.children.last?.needsSeparator = true
    }
}

class CollapsibleTableViewCell: UITableViewCell {
    let separator = UIView(frame: .zero)
    func configure(withViewModel viewModel: CollapsableViewModel) {
        self.textLabel?.text = viewModel.label
        self.imageView?.image = viewModel.image
        self.textLabel?.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
        backgroundColor = UIColor.clear
        layoutMargins = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
        if viewModel.children.count == 0 {
            accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        }
        if viewModel.needsSeparator {
            let viewSeparatorLine = UIView(frame:CGRect(x: 0, y: contentView.frame.size.height - 1.0, width: contentView.frame.size.width, height: 0.3))
            viewSeparatorLine.backgroundColor = UIColor.gray
            contentView.addSubview(viewSeparatorLine)
        } else {
            separator.removeFromSuperview()
        }
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
