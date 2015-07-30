//
//  Cell.swift
//  ParseStarterProject
//
//  Created by Scott Yoshimura on 7/28/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class Cell: UITableViewCell {
    
        //we want to set up each outlet for the cell we want to control
        @IBOutlet weak var postedImage: UIImageView!
        @IBOutlet weak var userName: UILabel!
        @IBOutlet weak var message: UILabel!

}
