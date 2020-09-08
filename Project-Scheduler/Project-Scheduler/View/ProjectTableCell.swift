//
//  ProjectTableCell.swift
//  Project-Scheduler
//
//  Created by user172177 on 5/10/20.
//  Copyright © 2020 MahelManjithaM. All rights reserved.
//

import Foundation
import UIKit

class ProjectTableCell: UITableViewCell {
    
    var cellDelegate: ProjectTableViewCellDelegate?
    var additionalNote: String = "Additional Note Not Included"
    
    @IBOutlet weak var academicLevelImage: UIImageView!
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // Configure the view for the selected state
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func clickedViewNoteButton(_ sender: Any) {
    self.cellDelegate?.customCell(cell: self, sender: sender as! UIButton, data: additionalNote)
    }
    
    //Set assessment informations in to the label and set related images 
    func commonInit(_ projectName: String, taskProgress: CGFloat, academicLevel: String, dueDate: Date, additionalNote: String) {
        
        var iconName = "ic_number_three"
        
        if academicLevel == "Level 3" {
            iconName = "ic_number_three"
        }else if academicLevel == "Level 4" {
            iconName = "ic_number_four"
        }else if academicLevel == "Level 5" {
            iconName = "ic_number_five"
        }else if academicLevel == "Level 6" {
            iconName = "ic_number_six"
        }else if academicLevel == "Level 7" {
            iconName = "ic_number_seven"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        
        academicLevelImage.image = UIImage(named: iconName)
        projectNameLabel.text = projectName
        dueDateLabel.text = "Due: \(formatter.string(from: dueDate))"
        self.additionalNote = additionalNote
    }
    
}
    
    protocol ProjectTableViewCellDelegate {
        func customCell(cell: ProjectTableCell, sender button: UIButton, data: String)
    }

    
    
    
    

