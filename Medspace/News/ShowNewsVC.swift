//
//  ShowNewsVC.swift
//  Medspace
//
//  Created by Queralt Sosa Mompel on 29/8/20.
//  Copyright © 2020 Queralt Sosa Mompel. All rights reserved.
//

import UIKit

class ShowNewsVC: UIViewController {

    @IBOutlet weak var image_header: UIImageView!
    @IBOutlet weak var news_title: UILabel!
    @IBOutlet weak var speciality: UILabel!
    @IBOutlet weak var news_body: UILabel!
    @IBOutlet weak var news_date: UILabel!
    @IBOutlet weak var scrollview: UIScrollView!
    
    var news: News?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMenu()
        image_header.image = news!.image
        news_title.text = news!.title
        news_body.text = news!.body
        news_date.text = news!.date
        speciality.text = news!.speciality.name.description
        speciality.backgroundColor = news!.speciality.color
        speciality.textColor = UIColor.white
        speciality.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
        speciality.round(corners: .allCorners, cornerRadius: 10)
        speciality.textAlignment = .center
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
    }
    
    @IBAction func didTapMenu(_ sender: Any) {
        swipeMenu()
    }

}
