//
//  ChkTableViewCell.swift
//  Storm
//
//  Created by Vagrant on 2016. 4. 24..
//  Copyright © 2016년 Storm. All rights reserved.
//

import UIKit

class CheckListTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkLabel: UILabel!
    @IBOutlet weak var checkTimeLabel: UILabel!
    @IBOutlet weak var inPlayRatio: UIProgressView!
    @IBOutlet weak var inPlayRatioLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
  
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2
        self.profileImage.clipsToBounds = true
        self.profileImage.layer.masksToBounds = true;
        self.profileImage.layer.borderWidth = 0.5
        self.profileImage.layer.borderColor = UIColor.orange.cgColor
        self.profileImage.layer.zPosition = 1
        
        self.inPlayRatio.progress = 0.0
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        //self.backgroundColor = UIColor.grayColor()
        // Configure the view for the selected state
    }

}
