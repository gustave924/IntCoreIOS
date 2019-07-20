//
//  UserInfoViewController.swift
//  IntCore
//
//  Created by Ahmed Aboelela on 7/19/19.
//  Copyright © 2019 Ahmed Aboelela. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView

class UserInfoViewController: UIViewController {
    var user: User!
    var loadingIndicator: NVActivityIndicatorView!
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var phoneNumberTextField: UITextField!
    @IBOutlet var coverImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        nameTextField.text = user.name
        emailTextField.text = user.email
        phoneNumberTextField.text = "0"+String(user.phoneNumber)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let midX = self.view.frame.size.width/2
        let midY = self.view.frame.size.height/2
        loadingIndicator = NVActivityIndicatorView(frame: CGRect(x: midX - 40.0, y: midY - 40.0, width:80.0, height:80.0), type: .ballScale, color: UIColor.blue, padding: NVActivityIndicatorView.DEFAULT_PADDING )
        self.view.addSubview(loadingIndicator)

    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
       if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= coverImage.image!.size.height/2
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    @IBAction func updateProfile(_ sender: Any) {
        let name: String = nameTextField.text!
        let email: String = emailTextField.text!
        
        if(isValidName(name: name) || name.isEmpty){
            showAlert(title: "Error", message: "Not A valid name.")
            return
        }
        
        if(!isValidEmail(email: email) || email.isEmpty){
            showAlert(title: "Error", message: "Not a valid email")
            return
        }
        
        let button = sender as! UIButton
        showLoadingIndicator(button: button)
        let URL = "https://internship-api-v0.7.intcore.net/api/v1/user/auth/update-profile"
        let params:[String: String] = ["api_token":user.apiToken, "name": name, "email": email, "image": ""]
        let headers = ["Accept": "application/json"]
        
        Alamofire.request(URL, method: .patch, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            do{
                
                let jsonData = try? JSON(data: response.data!)
                print(jsonData)
                self.hideLoadingIndicator(button: button)
                if(response.response?.statusCode == 422){
                    let message = jsonData!["errors"][0]["message"].stringValue
                    self.showAlert(title: "Error", message: message)
                    self.nameTextField.text = self.user.name
                    self.emailTextField.text = self.user.email
                }else{
                    self.user.name = name
                    self.user.email = email
                }
            }catch let error {
                
            }
        }
    }
    
    @IBAction func updateInfo(_ sender: Any) {
        let phoneNumber: String = phoneNumberTextField.text!
        if(!isValidePhoneNumber(value: phoneNumber) || phoneNumber.isEmpty){
            showAlert(title: "Error", message: "Invalid Phone number")
        }
        
        let button = sender as! UIButton
        showLoadingIndicator(button: button)
        
        let URL = "https://internship-api-v0.7.intcore.net/api/v1/user/auth/update-phone"
        let params:[String: String] = ["api_token":user.apiToken, "phone": phoneNumber, "temp_phone_code":"1928"]
        let headers = ["Accept": "application/json"]
        
        Alamofire.request(URL, method: .patch, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            do{
                let jsonData = try? JSON(data: response.data!)
                if(response.response?.statusCode == 422){
                    let message = jsonData!["errors"][0]["message"].stringValue
                    self.showAlert(title: "Error", message: message)
                    self.nameTextField.text = self.user.name
                    self.emailTextField.text = self.user.email
                }else{
                }
                print(jsonData)
                self.hideLoadingIndicator(button: button)
            }catch let error{
                print(error)
            }
        }
    }
    
    @IBAction func updatePassword(_ sender: Any) {
        let alert = UIAlertController(title: "Change password", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter old Password"
            textField.isSecureTextEntry = true
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Enter New password"
            textField.isSecureTextEntry = true
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Confirm password"
            textField.isSecureTextEntry = true
        }
        let action = UIAlertAction(title: "Update", style: .default) { (action) in
            let oldPassTextField = alert.textFields![0]
            let newPassTextField = alert.textFields![1]
            let confirmNewPassTextField = alert.textFields![2]
            
            let oldPass: String = oldPassTextField.text!
            let newPass: String = newPassTextField.text!
            let confirmNewPass: String = confirmNewPassTextField.text!
            
            if(!self.arePasswordMatches(pass: newPass, confirmPass: confirmNewPass)){
                self.showAlert(title: "Error", message: "Password doesn't match")
                return
            }
            
            let URL = "https://internship-api-v0.7.intcore.net/api/v1/user/auth/update-password"
            let params:[String: String] = ["api_token":self.user.apiToken, "new_password": newPass, "old_password": oldPass]
            let headers = ["Accept": "application/json"]
            
            Alamofire.request(URL, method: .patch, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
                do{
                    let jsonData = try? JSON(data: response.data!)
                    if(response.response?.statusCode == 422){
                        let message = jsonData!["errors"][0]["message"].stringValue
                        self.showAlert(title: "Error", message: message)
                        self.nameTextField.text = self.user.name
                        self.emailTextField.text = self.user.email
                    }else{
                    }
                    print(jsonData)
                }catch let error{
                    print(error)
                }
            }
        }
        alert.addAction(action)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func isValidName(name: String) -> Bool {
        let RegEx = ".*[^A-Za-z ].*"
        let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
        return Test.evaluate(with: name)
    }
    
    func isValidEmail(email: String) -> Bool{
        let RegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
        return Test.evaluate(with: email)
    }
    
    func isValidePhoneNumber(value: String) -> Bool {
        let PHONE_REGEX = "^\\d{11}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
    }
    
    func arePasswordMatches(pass: String, confirmPass: String) -> Bool{
        return pass == confirmPass
    }
    
    func showAlert(title: String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "ok", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    func showLoadingIndicator(button: UIButton){
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        button.isEnabled = false
    }
    
    func hideLoadingIndicator(button: UIButton){
        loadingIndicator.isHidden = true
        loadingIndicator.stopAnimating()
        button.isEnabled = true
    }
}
