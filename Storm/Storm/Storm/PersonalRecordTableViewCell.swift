//
//  PersonalRecordListViewCell.swift
//  Storm
//
//  Created by Vagrant on 2016. 4. 24..
//  Copyright © 2016년 Storm. All rights reserved.
//

import UIKit

class PersonalRecordTableViewCell: UITableViewCell {

    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var result: UILabel!
    @IBOutlet weak var gole: UILabel!
    @IBOutlet weak var assist: UILabel!
    @IBOutlet weak var mvp: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2
        self.profileImage.clipsToBounds = true
        self.profileImage.layer.masksToBounds = true;
        self.profileImage.layer.borderWidth = 0.5
        self.profileImage.layer.borderColor = UIColor.orange.cgColor
        self.profileImage.layer.zPosition = 1
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

}
