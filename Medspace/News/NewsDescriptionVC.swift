//
//  NewsDescriptionVC.swift
//  Medspace
//
//  Created by Queralt Sosa Mompel on 24/8/20.
//  Copyright © 2020 Queralt Sosa Mompel. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class NewsDescriptionVC: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var body_news: UITextView!
    
    var title_news: String = ""
    var image_news: UIImage? = nil
    var speciality: String = ""
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        body_news.delegate = self
        ref = Database.database().reference()
        body_news.customTextView(view_text:"Write the body of the news...",view_color:UIColor.gray, view_font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body), view_scroll: true)
        setMenu()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.gray {
            textView.customTextView(view_text:"",view_color:UIColor.black, view_font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body), view_scroll: true)
        } else if (textView.textColor == UIColor.red) {
            textView.customTextView(view_text:"",view_color:UIColor.black, view_font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body), view_scroll: true)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.customTextView(view_text:"Write the body of the news...",view_color:UIColor.gray, view_font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body), view_scroll: true)
        }
    }
    
    @IBAction func didTapMenuButton(_ sender: Any) {
        if AppDelegate.menu_bool {
            openMenu()
        } else {
            closeMenu()
        }
    }
    
    func openMenu() {
        let menu_view = getMenuView()
        self.addChild(menu_view)
        self.view.addSubview(menu_view.view)
    }
    
    func setMenu() {
        if (usertype! == "Admin") {
            admin_menu = self.storyboard?.instantiateViewController(withIdentifier: "AdminMenuVC") as? AdminMenuVC
        } else {
            doctor_menu = self.storyboard?.instantiateViewController(withIdentifier: "DoctorMenuVC") as? DoctorMenuVC
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }

    func saveNewsDB(path: String, user: String, date: String) {
        self.ref.child("News/\(path)/title").setValue(title_news)
        self.ref.child("News/\(path)/body").setValue(body_news.text!)
        self.ref.child("News/\(path)/speciality").setValue(speciality)
        self.ref.child("News/\(path)/user").setValue(user)
        self.ref.child("News/\(path)/date").setValue(date)
    }
    
    @IBAction func askPost(_ sender: Any) {
        if (body_news.textColor == UIColor.black && !body_news.text.isEmpty) {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            alert.title = "Do you want to post the news?"
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
                action in
                self.postNews()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            body_news.customTextView(view_text:"Body can't be empty",view_color:UIColor.red, view_font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body), view_scroll: true)
            body_news.resignFirstResponder()
        }
    }
    
    func postNews() {
        let user = Auth.auth().currentUser?.uid
        let now = Date().description
        let path = now + "::" + user!
        guard let imageData: Data = image_news!.jpegData(compressionQuality: 0.1) else {
            return
        }
        let metaDataConfig = StorageMetadata()
        metaDataConfig.contentType = "image/jpg"
        let storageRef = Storage.storage().reference(withPath: path)
        storageRef.putData(imageData, metadata: metaDataConfig){ (metaData, error) in
            if let error = error {
                self.showAlert(title: "Could't publish the news", message: error.localizedDescription)
                return
            } else {
                self.saveNewsDB(path: path, user: user!, date: now)
                self.performSegue(withIdentifier: "HomeVC", sender: nil)
            }
        }
    }
}
