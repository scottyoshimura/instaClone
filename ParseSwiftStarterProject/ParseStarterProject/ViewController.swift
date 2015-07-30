//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//  we can think of parse as an online database store. it is saving objects. we can upload our variables and objects and then download them later on to use on the same device or a different device.
//we can store a variety of things in parse including variables, arrays, dictionaries, files, boolean variables.

//we will also set up some spinners and alerts. we will use an activity indicator for the spinner

import UIKit
import Parse

//this is a login module that works with parse. it takes the PFUser object and grabs parameters from the user through the interface. when an error occurs on the parse side, we are putting the error message in an alert to prompt the user.


class ViewController: UIViewController, UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    
    
    //when the user is already a member and selects the sign in button, we will change the text on the buttons. the below outlets will set up the variables for that change
    //lets create an outlet to use on this form when the user is already a member
    @IBOutlet weak var signUpButtonMember: UIButton!
    //lets create an outlet to use on this form when the user is already a member
    @IBOutlet weak var signUpTextMember: UILabel!
    //lets create an outlet to use on this form when the user is already a member
    @IBOutlet weak var logInButtonMember: UIButton!
    
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    
    
    //we need a boolean to keep track of if the user is already a user. we will call that state signUpActive
    var signUpActive = true
    
    //lets set up an Activity Indicator, which is going to be a UI, and set it to a emtpy UIIndicatorView
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    //lets set up a default errorMessage
    var errorMessage = "please try again later"
    
    //lets create a function that will create us a pop alert. we dont want to have to change code everytime we want to change the pop ups. it will receive two varibalbes, title, and message. note that in a pop up alert, the user closes it with an action
    func displayAlert(title: String, message: String) {
        //lets create an alert up front so the user doesn't have to wait for the parse response if there is a problem with their uername or pass
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        //lets add a single uialert action for the user to press
        alert.addAction(UIAlertAction(title: "ok", style: .Default, handler: { (action) -> Void in

            //and then dismiss the view controller
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        //and of course we have to present the alert View Controller
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func signUp(sender: AnyObject) {
        //this button has two main routines both the "sign up" and the "login"
        //first
        //if the user has left the userName and password blank, then we want to display an alert for them to check the boxes. if not, than we want to present an activity indicator and then if signUpActive is true, we will go ahead and sign up the user by creating an instance of PFUser, and saving it in the background. if signUpActive is not true, that is the user has told the app that they are a registered user, then we will
        
        
        if userName.text == "" || password.text == ""{
        //remember that the double pipes is "or"
            //note below we are using the displayAlert function we created, and passed in a variable called title, and message
            displayAlert("Error in Form", message: "Please check your username or password")
            
        } else {
            
            //lets activiate the activity indicator and set the frame. this should be a good size one
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            //and lets set up the activitiy indicator in the middle of the screen
            activityIndicator.center = self.view.center
            //then lets hidesWhenStopped to true. this saves us from activel hiding it when we stop it each time
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            //and lets add it to the view, the subview we want to add is activityIndicataor
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            //and lets pause the app so hte user can't do anything
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            if signUpActive == true {
                
            var user = PFUser()
            user.username = userName.text
            user.password = password.text
            
            //lets sign up in the background, with two variables, success and error
            user.signUpInBackgroundWithBlock({ (success, error) -> Void in
                //either way, whatever happens, we want to stop the animation
                self.activityIndicator.stopAnimating()
                //because we set hides when stopped to true, we don't need to get rid of the indicatora, but we need to make the app active
                
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                //above means the user can use hte app again, 
                
                //now we can look at either of hte variables to see if we have been succesful
                if error == nil {
                    
                    //sign up succesful
                    println("sign up has been succesful " + user.username!)
                    
                    //lets do our seguay, and we need to use self to use this view controller because it is in a block
                    self.performSegueWithIdentifier("login", sender: self)
                    
                    
                
                } else {
                    //if error is not nil
                    //lets get an error message from parse
                    //it is an optional, so we should check if it exists
                        //we want to attempt to get it from parse and see if it is there.
                        //we will try to set it to a variable called errorString, and attempt to cast it as a string
                    if let errorString = error!.userInfo?["error"] as? String {
                        //note we unwrapped error, and then accessed its "error" and cast it as a string
                        
                        // now we want parse to hopefully provide us with an error
                        self.errorMessage = errorString
                        
                    }
                    
                    self.displayAlert("failed sign up", message: self.errorMessage)
                }
            }) } else {
                PFUser.logInWithUsernameInBackground(userName.text, password: password.text, block: { (user, error) -> Void in
                    
                    self.activityIndicator.stopAnimating()
                    //because we set hides when stopped to true, we don't need to get rid of the indicatora, but we need to make the app active
                    
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    //above means the user can use hte app again,
                    
                    if user != nil {
                        //logged in
                        println("logged in ")
                        

                //lets do our seguay, and we need to use self to use this view controller
                self.performSegueWithIdentifier("login", sender: self)
                        //note that with the above, when the user is logged in, the app will take them to the user list table
                    } else {
                        if let errorString = error!.userInfo?["error"] as? String {
                            //note we unwrapped error, and then accessed its "error" and cast it as a string
                            
                            // now we want parse to hopefully provide us with an error
                            self.errorMessage = errorString
                            
                        }
                        
                        self.displayAlert("failed login", message: self.errorMessage)
                    }
                })
            }
        }
    } 
    
    @IBAction func login(sender: AnyObject) {
        //if the user is already a member and presses log in, they have to go to a different view.
            //we will need both aspects to the login view, and the sign up view
                //in order to do this we need to keep track of what mode the app is in
        
        //if the user is already a member, we will change the buttons and the text
        if signUpActive == true {
            signUpButtonMember.setTitle("Log In", forState: UIControlState.Normal)
            
            signUpTextMember.text = "Not Registered?"
            
            logInButtonMember.setTitle("Sign Up", forState: UIControlState.Normal)
            
            signUpActive = false
        } else {
            signUpButtonMember.setTitle("Sign Up", forState: UIControlState.Normal)
            
            signUpTextMember.text = "Already a Member"
            
            logInButtonMember.setTitle("Log In", forState: UIControlState.Normal)
            
            signUpActive = true
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view didLoad runs before segues are created. so we need to check to see if the user is logged in below. if they are, they will go straight to the user list
        }
        //lets see if the user is checked in. if they are, we will appear the tablelist

    
    //we are getting errors when running this application on different versions of simulator devices because parse is checking that we are logged in from the same device we logged in with. to fix this issue. we will remove the below code, run the app. then add in the code, and fix.
    
    
    override func viewDidAppear(animated: Bool) {
        //to actually do the check we just see if a current user actually exists at this state
        if PFUser.currentUser() != nil {
            self.performSegueWithIdentifier("login", sender: self)
            //if the user is logged in already, it jumps straight to the user list
            println("testing the line")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    }

    
    
    