//
//  feedTableController.swift
//  ParseStarterProject
//
//  Created by Scott Yoshimura on 7/28/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//
// this view controller controls the view the user sees when they have selected the feed button bar item

// below we are going to we are starting by getting a list of users, and populating that array, then work out which users are followed by the active user, then getting the list of posts of those users, and then appending all the details in the arrays we created.

import UIKit
import Parse

class feedTableController: UITableViewController {
    
    //lets create some arrays that we will use later
    var messages = [String]()
        //for storing the messages
    var userNames = [String]()
        //for storing the userNames
    var imageFiles = [PFFile]()
        //for storing the image files
    var users = [String: String]() //note we are turning this into a dictionary
        //for storing userIds and users names
    override func viewDidLoad() {
        super.viewDidLoad()
        
 //-----lets start by populating the users dictionary
        //lets create our query to find which users the current user is following
        var query = PFUser.query()
        
        //and lets start this, and find every user. we will return objects which are our users, and maybe an error
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            //lets see if objects exists
            if let users = objects {
                //lets clear the first record in the array because we created an  array with a blank record first
                self.messages.removeAll(keepCapacity: true)
                self.users.removeAll(keepCapacity: true)
                self.imageFiles.removeAll(keepCapacity: true)
                self.userNames.removeAll(keepCapacity: true)
                //and if the above happens we can use users as our AnyObject to loop through to get all of our users. and the main thing we want to do is update the user id and username arrays.
                for object in users {
                    //lets start filling up our users dictionary
                    //lets create a pfUser to extract the user name and id
                    if let user = object as? PFUser {
                        //this is the user that we are interested in, and we add it to the users dictionary. we get the object id and equal it to the username
                        self.users[user.objectId!] = user.username!
                        //quite a convulated way to create a dictionary of users to access later.
                        
                    }
                }
                
        
            }
           
                //----- then lets gets the users that the current user is following.
            
                //the first thing we need to know is what users are following who?
                var queryGetFollowedUsers = PFQuery(className: "followers")
            
                //we have two important aspects. follower and following. for the below query we want to get all of the followers that the currentUser()!.objectId! is a follower
                queryGetFollowedUsers.whereKey("follower", equalTo: PFUser.currentUser()!.objectId!)
                //now lets action the query. we will use findObjectsInBackgroundWithBlock
                queryGetFollowedUsers.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                //lets check to see if objects exists
                if let objects = objects {
                        //println(objects)
                    //if objects exist, loop through it
                    for object in objects {
                        //println(object)
                        //the key info we want from the object is the user that is followed. we will them followedUser and set it equal to an object that is following. the one that we are following is the user that is being followed.
                        var followedUser = object["following"] as! String
                        //once we have the user that is followed, we need to download the images that they have with a qury
                        println("one of the userIds of the people you are following is \(followedUser)")
                        
                //----- then lets get the posts for all those followers.
                        var getImages = PFQuery(className: "Post")
                        //and we want to find all the posts of the followedUser
                        
                        
                        getImages.whereKey("userId", equalTo: followedUser)
                        getImages.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                            if let objects = objects {
                                    //println(objects)
                                for object in objects {
                                    //println("one of the objects is \(object)")
                                    //we want to save these in our app, by creating arrarrys for them.
                                    //we can get the message from teh object and append it.
                                    self.messages.append(object["message"]! as! String)
                                    self.imageFiles.append(object["imageFile"]! as! PFFile)
                                    //lets also add to the array
                                    self.userNames.append(self.users[object["userId"] as! String]!)
                                    
                                    //now specifically we want to reload the data many times. because we have not is actually download the image, we only downloaded the file PFFile. the nice thing about this we can get the above results and populate our table, without downloading image which would have taken a long time.
                                    self.tableView.reloadData()
                                }
                                //println(self.users)
                                println(self.messages)
                                //println(self.userNames)
                                
                            } else {
                                println("there was a problem loading user id posts")
                            }
                        })
                    }
                } else {
                    println("there was a problem")
                    }
            }
            
        }
        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return userNames.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! Cell
            //not in the above we are using the new class "Cell" that we created
        //now we can access the image and the labels
        
        
        //lets actually download the image from parse now. using imageFiles.indexPath.row will access the pffile
        imageFiles[indexPath.row].getDataInBackgroundWithBlock { (data, error) -> Void in
            //above, the data is the image data we need. below is we are checking to see that a downloadedImage variable is made from UIImage, which is made from what we got returned from getDataInBackgroundWithBlock
            if let downloadedImage = UIImage(data: data!) {
                myCell.postedImage.image = downloadedImage
            }
                
            
        }
        
    
        myCell.userName.text = userNames[indexPath.row]
        myCell.message.text = messages[indexPath.row]
        
        return myCell
        
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
