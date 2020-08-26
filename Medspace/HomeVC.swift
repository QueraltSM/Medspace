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
let specialities = ["Allergy & Inmunology","Anesthesiology","Dermatology",
                    "Diagnostic Radiology", "Emergency Medicine", "Family Medicine",
                    "Internal Medicine", "Medical Genetics", "Neurology",
                    "Nuclear Medicine", "Opthalmology", "Pathology",
                    "Pediatrics","Preventive Medicine", "Psychiatry",
                    "Radiation Oncology", "Surgery", "Urology"]

class HomeVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usertype = UserDefaults.standard.string(forKey: "usertype")
        username = UserDefaults.standard.string(forKey: "fullname")
        setMenu()
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
}

func getMenuView() -> UIViewController {
    AppDelegate.menu_bool = false
    if (usertype! == "Admin") {
        return admin_menu
    }
    return doctor_menu
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
