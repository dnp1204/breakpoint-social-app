//
//  AuthService.swift
//  breakpoint
//
//  Created by dnp on 3/19/18.
//  Copyright © 2018 dnp. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

class AuthService {
    static let instance = AuthService()
    
    func registerUser(widthEmail email: String, andPassword password: String, userCreationComplete: @escaping CompletionHandler) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            guard let user = user else {
                userCreationComplete(false, error)
                return
            }
            
            
            let userData = ["provider": user.providerID, "email": user.email]
            DataService.instance.createDBUser(uid: user.uid, userData: userData)
            userCreationComplete(true, nil)
        }
    }
    
    func loginUser(widthEmail email: String, andPassword password: String, loginComplete: @escaping CompletionHandler) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                loginComplete(false, error)
                return
            }
            loginComplete(true, nil)
        }
    }
}
