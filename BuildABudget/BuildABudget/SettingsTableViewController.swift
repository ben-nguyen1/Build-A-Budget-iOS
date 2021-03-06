//
//  SettingsTableViewController.swift
//  BuildABudget
//
//  Created by Ben Nguyen on 11/27/17.
//  Copyright © 2017 Ben Nguyen. All rights reserved.
//
import UIKit

class SettingsTableViewController: UITableViewController {
    var changeEmailAlertController:UIAlertController? = nil
    var changePasswordAlertController:UIAlertController? = nil
    var alertErrorController:UIAlertController? = nil
    
    var newEmailTextField: UITextField? = nil
    var oldPasswordTextField: UITextField? = nil
    var newPasswordTextField: UITextField? = nil
    var confirmNewPasswordTextField: UITextField? = nil
    
    @IBOutlet weak var segCurrency: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        print("IN settings screen")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let currency = Account.currency()
        if (currency == "$") {
            segCurrency.selectedSegmentIndex = 0
        } else if (currency == "€") {
            segCurrency.selectedSegmentIndex = 1
        } else {
            segCurrency.selectedSegmentIndex = 2
        }
        
    }
    
    @IBAction func segCurrencyAction(_ sender: Any) {
        switch self.segCurrency.selectedSegmentIndex {
            case 0:
                Account.setCurrency("$")
                segCurrency.selectedSegmentIndex = 0
                print("dollar")
            case 1:
                Account.setCurrency("€")
                segCurrency.selectedSegmentIndex = 1
                print("euro")
            case 2:
                Account.setCurrency("£")
                segCurrency.selectedSegmentIndex = 2
                print("pound")
            default:
                break
        }
    }
    
    @IBAction func changeEmail(_ sender: UIButton) {
        self.changeEmailAlertController = UIAlertController(title: "Change Email", message: "Fill out the forms", preferredStyle: UIAlertControllerStyle.alert)
        
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            print("Ok Button Pressed")
            if (Account.pass() == self.oldPasswordTextField!.text) {
                print("password matches!")
                Account.setUserName((self.newEmailTextField?.text)!)
                print(Account.userName())
            } else {
                print("password do not match")
                self.alertErrorController = UIAlertController(title: "Error!!", message: "Password does not match", preferredStyle: UIAlertControllerStyle.alert)
                
                let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default){
                    (action:UIAlertAction) in
                }
                
                self.alertErrorController!.addAction(OKAction)
                self.present(self.alertErrorController!, animated: true, completion:nil)
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) -> Void in
            print("Cancel Button Pressed")
        }
        
        self.changeEmailAlertController!.addAction(ok)
        self.changeEmailAlertController!.addAction(cancel)
        
        self.changeEmailAlertController!.addTextField { (textField) -> Void in
            // Enter the textfiled customization code here.
            self.newEmailTextField = textField
            self.newEmailTextField?.placeholder = "New Email"
        }
        self.changeEmailAlertController!.addTextField { (textField) -> Void in
            // Enter the textfiled customization code here.
            self.oldPasswordTextField = textField
            self.oldPasswordTextField?.placeholder = "Password"
            self.oldPasswordTextField?.isSecureTextEntry = true
        }
        
        present(self.changeEmailAlertController!, animated: true, completion: nil)
    }
    
    @IBAction func changePassword(_ sender: Any) {
        self.changePasswordAlertController = UIAlertController(title: "Change Password", message: "Fill out the forms", preferredStyle: UIAlertControllerStyle.alert)
        
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            print("Ok Button Pressed")
            if (Account.pass() == self.oldPasswordTextField!.text && self.newPasswordTextField!.text == self.confirmNewPasswordTextField!.text) {
                print("password matches!")
                Account.setPass((self.newPasswordTextField?.text)!)
                print(Account.userName())
            } else {
                print("password do not match")
                self.alertErrorController = UIAlertController(title: "Error!!", message: "Something doesn't match!", preferredStyle: UIAlertControllerStyle.alert)
                
                let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default){
                    (action:UIAlertAction) in
                }
                
                self.alertErrorController!.addAction(OKAction)
                self.present(self.alertErrorController!, animated: true, completion:nil)
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) -> Void in
            print("Cancel Button Pressed")
        }
        
        self.changePasswordAlertController!.addAction(ok)
        self.changePasswordAlertController!.addAction(cancel)
        
        self.changePasswordAlertController!.addTextField { (textField) -> Void in
            // Enter the textfiled customization code here.
            self.oldPasswordTextField = textField
            self.oldPasswordTextField?.placeholder = "Current password"
            self.oldPasswordTextField?.isSecureTextEntry = true
        }
        self.changePasswordAlertController!.addTextField { (textField) -> Void in
            // Enter the textfiled customization code here.
            self.newPasswordTextField = textField
            self.newPasswordTextField?.placeholder = "New password"
            self.newPasswordTextField?.isSecureTextEntry = true
        }
        
        self.changePasswordAlertController!.addTextField { (textField) -> Void in
            // Enter the textfiled customization code here.
            self.confirmNewPasswordTextField = textField
            self.confirmNewPasswordTextField?.placeholder = "Confirm new password"
            self.confirmNewPasswordTextField?.isSecureTextEntry = true
        }
        
        present(self.changePasswordAlertController!, animated: true, completion: nil)
    }
    
    @IBAction func tutorialsBtn(_ sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint(), to:tableView)
        let indexPath = tableView.indexPathForRow(at:buttonPosition)
        let cell = tableView.cellForRow(at: indexPath!)
        cell?.backgroundColor = UIColor.lightGray


        let storyboard = UIStoryboard(name: "Tutorial", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "tutorialPageVC") as! TutorialPageViewController
        present(vc, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func logout(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "loginViewController") as! LoginViewController
        present(vc, animated: true, completion: nil)
    }
}
