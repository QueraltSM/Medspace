import UIKit

class CollapsibleTableViewCell: UITableViewCell {
    
    let separator = UIView(frame: .zero)
    
    func configure(withViewModel viewModel: CollapsableViewModel) {
        self.textLabel?.text = viewModel.label
        self.imageView?.image = viewModel.image
        self.textLabel?.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
        backgroundColor = UIColor.clear
        if(viewModel.needsSeparator) {
            let viewSeparatorLine = UIView(frame:CGRect(x: 0, y: contentView.frame.size.height - 1.0, width: contentView.frame.size.width, height: 0.5))
            viewSeparatorLine.backgroundColor = UIColor.black
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
