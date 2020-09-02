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
    @IBOutlet weak var news_title: UILabel!
    @IBOutlet weak var news_date: UILabel!
    @IBOutlet weak var news_speciality: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        //labels_container.round(corners: .allCorners, cornerRadius: 30)
        labels_container.layer.borderWidth = 0.5
        labels_container.layer.borderColor = UIColor.lightGray.cgColor
        news_speciality.textColor = UIColor.white
        news_speciality.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
        news_speciality.round(corners: .allCorners, cornerRadius: 10)
        news_speciality.textAlignment = .center
        news_title.numberOfLines = 0
        news_title.lineBreakMode = .byWordWrapping
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
