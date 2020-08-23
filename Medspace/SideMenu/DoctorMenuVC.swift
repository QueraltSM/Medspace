//
//  DoctorMenuVC.swift
//  Medspace
//
//  Created by Queralt Sosa Mompel on 21/8/20.
//  Copyright © 2020 Queralt Sosa Mompel. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class DoctorMenuVC: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var fullname: UILabel!
    @IBOutlet weak var menu_table: UITableView!
    
    let data = [
        CollapsableViewModel(label: "Home", image: UIImage(named: "Home.png"), segue:"HomeVC"),
        CollapsableViewModel(label: "News", image: UIImage(named: "News.png")),
        CollapsableViewModel(label: "Clinical cases", image: UIImage(named: "Cases.png"), children: [
            CollapsableViewModel(label: "All cases"),
            CollapsableViewModel(label: "My cases"),
            CollapsableViewModel(label: "Post new case")]),
        CollapsableViewModel(label: "Discussions", image: UIImage(named: "Discussions.png"), children: [
            CollapsableViewModel(label: "All discussions"),
            CollapsableViewModel(label: "My discussions"),
            CollapsableViewModel(label: "Post new discussion")]),
        CollapsableViewModel(label: "Researches", image: UIImage(named: "Researches.png"), children: [
            CollapsableViewModel(label: "All researches"),
            CollapsableViewModel(label: "My researches"),
            CollapsableViewModel(label: "Post new research")]),
        CollapsableViewModel(label: "Account settings", image: UIImage(named: "Settings.png")),
        CollapsableViewModel(label: "Logout", image: UIImage(named: "Logout.png"))]
    
    var displayedRows: [CollapsableViewModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayedRows = data
        self.menu_table.delegate = self
        self.menu_table.dataSource = self
        menu_table.separatorStyle = .none
        self.view.backgroundColor = UIColor.clear
        setFullname()
    }

    func setFullname() {
        Database.database().reference().child("Users").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            let username = value?["Fullname"] as? String ?? ""
            self.fullname.text = username
        })
    }
    
    func closeMenu() {
        self.view.removeFromSuperview()
        AppDelegate.menu_bool = true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: "cell") as? CollapsibleTableViewCell) ?? CollapsibleTableViewCell(style: .default, reuseIdentifier: "cell")
        cell.configure(withViewModel: displayedRows[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let viewModel = displayedRows[indexPath.row]
        if viewModel.children.count > 0 {
            let range = indexPath.row+1...indexPath.row+viewModel.children.count
            let indexPaths = range.map { IndexPath(row: $0, section: indexPath.section) }
            tableView.beginUpdates()
            if viewModel.isCollapsed {
                displayedRows.insert(contentsOf: viewModel.children, at: indexPath.row + 1)
                tableView.insertRows(at: indexPaths, with: .automatic)
            } else {
                displayedRows.removeSubrange(range)
                tableView.deleteRows(at: indexPaths, with: .automatic)
            }
            tableView.endUpdates()
        }
        viewModel.isCollapsed = !viewModel.isCollapsed
        if (viewModel.label == "Logout") {
            logout()
        } else if (viewModel.segue != nil) {
            closeMenu()
            self.performSegue(withIdentifier: viewModel.segue!, sender: nil)
        }
    }
    
    func logout() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
            self.performSegue(withIdentifier: "LogoutVC", sender: nil)
        } catch let signOutError as NSError {
            showAlert(title: "Error signing out", message: signOutError.description)
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}
