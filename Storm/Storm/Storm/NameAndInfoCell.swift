//
//  NameAndInfoCell.swift
//  Storm
//
//  Created by Vagrant on 2016. 4. 12..
//  Copyright © 2016년 Storm. All rights reserved.
//

import UIKit

class NameAndInfoCell: UITableViewCell {
    var name: String = ""{
        didSet {
            if (name != oldValue){
                nameLabel.text = name
            }
        }
    }
    
    var check: String = ""{
        didSet{
            if (check != oldValue){
                checkLabel.text = check
            }
        }
    }
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var checkLabel: UILabel!
    
    //override func awakeFormNib() { }
    
    //override func setSelected(selectd:Bool, animated:Bool){}
        
    
}
