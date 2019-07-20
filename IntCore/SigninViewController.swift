//
//  SigninViewController.swift
//  IntCore
//
//  Created by Ahmed Aboelela on 7/13/19.
//  Copyright © 2019 Ahmed Aboelela. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView

class SigninViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet var emailOrMobilleNumber: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var signinButton: UIButton!
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    var loadingInicator: NVActivityIndicatorView!
    var user: User!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(SigninViewController.dismissKeyboard))

        tapRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapRecognizer)
        
        emailOrMobilleNumber.delegate = self
        passwordTextField.delegate = self
        
        let midX = self.view.frame.size.width/2
        let midY = self.view.frame.size.height/2
        loadingInicator = NVActivityIndicatorView(frame: CGRect(x: midX - 40.0, y: midY - 40.0, width:80.0, height:80.0), type: .ballScale, color: UIColor.blue, padding: NVActivityIndicatorView.DEFAULT_PADDING )
        self.view.addSubview(loadingInicator)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
   
    
    @objc func dismissKeyboard(){
        emailOrMobilleNumber.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        if(textField.tag == 1){
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
            doWebRequest()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        
    }
    
    @IBAction func signin(_ sender: UIButton) {
        doWebRequest()
    }
    
    
    
    func doWebRequest(){
        showLoadingIndicator()
        let BASE_URL = "https://internship-api-v0.7.intcore.net/api/v1/user/auth/signin"
        let auth = emailOrMobilleNumber.text!
        let password = passwordTextField.text!
        let isValidUserName = checkForEmailAndMobileNumber(auth: auth)
        let isValidPassword = checkForPassword(password: password)
        
        if(isValidUserName && isValidPassword){
            let parameters: [String:String] = ["name": auth, "password": password]
            let headers: [String: String] = ["Accept":"application/json"]
            Alamofire.request(BASE_URL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
                if let responseData = response.data{
                    self.hideLoadingIndicator()
                    do{
                        let jsonData = try JSON(data: responseData)
                        print(jsonData)
                        self.user = User(id: jsonData["user"]["id"].intValue, email: jsonData["user"]["email"].stringValue, name: jsonData["user"]["name"].stringValue, phoneNumber: jsonData["user"]["phone"].intValue, createdAt: jsonData["user"]["created_at"].stringValue, image: jsonData["user"]["image"].stringValue, type: jsonData["user"]["type"].intValue, updatedAt: jsonData["user"]["updated_at"].stringValue, activation: jsonData["user"]["activation"].intValue, apiToken: jsonData["user"]["api_token"].stringValue)
                        self.performSegue(withIdentifier: "userInfoFromSignin", sender: self)
                    }catch let error{
                        print("Error parsing json: \(error)")
                    }
                    
                }
                
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userInfoFromSignin"{
            let tabBar = segue.destination as! UITabBarController
            let userInfo = tabBar.viewControllers![0] as! UserInfoViewController
            //let userInfo = nav.topViewController as! UserInfoViewController
            userInfo.user = self.user
        }
    }
    
    
    
    func checkForPassword(password: String) -> Bool{
        if password.isEmpty{
            showAlert(title: "Error", message: "This field can't be empty")
            return false
        }
        return true
    }
    
    func checkForEmailAndMobileNumber(auth: String)->Bool{
        if auth.isEmpty{
            showAlert(title: "Error", message: "This field can't be empty")
            return false
        }
        
        if Int(auth) != nil{
            if(isValidePhoneNumber(value: auth)){
                return true
            }
            showAlert(title: "Error", message: "Invalid phone number")
        }else{
            if(isValidEmail(testStr: auth)){
                return true
            }
            showAlert(title: "Error", message: "Invalid email")
        }
        return false
    }
    
    func isValidEmail(testStr:String) -> Bool {
        print("validate emilId: \(testStr)")
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        return result
    }
    
    func isValidePhoneNumber(value: String) -> Bool {
        let PHONE_REGEX = "^\\d{11}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
    }
    
    func showAlert(title: String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "ok", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func showLoadingIndicator(){
        loadingInicator.isHidden = false
        loadingInicator.startAnimating()
        signinButton.isEnabled = false
    }
    
    func hideLoadingIndicator(){
        loadingInicator.isHidden = true
        loadingInicator.stopAnimating()
        signinButton.isEnabled = true
    }
}
