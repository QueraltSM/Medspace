//
//  CollapsibleTableViewCell.swift
//  Medspace
//
//  Created by Queralt Sosa Mompel on 21/8/20.
//  Copyright © 2020 Queralt Sosa Mompel. All rights reserved.
//

import UIKit

class CollapsibleTableViewCell: UITableViewCell {
    
    let separator = UIView(frame: .zero)
    
    func configure(withViewModel viewModel: CollapsableViewModel) {
        self.textLabel?.text = viewModel.label
        self.imageView?.image = viewModel.image
        backgroundColor = UIColor.clear
        if(viewModel.needsSeparator) {
            let viewSeparatorLine = UIView(frame:CGRect(x: 0, y: contentView.frame.size.height - 1.0, width: contentView.frame.size.width, height: 1))
            viewSeparatorLine.backgroundColor = UIColor.lightGray
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
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
