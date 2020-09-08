//
//  TaskTableCell.swift
//  Project-Scheduler
//
//  Created by user172177 on 5/11/20.
//  Copyright © 2020 MahelManjithaM. All rights reserved.
//

import Foundation
import UIKit

class TaskTableCell: UITableViewCell {
    
    var cellDelegate: TaskTableViewCellDelegate?
    var additionalNote: String = "Additional Note Not Included"

    @IBOutlet weak var taskNumberLabel: UILabel!
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var remainingDaysLabel: UILabel!
    @IBOutlet weak var remainingDaysProgressBar: LinearProgressBar!
    @IBOutlet weak var totalTaskProgressBar: CircularProgressBar!
  
    
    let now: Date = Date()
    let colours: Colours = Colours()
    let formatter: Formatter = Formatter()
    let calculations: Calculations = Calculations()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
     // Configure the view for the selected state
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func additionalNoteButtonClicked(_ sender: Any) {
        
        self.cellDelegate?.viewNotes(cell: self, sender: sender as! UIButton, data: additionalNote)
    }
    
    //Set task values in to the cell label and progressbar
    func commonInit(_ taskName: String, taskProgress: CGFloat, startDate: Date, endDate: Date, additionalNote: String, taskNo: Int) {
        
        let (daysLeft, hoursLeft, minutesLeft) = calculations.getTimeDiff(now, end: endDate)
        let remainingDaysPercentage = calculations.getRemainingTimePercentage(startDate, end: endDate)
        
        taskNameLabel.text = taskName
        startDateLabel.text = "Start Date is \(formatter.formatDate(startDate))"
        dueDateLabel.text = "End Date is \(formatter.formatDate(endDate))"
        remainingDaysLabel.text = "Due in \(daysLeft) Days \(hoursLeft) Hours \(minutesLeft) Minutes"
        
        //Task progress configurations
        DispatchQueue.main.async {
            let colours = self.colours.getProgressGradient(Int(taskProgress))
            self.totalTaskProgressBar.customSubtitle = "Completed"
            
            self.totalTaskProgressBar.startGradientColor = colours[0]
            self.totalTaskProgressBar.endGradientColor = colours[1]
            self.totalTaskProgressBar.progress = taskProgress / 100
        }
        
        //Task remaining days linear bar configurations
        DispatchQueue.main.async {
            let colours = self.colours.getProgressGradient(remainingDaysPercentage, negative: true)
            self.remainingDaysProgressBar.startGradientColor = colours[0]
            self.remainingDaysProgressBar.endGradientColor = colours[1]
            self.remainingDaysProgressBar.progress = CGFloat(remainingDaysPercentage) / 100
        }
        
        //Task number
        taskNumberLabel.text = "Task \(taskNo)"
        self.additionalNote = additionalNote
        
        //Task cell border color and border size
        taskNumberLabel.layer.borderColor = UIColor.white.cgColor
        taskNumberLabel.layer.borderWidth = 1.0
    }
}


protocol TaskTableViewCellDelegate {
    func viewNotes(cell: TaskTableCell, sender button: UIButton, data: String)
}

//Button layout configuration to enable button configuration in storyboard
@IBDesignable extension UIButton {

    @IBInspectable var borderWidthTaskCell: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }

    @IBInspectable var cornerRadiusTaskCell: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }

    @IBInspectable var borderColorTaskCell: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}

