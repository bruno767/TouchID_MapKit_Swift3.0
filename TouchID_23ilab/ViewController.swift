//
//  ViewController.swift
//  TouchID_23ilab
//
//  Created by Bruno Augusto Mendes Barreto Alves on 14/07/2017.
//  Copyright © 2017 Bruno Augusto Mendes Barreto Alves. All rights reserved.
//

import UIKit
import LocalAuthentication


class ViewController: UIViewController {
    let context = LAContext()
    
    @IBOutlet weak var message: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func touchID(_ sender: UIButton) {
        updateUI()
    }
    
    func updateUI() {
        var policy: LAPolicy?
        
        if #available(iOS 9.0, *) {
            // iOS 9+ users
            policy = .deviceOwnerAuthentication
        } else {
            // iOS 8+ users
            context.localizedFallbackTitle = "iOS 8"
            policy = .deviceOwnerAuthenticationWithBiometrics
            
        }
        var err: NSError?
        
        guard context.canEvaluatePolicy(policy!, error: &err) else {
            return
        }
        loginProcess(policy: policy!)

        
    }
    
    private func loginProcess(policy: LAPolicy) {
        
        context.evaluatePolicy(policy, localizedReason: "Authentication is needed to access the route, please enter your TouchID", reply: { (success, error) in
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5, animations: {
                    
                    if success{
                        self.message.text = "Authentication seccess"
                        self.performSegue(withIdentifier: "ShowMap", sender: nil)
                    } else {
                        guard let error = error else {return}
                        
                        switch(error) {
                        case LAError.authenticationFailed:
                            self.message.text = "There was a problem verifying your identity."
                        case LAError.userCancel:
                            self.message.text = "Authentication was canceled by user."
                        case LAError.userFallback:
                            self.message.text = "The user tapped the fallback button (Fuu!)"
                        case LAError.systemCancel:
                            self.message.text = "Authentication was canceled by system."
                        case LAError.passcodeNotSet:
                            self.message.text = "Passcode is not set on the device."
                        case LAError.touchIDNotAvailable:
                            self.message.text = "Touch ID is not available on the device."
                        case LAError.touchIDNotEnrolled:
                            self.message.text = "Touch ID has no enrolled fingers."
                        // iOS 9+ functions
                        case LAError.touchIDLockout:
                            self.message.text = "There were too many failed Touch ID attempts and Touch ID is now locked."
                        case LAError.appCancel:
                            self.message.text = "Authentication was canceled by application."
                        case LAError.invalidContext:
                            self.message.text = "LAContext passed to this call has been previously invalidated."
                        default:
                            self.message.text = "Touch ID may not be configured"
                            break
                        }
                        return
                    }
                
                })
            }

        })

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
    }
    
}

