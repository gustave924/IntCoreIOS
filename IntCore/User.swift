//
//  User.swift
//  IntCore
//
//  Created by Ahmed Aboelela on 7/14/19.
//  Copyright © 2019 Ahmed Aboelela. All rights reserved.
//

import Foundation

class User{
    var id: Int
    var email: String
    var name: String
    var phoneNumber: Int
    var createdAt: Date
    var image: String
    var type: Int
    var updatedAt: Date
    var activation: Bool
    var apiToken: String = ""
    
    
    init(id:Int, email:String, name:String, phoneNumber: Int,createdAt: String,image: String,type: Int,
         updatedAt: String, activation: Int) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let now = Date()
        
        self.id = id
        self.email = email
        self.name = name
        self.phoneNumber = phoneNumber
        self.createdAt = dateFormatter.date(from: createdAt) ?? now
        self.image = image
        self.type = type
        self.updatedAt = dateFormatter.date(from: updatedAt) ?? now
        self.activation = activation == 1
    }
    
    convenience init(id:Int, email:String, name:String, phoneNumber: Int,createdAt: String,image: String,type: Int, updatedAt: String, activation: Int, apiToken: String){
        self.init(id:id,
                  email:email,
                  name:name,
                  phoneNumber: phoneNumber,
                  createdAt: createdAt,
                  image: image,
                  type: type,
                  updatedAt: updatedAt,
                  activation: activation)
        self.apiToken = apiToken
    }
}
