//
//  TeamRecordHeaderCell.swift
//  Storm
//
//  Created by Vagrant on 2016. 5. 2..
//  Copyright © 2016년 Storm. All rights reserved.
//

import UIKit

class TeamRecordHeaderCell: UITableViewHeaderFooterView{

    @IBOutlet weak var teamSearchText: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!


    //var pickerView : MonthYearPickerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        

        
        let pickerView = UIDatePicker()
        yearTextField.inputView = pickerView


        
    }
    
    

}
