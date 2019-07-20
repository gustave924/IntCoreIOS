//
//  SignupViewController.swift
//  IntCore
//
//  Created by Ahmed Aboelela on 7/19/19.
//  Copyright © 2019 Ahmed Aboelela. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView

class SignupViewController: UIViewController, UITextFieldDelegate{
    

    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var phoneNumberTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var confirmPasswordTextField: UITextField!
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        emailTextField.delegate = self
        phoneNumberTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignupViewController.dismissKeyboard))
        
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapRecognizer)
        
        /*NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)*/
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userInfoFromSignup"{
            let tabBar = segue.destination as! UITabBarController
            let userInfo = tabBar.viewControllers![0] as! UserInfoViewController
            //let userInfo = nav.topViewController as! UserInfoViewController
            userInfo.user = self.user
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
   
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func signup(_ sender: UIButton) {
        signupApiCall()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        switch textField.tag {
        case 1:
            nameTextField.resignFirstResponder()
            emailTextField.becomeFirstResponder()
        case 2:
            emailTextField.resignFirstResponder()
            phoneNumberTextField.becomeFirstResponder()
        case 3:
            phoneNumberTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        case 4:
            passwordTextField.resignFirstResponder()
            confirmPasswordTextField.becomeFirstResponder()
        default:
            confirmPasswordTextField.resignFirstResponder()
            signupApiCall()
        }
        return true
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
    
    
    fileprivate func signupApiCall() {
        
        let name: String =  nameTextField.text!
        let email: String = emailTextField.text!
        let phoneNumber: String = phoneNumberTextField.text!
        let password: String = passwordTextField.text!
        let confirmPassword: String = confirmPasswordTextField.text!
        
        
        if(name.isEmpty){
            showAlert(title: "Error", message: "Name can't be empty")
            return
        }
        
        if(isValidName(name: name)){
            showAlert(title: "Error", message: "Invalid Name")
            return
        }
        
        if(email.isEmpty){
            showAlert(title: "Error", message: "Email can't be empty")
            return
        }
        
        if(!isValidEmail(email: email)){
            showAlert(title: "Error", message: "Invalid Email Address")
            return
        }
        
        if(phoneNumber.isEmpty){
            showAlert(title: "Error", message: "Phone Number can't be empty")
            return
        }
        
        if(!isValidePhoneNumber(value: phoneNumber)){
            showAlert(title: "Error", message: "Invalid Phone Number")
            return
        }
        
        if(password.isEmpty){
            showAlert(title: "Error", message: "Password can't be empty")
            return
        }
        
        if(!arePasswordMatches(pass: password, confirmPass: confirmPassword)){
            showAlert(title: "Error", message: "Password doesn't match")
            return
        }
        
        let URL = "https://internship-api-v0.7.intcore.net/api/v1/user/auth/signup"
        let body = ["name":name, "phone": phoneNumber, "password": password, "email": email]
        let headers = ["Accept": "application/json"]
        Alamofire.request(URL, method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            if let responseData = response.data{
                do{
                    print()
                    let jsonData = try JSON(data: responseData)
                    
                    if(response.response?.statusCode == 422){
                        let message = jsonData["errors"][0]["message"].stringValue
                        self.showAlert(title: "Error", message: message)
                        
                    }else{
                        self.user = User(id: jsonData["user"]["id"].intValue, email: jsonData["user"]["email"].stringValue, name: jsonData["user"]["name"].stringValue, phoneNumber: jsonData["user"]["phone"].intValue, createdAt: jsonData["user"]["created_at"].stringValue, image: jsonData["user"]["image"].stringValue, type: jsonData["user"]["type"].intValue, updatedAt: jsonData["user"]["updated_at"].stringValue, activation: jsonData["user"]["activation"].intValue, apiToken: jsonData["user"]["api_token"].stringValue)
                        self.performSegue(withIdentifier: "userInfoFromSignup", sender: self)
                    }
                    
                    print(jsonData)
                }catch let error{
                    print(error)
                }
            }
        }
    }
}
