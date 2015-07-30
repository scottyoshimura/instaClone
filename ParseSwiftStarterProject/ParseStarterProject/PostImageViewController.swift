//
//  PostImageViewController.swift
//  ParseStarterProject
//
//  Created by Scott Yoshimura on 7/23/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse


//we have to add some more delegates to enable the image picking. UINavigationControllerDelegate, UIImagePickerControllerDelegate

class PostImageViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    //lets set up some pop up alerts
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
    
    
    //lets create an activity indicator for us to use later
    var activityIndicator = UIActivityIndicatorView()
    
    
    //lets create outlets for the ui elements.
    @IBOutlet weak var imageToView: UIImageView!
    
    
    @IBAction func btnSelectImage(sender: AnyObject) {
        
        //lets create a variable called image
        var image = UIImagePickerController()
        
        //lets set the image delegate to self
        image.delegate = self
        
        //lets set source type to uiimagepickercontrollersourcetype.photolibrary to get the photolibrary
        //CHALLENGE set up so the user can use their camera
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        image.allowsEditing = false
        
        self.presentViewController(image, animated: true, completion: nil)
        
    }
    
    //below will happen when the user has picked an image using the above code
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        //below will dismiss the view controller that we have presented here
        self.dismissViewControllerAnimated(true, completion: nil)
        
        //and then lets take the image that was chosen and set it as the image they chose from their photo library
        imageToView.image = image
        
    }
    
    @IBOutlet weak var textMessage: UITextField!
    
    @IBAction func btnPostImage(sender: AnyObject) {
        // here is where we will enable the saving of the image to parse
        //save an object to parse. we will save, the image, the message, and the userid
        
        //lets do our usual code for the activity indicator kick off
        //we set up the activity indicator with a frame, center to self.view.frame
        activityIndicator = UIActivityIndicatorView(frame: self.view.frame)
        //and lets put some color behind the frame
        activityIndicator.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        //lets set the center of the view to the center of the screen
        activityIndicator.center = self.view.center
        //lets set the hides when stopped boolean to true
        activityIndicator.hidesWhenStopped = true
        //lets set the activityIndicator viewStyle
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        //and add this to the view
        view.addSubview(activityIndicator)
        //finally kick it off
        activityIndicator.startAnimating()
        //once the activity indicator, we don't want the user to do anyting until done
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        
        //lets create a variable called post of a pfobject
        var post = PFObject(className: "Post")
        
        //lets set the message to message.text
        post["message"] = textMessage.text
        
        //lets set the userId to the one of the current user
        post["userId"] = PFUser.currentUser()!.objectId!
        
        //and then we need to save the image. we can do that as an image file. we just have to convert the image to a file and the save  it to the post variable.
        //lets create a static variable called imageData, and take the image we have and convert it to data.
        let imageData = UIImagePNGRepresentation(imageToView.image)
        //and then we will create an image file from the above that will be a PFFile
        let imageFile = PFFile(name: "image.png", data: imageData)
            //the above creates a file of PFFile typw with a name of image.png and the data is from imageData
        
        //the set the post["imageFile"] to imageFile
        post["imageFile"] = imageFile
        
        //the above saves the message, userId, and the file
        //and then we can kick off the post.SaveInBackgroundWithBlock, and the variables we are going to get back are success and error
        post.saveInBackgroundWithBlock{(success,error) -> Void in
            
            //as soon as the post has finished, we want to stop the activity indicator and end ignoring interaction events.
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            
            //CHALLENGE, test to make sure that an image has been selected, and that text has been entered in the text box
            
            
            if error == nil {
                
                //if we were succesful lets tell the user
                self.displayAlert("Image saved", message: "Your image was saved to your account")
                //println("post was a success")
                //lets clear the image once it has been posted
                self.imageToView.image = UIImage(named: "icon-user-default.png")
                //and lets set the message to nothng
                self.textMessage.text = ""
                
                
            } else {
                println("there was an error in the post")
                self.displayAlert("Could not post image", message: "try again later")
                //CHALLENGE! extract the parse error and success message and display
            }
            }
        //the above will create the post class, and create the three variables of userid, image, and message
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
