//
//  ViewController.swift
//  RLShowRoom
//
//  Created by Mikola Dyachok on 9/16/16.
//  Copyright © 2016 Mykola Diachok. All rights reserved.
//

import UIKit

import Firebase
import FirebaseAuth
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import Social

class LoginViewController: UIViewController, UITextFieldDelegate, GIDSignInDelegate, GIDSignInUIDelegate {

    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var btnGoogleSignIn: UIButton!
    @IBOutlet weak var btnFaceBookSignIn: UIButton!
    @IBOutlet weak var btnEmailSignUp: UIButton!
    @IBOutlet weak var btnEmailLogin: UIButton!
    @IBOutlet weak var btnLogOut: UIButton!
    
    //var ref: fir!
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        hideKeyboardWhenTappedAround()
        
        self.tfEmail.setLeftImage(imageName: "mail")
        
        self.tfPassword.setLeftImage(imageName: "password")
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            
            print(error.localizedDescription)
            
            return
        } else {
            
            print("Wow, it works! with \(user.profile.name)")
            
            let authentication = user.authentication
            let credential = FIRGoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!,
                                                              accessToken: (authentication?.accessToken)!)
            
            
            print(credential)
            
           firebaseAuth(credential)
        }
    }
    
    // SignOut of Google Instance
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        GIDSignIn.sharedInstance().signOut()
    }
    
    @IBAction func onClickbtnGoogleSignIn(_ sender: UIButton) {
       print("onClickbtnGoogleSignIn")
        GIDSignIn.sharedInstance().signIn()
              
    }
    

    
    @IBAction func onClickbtnEmailSignIn(_ sender: UIButton) {
        if self.tfEmail.text == "" || self.tfPassword.text == ""
        {
            let alertController = UIAlertController(title: "Ooops!", message: "Please enter an email and password", preferredStyle: .alert)
            
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        }
        else
        {
            FIRAuth.auth()?.signIn(withEmail: self.tfEmail.text!, password: self.tfPassword.text!, completion: { (user, error) in
                if error == nil
                {
                    //self.logoutButton.alpha = 1.0
                    //self.usernameLable.text = user!.email
                    self.tfEmail.text = ""
                    self.tfPassword.text = ""
                }
                else
                {
                    let alertController = UIAlertController(title: "Ooops!", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                }
            })
            
            
        }
    }
    
    @IBAction func btnEmailSignUp(_ sender: UIButton) {
        
        if self.tfEmail.text == "" || self.tfPassword.text == ""
        {
            let alertController = UIAlertController(title: "Ooops!", message: "Please enter an email and password", preferredStyle: .alert)
            
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        }
        
        else
        {
            FIRAuth.auth()?.createUser(withEmail: self.tfEmail.text!, password: self.tfPassword.text!, completion: { (user, error) in
                if error == nil
                {
                    //self.logoutButton.alpha = 1.0
                    //self.usernameLable.text = user!.email
                    self.tfEmail.text = ""
                    self.tfPassword.text = ""
                }
                else
                {
                    let alertController = UIAlertController(title: "Ooops!", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                }
            })
            
        }
    }
    
    
    @IBAction func OnClickbtnFaceBook(_ sender: UIButton) {

        FBSDKProfile.enableUpdates(onAccessTokenChange: true)
        
        let facebookLogin: FBSDKLoginManager = FBSDKLoginManager()
        
        facebookLogin.loginBehavior = FBSDKLoginBehavior.web
        facebookLogin.logOut()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self){
            (result, error) in
            if error != nil {
                print("Unable to  auth in FaceBook - \(error)")
            } else if result?.isCancelled == true {
                //print(FBSDKAccessToken.current().tokenString)
                print("User cancelled Facebook auth")
            } else {
                print("Successfully auth with FaceBook")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        }
    }
    
    

    
    
    
    
    func firebaseAuth(_ credential: FIRAuthCredential)
    {
        FIRAuth.auth()?.signIn(with: credential, completion: {(user, error) in
            if error != nil {
                print("Unable to auth with Firebase - \(error)");
            } else {
                print("Successfully auth with Firebase")
                print("Wow, it works in Firebase! with \(user?.displayName)")
            }
        })
    }
    
    
    @IBAction func onClickbtnLogOut(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signOut() // need add if google sign
        try! FIRAuth.auth()!.signOut()
    }
    
    

    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == tfEmail || textField == tfPassword {
            
            UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
            
            UserDefaults.standard.synchronize()
            // synchronize will impose the change made to the user defaults. }
            
            self.animateViewMoving(up: true, moveValue: 100)

        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == tfEmail || textField == tfPassword {
            animateViewMoving(up: false, moveValue: 100)
        }
    }
    

    
    
}

