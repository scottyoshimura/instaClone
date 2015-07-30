//
//  TableViewController.swift
//  ParseStarterProject
//
//  Created by Scott Yoshimura on 6/29/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//
// we created this table view controller, and assigned it 
// we now have this swift file to use as we need and make this page how we want it

// now we want to download the user list from Parse, and have an array that we store the user names in locally, and update the table view using that array

import UIKit
//lets import parse
import Parse

class TableViewController: UITableViewController {

    //lets go ahead and create an empty array for user names
    var usernames = [""]
    //and lets also store the userIDs, we want to see who is following who. we will use object id from parse.
    var userids = [""]
    //lets set up a global variable for when we want to sort the usernames later
    var sortedUserNames = [""]
    
    //lets set up an array of boolean variables, to use later when we want followers following other followers. note here that we are not creating an empty array, we are filling it with a value, just like the other arrays we haev already set up (they are not empty)
    var isFollowing = ["":false]
    
    //lets create a pull to refresh feature. note we want it to be force unrwapped when we use it
    var refresher: UIRefreshControl!
    //and lets create the function for the refresher
    func refresh () {
        
        //now lets create a query so that we can load the arrays
        var query = PFUser.query()
        
        //and lets start this, and find every user. we will return objects which are our users, and maybe an error
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            //lets see if objects exists
            if let users = objects {
                
                //lets clear the first record in the array because we created an  array with a blank record first
                self.usernames.removeAll(keepCapacity: true)
                self.userids.removeAll(keepCapacity: true)
                self.isFollowing.removeAll(keepCapacity: true)
                //and if the above happens we can use users as our AnyObject to loop through to get all of our users. and the main thing we want to do is update the user id and username arrays.
                
                for object in users {
                    //users is still an AnyObject type, so let's change it to a PFuser type. we have to do this before we can do anything with it with the parse library
                    if let user = object as? PFUser {
                        
                        //lets remove from the current user to the array
                        if user.objectId! != PFUser.currentUser()?.objectId {
                            
                            self.usernames.append(user.username!)
                            self.userids.append(user.objectId!)
                            //note that we force unwrap both these. we may want to do a check above to be certain it is there.
                            
                            //for each user in our table, we need to check if they are being followed by the current user. note we are querying the followers class name
                            var query = PFQuery(className: "followers")
                            
                            //and we will add two query keys to this query
                            //first we want see where the follower equals the PFUser current user's objectId
                            query.whereKey("follower",equalTo: PFUser.currentUser()!.objectId!)
                            //second we want the person that they are following
                            query.whereKey("following", equalTo: user.objectId!)
                            
                            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                                //below will check to see if objects is nil, if not, unwrap it
                                if let objects = objects {
                                    //if it exists, than the user must be following the other user. no need to check object id.
                                    
                                    //and lets check to see if objects is greater than 0. we want to actually see if something of value is returned. it will either be 1 or none
                                    if objects.count > 0 {
                                        
                                        //lets set the isFollowing to true
                                        self.isFollowing[user.objectId!] = true
                                    } else {
                                        //and if it is not true than it is false
                                        self.isFollowing[user.objectId!] = false
                                    }
                                }
                                
                                //lets check to make sure that isFollowing.count is equal to userNames.count
                                if self.isFollowing.count == self.usernames.count {
                                    
                                    //lets go ahead and sort the array alphabetically
                                    self.sortedUserNames = self.usernames.sorted { $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
                                    //println(self.sortedUserNames)
                                    //and now we need to reload the table view
                                    self.tableView.reloadData()
                                
                                    //now then lets close the refresh process
                                    self.refresher.endRefreshing()
                                    
                                }
                            })
                        }
                        
                        
                    }
                }
            }
            
            //println(self.usernames)
            //println(self.userids)
            
            
        })
        
        
        
        
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //when we are ready to use it (ie. in viewdid load), we will take refresher and set it to an empty UIRefreshControl. and then we will add various attributes to it
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        //then lets add a target to the controller. this is the code that will occure when the user activates the refresher sequence. we will point it to the viewController, the action is the name of the function that we want to run. for now we will call it refresh
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        //we will run the refresh function when the value has changed, which means someone has pulled down and initiated the refrefh function
        self.tableView.addSubview(refresher)
        
        //note we are programattically setting the title for this page
        self.title = "User List"
        
        refresh()


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

        // notify the table view the data has changed
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        //return usernames.count
        return self.sortedUserNames.count
        
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell

        //we want the index path item in the array for each cell
        
        cell.textLabel?.text = sortedUserNames[indexPath.row]
    
        //we will create a variable called followedObjectId that we got from userid of the user that has been tapped on, and we use that to see if the user is following that particular user
        let followedObjectId = userids[indexPath.row]
        
        if isFollowing[followedObjectId] ==  true {
            //and then, lets add a checkmark to the cell
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            
        }

        return cell
        
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    

    
    //the below will happen when the user taps on a cell
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //and lets update the table flag which indicates the user is following a particular user and we do that using accessory type once we have the cell. lets work out hte cell.
        var cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        //we know the above exists becuase the user has tapped on it
        
        let followedObjectId = userids[indexPath.row]
        
        //now we also want to be able unselect and unfollow each other. we will need to check wether or not if we want to follow the user or not.
        if isFollowing[followedObjectId] == false {
        
            //now what we want to do here is check to see if the user is following the person they select, if they already are,than they will unfollow them. if they are not, then follow them
            
            isFollowing[followedObjectId] = true
            //lets create the follow part by creating a pfobject. note, we created teh class followers over in Parse
            var following = PFObject(className: "followers")
            //each object of our class has two variables that we care about. following and follower.
            

            
            //and then, lets add a checkmark to the cell
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            
            
            //below we are saying, the following variable (or element) of following, is set to the userids' indexPath.row, the object id of the user they just tapped on.
            following["following"] = userids[indexPath.row]
            following["follower"] = PFUser.currentUser()?.objectId
            //lets save the update
            following.saveInBackground()
            
            
        }   else {
            
            isFollowing[followedObjectId] = false
            
            //and then, lets add a checkmark to the cell
            cell.accessoryType = UITableViewCellAccessoryType.None
            
            //for each user in our table, we need to check if they are being followed by the current user. note we are querying the followers class name
            var query = PFQuery(className: "followers")
            
            //and we will add two query keys to this query
            //first we want see where the follower equals the PFUser current user's objectId
            query.whereKey("follower", equalTo: PFUser.currentUser()!.objectId!)
            //second we want the person that they are following
            query.whereKey("following", equalTo: userids[indexPath.row])
                //we want the id of the person we just tapped on
            
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                //this will check to see if objects is nil, if not, unwrap it
                if let objects = objects {
                    //if it exists, than the user must be following the other user. no need to check object id.
                    
                    
                    //and in case there are more than one record in the database, we want to loop through them and delete
                    for object in objects{
                        
                        object.deleteInBackground()
                        
                    }
                }
                
            })
        }
        
    }

}
