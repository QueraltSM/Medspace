//
//  Home2Cell.swift
//  Medspace
//
//  Created by Queralt Sosa Mompel on 27/8/20.
//  Copyright © 2020 Queralt Sosa Mompel. All rights reserved.
//

import UIKit

class HomeCell: UITableViewCell {
    @IBOutlet weak var image_header: UIImageView!
    @IBOutlet weak var labels_container: UIView!
    @IBOutlet weak var news_title: UITextView!
    @IBOutlet weak var news_date: UILabel!
    @IBOutlet weak var news_speciality: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        labels_container.round(corners: .allCorners, cornerRadius: 10)
        news_title.isEditable = false
        image_header.layer.borderWidth = 1
        image_header.layer.borderColor = UIColor.black.cgColor
        news_speciality.textColor = UIColor.white
        news_speciality.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
        news_speciality.round(corners: .allCorners, cornerRadius: 10)
        news_speciality.textAlignment = .center
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
