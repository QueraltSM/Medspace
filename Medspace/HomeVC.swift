//
//  HomeVC.swift
//  Medspace
//
//  Created by Queralt Sosa Mompel on 20/8/20.
//  Copyright © 2020 Queralt Sosa Mompel. All rights reserved.
//

import UIKit

var admin_menu : AdminMenuVC!
var doctor_menu: DoctorMenuVC!
var usertype: String!
var username: String!

class HomeVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usertype = UserDefaults.standard.string(forKey: "usertype")
        username = UserDefaults.standard.string(forKey: "fullname")
        setMenu()
    }
    
    func openMenu() {
        if (usertype! == "Admin") {
            self.addChild(admin_menu)
            self.view.addSubview(admin_menu.view)
        } else {
            self.addChild(doctor_menu)
            self.view.addSubview(doctor_menu.view)
        }
        AppDelegate.menu_bool = false
    }
    
    @IBAction func didTapMenuButton(_ sender: Any) {
        if AppDelegate.menu_bool {
            openMenu()
        } else {
            closeMenu()
        }
    }
    
    @objc func respondToGesture(gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case UISwipeGestureRecognizer.Direction.right:
            AppDelegate.menu_bool = false
            openMenu()
        case UISwipeGestureRecognizer.Direction.left:
            close_on_swipe()
        default:
            break
        }
    }
    
    func setMenu() {
        if (usertype! == "Admin") {
            admin_menu = self.storyboard?.instantiateViewController(withIdentifier: "AdminMenuVC") as? AdminMenuVC
        } else {
            doctor_menu = self.storyboard?.instantiateViewController(withIdentifier: "DoctorMenuVC") as? DoctorMenuVC
        }
        let swipeRight = UISwipeGestureRecognizer(target: self, action:#selector(self.respondToGesture))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        let swipeLeft = UISwipeGestureRecognizer(target: self, action:#selector(self.respondToGesture))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeRight)
        self.view.addGestureRecognizer(swipeLeft)
    }

    func closeMenu() {
        AppDelegate.menu_bool = true
        if (usertype! == "Admin") {
            admin_menu.closeMenu()
        } else {
            doctor_menu.closeMenu()
        }
    }

    func close_on_swipe() {
        if AppDelegate.menu_bool {
            AppDelegate.menu_bool = false
        } else {
            closeMenu()
        }
    }
}
