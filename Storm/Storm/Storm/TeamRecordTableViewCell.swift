//
//  CheckListViewCell.swift
//  Storm
//
//  Created by Vagrant on 2016. 4. 24..
//  Copyright © 2016년 Storm. All rights reserved.
//

import UIKit

class TeamRecordTableViewCell: UITableViewCell {

    
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var gameDayLabel: UILabel!
    @IBOutlet weak var gameGroundLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

}
