//
//  CreateGroupVC.swift
//  breakpoint
//
//  Created by dnp on 3/19/18.
//  Copyright © 2018 dnp. All rights reserved.
//

import UIKit
import FirebaseAuth

class CreateGroupVC: UIViewController {

    @IBOutlet weak var titleTextField: InsetTextField!
    @IBOutlet weak var descriptionTextField: InsetTextField!
    @IBOutlet weak var emailSearchTextField: InsetTextField!
    @IBOutlet weak var groupMemeberLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneBtn: UIButton!
    
    var emailArray = [String]()
    var choosenUserArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        emailSearchTextField.delegate = self
        emailSearchTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        doneBtn.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func doneBtnWasPressed(_ sender: Any) {
        if titleTextField.text != "" && descriptionTextField.text != "" {
            DataService.instance.getIds(forUsernames: choosenUserArray, handler: { (idsArray) in
                var userIds = idsArray
                userIds.append((Auth.auth().currentUser?.uid)!)
                
                DataService.instance.createGroup(withTitle: self.titleTextField.text!, andDescription: self.descriptionTextField.text!, forUserIds: userIds, handler: { (groupCreated) in
                    if groupCreated {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        print("Group could not be created. Please try again")
                    }
                })
            })
        }
    }
    
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func textFieldDidChange() {
        if emailSearchTextField.text == "" {
            emailArray = []
            tableView.reloadData()
        } else {
            DataService.instance.getEmail(forSearchQuery: emailSearchTextField.text!, handler: { (returnEmailArray) in
                self.emailArray = returnEmailArray
                self.tableView.reloadData()
            })
        }
    }
}

extension CreateGroupVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emailArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as? UserCell else { return UITableViewCell() }
        
        let profileImage = UIImage(named: "defaultProfileImage")
        
        if choosenUserArray.contains(emailArray[indexPath.row]) {
            cell.configureCell(profileImage: profileImage!, email: emailArray[indexPath.row], isSelected: true)
        } else {
            cell.configureCell(profileImage: profileImage!, email: emailArray[indexPath.row], isSelected: false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? UserCell else { return }
        if !choosenUserArray.contains(cell.emailLbl.text!) {
            choosenUserArray.append(cell.emailLbl.text!)
            groupMemeberLbl.text = choosenUserArray.joined(separator: ", ")
            doneBtn.isHidden = false
        } else {
            choosenUserArray = choosenUserArray.filter({ $0 != cell.emailLbl.text! })
            if choosenUserArray.count >= 1 {
                groupMemeberLbl.text = choosenUserArray.joined(separator: ", ")
            } else {
                groupMemeberLbl.text = "added people to your group"
                doneBtn.isHidden = true
            }
        }
    }
}

extension CreateGroupVC: UITextFieldDelegate {}
