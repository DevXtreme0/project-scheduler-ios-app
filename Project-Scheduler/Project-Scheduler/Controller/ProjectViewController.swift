//
//  ProjectViewController.swift
//  Project-Scheduler
//
//  Created by user172177 on 5/10/20.
//  Copyright © 2020 MahelManjithaM. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import EventKit

class ProjectViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UNUserNotificationCenterDelegate {
    
    var projects: [NSManagedObject] = []
    var editingMode: Bool = false
    let now = Date();
    let formatter: Formatter = Formatter()
    let notificationCenter = UNUserNotificationCenter.current()
    
    @IBOutlet weak var includeToCalendarSwitch: UISwitch!
    @IBOutlet weak var moduleNameTextField: UITextField!
    @IBOutlet weak var assessmentNameTextField: UITextField!
    @IBOutlet weak var dueDateLebel: UILabel!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var moduleWeightTextField: UITextField!
    @IBOutlet weak var awardedMarkTextField: UITextField!
    @IBOutlet weak var additionalNoteTextView: UITextView!
    @IBOutlet weak var projectAddButton: UIBarButtonItem!
    @IBOutlet weak var academicLevelValueLabel: UILabel!
    @IBOutlet weak var academicLevelPicker: UIPickerView!
    
    var academicLevelType = ["Level 3","Level 4","Level 5","Level 6","Level 7"]
    
    var editingProject: Project? {
        
        didSet {
            
            // Update the view.
            editingMode = true
            configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        additionalNoteTextView.delegate = self
        
        // load typed data in to textbox
        self.loadInputWhenAppOpen()

        // Configure user notification center for assessment reminder
        notificationCenter.delegate = self
        
        academicLevelPicker.dataSource = self as! UIPickerViewDataSource
        academicLevelPicker.delegate = self as! UIPickerViewDelegate
        
        //set academic level in UIPickerView
        if academicLevelValueLabel.text?.contains("Level 3") == true{
            self.academicLevelPicker.selectRow(0, inComponent: 0, animated: true)
        } else if academicLevelValueLabel.text?.contains("Level 4") == true {
            self.academicLevelPicker.selectRow(1, inComponent: 0, animated: true)
        } else if academicLevelValueLabel.text?.contains("Level 5") == true {
            self.academicLevelPicker.selectRow(2, inComponent: 0, animated: true)
        } else if academicLevelValueLabel.text?.contains("Level 6") == true {
            self.academicLevelPicker.selectRow(3, inComponent: 0, animated: true)
        } else if academicLevelValueLabel.text?.contains("Level 7") == true {
            self.academicLevelPicker.selectRow(4, inComponent: 0, animated: true)
        }
    
        configureView()

    }

    func configureView() {
        
        //when assessment editing intiated screen title and submit button naming will change
        if editingMode {
            self.navigationItem.title = "Edit Assessment"
            self.navigationItem.rightBarButtonItem?.title = "Update"
        }
        
        // MARK: - Set update information
        //when task ediding initiated values will be set in the relevent items
        if let project = editingProject {
            
            if let includeToCalendar = includeToCalendarSwitch {
                includeToCalendar.setOn((editingProject?.includeToCalendar)!, animated: true)
            }
            if let academicLevel = academicLevelValueLabel {
                academicLevel.text = editingProject?.academicLevel
            }
            if let academicLevel = academicLevelValueLabel {
                academicLevel.text = (editingProject?.academicLevel)!
            }
            if let moduleName = moduleNameTextField {
                moduleName.text = editingProject?.moduleName
            }
            if let assessmentName = assessmentNameTextField {
                assessmentName.text = editingProject?.assessmentName
            }
            if let moduleWeight = moduleWeightTextField {
                moduleWeight.text = "\(editingProject!.moduleWeight)"
            }
            if let awardedMark = awardedMarkTextField {
                awardedMark.text = "\(editingProject!.awardedMark)"
            }
            if let additionalNote = additionalNoteTextView {
                additionalNote.text = editingProject?.additionalNote
            }
            if let dueDate = dueDateLebel {
                 dueDate.text = formatter.formatDate(editingProject?.dueDate as! Date)
            }
            if let dueDatePicker = dueDatePicker {
                dueDatePicker.date = editingProject?.dueDate as! Date
            }
            
        }
    }
    
    //When clicked Cancel button
    @IBAction func handleCancelButtonClick(_ sender: UIBarButtonItem) {
        dismissAddProjectPopOver()
    }
    
    //Clear all data and set to defaults
       @IBAction func onClearPreviousData(_ sender: UIButton) {
           
           moduleNameTextField.text = ""
           assessmentNameTextField.text = ""
           moduleWeightTextField.text = ""
           awardedMarkTextField.text = ""
           academicLevelValueLabel.text = "Level 3"
           additionalNoteTextView.text = "Additional Note"
           additionalNoteTextView.textColor = UIColor.lightGray
           academicLevelPicker.selectRow(0, inComponent: 0, animated: true)
           dueDatePicker.setDate(now, animated: true)
           dueDateLebel.text = formatter.formatDate(now)
       }
    
    // MARK: - Add+Calendar+Reminder
    @IBAction func handleAddButtonClick(_ sender: UIBarButtonItem) {
        
        // Check value with boolean validate function. if true - add data If not - display error message
        if moduleNameTextField.text!.isEmpty || assessmentNameTextField.text!.isEmpty || moduleWeightTextField.text!.isEmpty || awardedMarkTextField.text!.isEmpty ||
        moduleWeightTextField.text!.isEmpty || awardedMarkTextField.text!.isEmpty {
            
            let alertController = UIAlertController(title: "Alert", message: "Please enter compulsory information. Except additional note.", preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                
            }
            
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true, completion:nil)
           
            
            
        } else if Int(moduleWeightTextField.text!) == nil || Int(awardedMarkTextField.text!) == nil {
            
            let alertController = UIAlertController(title: "Alert", message: "Only numbers allowed in module weight & awarded mark.", preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                
            }
            
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true, completion:nil)
            
            
        } else {
            
            var calendarIdentifier = ""
            var addedToCalendar = false
            var eventDeleted = false
            let eventStore = EKEventStore()
            var academicLevel = academicLevelValueLabel.text
            let moduleName = moduleNameTextField.text
            let assessmentName = assessmentNameTextField.text
            let moduleWeight = Int16(moduleWeightTextField.text!)
            let awardedMark = Int16(awardedMarkTextField.text!)
            let dueDate = dueDatePicker.date
            let additionalNote = additionalNoteTextView.text
            let includeToCalendar = Bool(includeToCalendarSwitch.isOn)
            let includeToReminder = Bool(includeToCalendarSwitch.isOn)
            
            //Handle special UIApplication states
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            
            //Creation and management of the Core Data stack by handling the creation of the managed object model
            let managedContext = appDelegate.persistentContainer.viewContext
            
            //Managed core data under "Project" class
            let entity = NSEntityDescription.entity(forEntityName: "Project", in: managedContext)!
            
            // implements the behavior required of a Core Data model object
            var project = NSManagedObject()
                        
            if editingMode {
                
                project = (editingProject as? Project)!
                
            } else {
                
                project = NSManagedObject(entity: entity, insertInto: managedContext)
            }
            
            //Add, upadte calendar event in the calendar app
            if includeToCalendar {
                if editingMode {
                    if let project = editingProject {
                        if !project.includeToCalendar {
                            if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
                                eventStore.requestAccess(to: .event, completion: {
                                    granted, error in
                                    calendarIdentifier = self.createEvent(eventStore, title: assessmentName!, startDate: self.now, dueDate: dueDate)
                                })
                            } else {
                                calendarIdentifier = createEvent(eventStore, title: assessmentName!, startDate: now, dueDate: dueDate)
                            }
                        }
                    }
                } else {
                    if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
                        eventStore.requestAccess(to: .event, completion: {
                            granted, error in
                            calendarIdentifier = self.createEvent(eventStore, title: assessmentName!, startDate: self.now, dueDate: dueDate)
                        })
                    } else {
                        calendarIdentifier = createEvent(eventStore, title: assessmentName!, startDate: self.now, dueDate: dueDate)
                    }
                }
                
                //Check whether calendar event already exist or not, if not add calendar event
                if calendarIdentifier != "" {
                    addedToCalendar = true
                }
            } else {
                if editingMode {
                    if let project = editingProject {
                        if project.includeToCalendar {
                            if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
                                eventStore.requestAccess(to: .event, completion: { (granted, error) -> Void in
                                    eventDeleted = self.deleteEvent(eventStore, eventIdentifier: project.calendarIdentifier!)
                                })
                            } else {
                                eventDeleted = deleteEvent(eventStore, eventIdentifier: project.calendarIdentifier!)
                            }
                        }
                    }
                }
            }
            
            //Add reminder when notification permission authorized
            if includeToReminder {
                notificationCenter.getNotificationSettings { (notificationSettings) in
                    switch notificationSettings.authorizationStatus {
                    case .notDetermined:
                        self.requestAuthorization(completionHandler: { (success) in
                            guard success else { return }
      
                            // Schedule Local Notification
                            self.scheduleLocalNotification("Assessment Reminder!", subtitle: "Deadline Reminder for assessment '\(assessmentName!)'.", body: "which was due on \(self.formatter.formatDate(dueDate)).", date: dueDate)
                                
                            })
                    case .authorized:

                        // Schedule Reminder
                        self.scheduleLocalNotification("Assessment Reminder!", subtitle: "Deadline Reminder for assessement '\(assessmentName!)'.", body: "which was due on \(self.formatter.formatDate(dueDate)).", date: dueDate)
                        
                    case .denied:
                        
                        //when access denied to show alert
                        let alertController = UIAlertController(title: "Alert", message: "Application Not Allowed to Display Notifications. Please go to settings and allow notification for this app.", preferredStyle: .alert)
                    case .provisional:
                        
                        //when access denied to show alert
                        let alertController = UIAlertController(title: "Alert", message: "Application Not Allowed to Display Notifications. Please go to settings and allow notification for this app.", preferredStyle: .alert)
                    }
                }
            }
            
            // Handle event creation state
            if eventDeleted {
                addedToCalendar = false
            }
            
            // Set values to core data attributes
            project.setValue(moduleName, forKeyPath: "moduleName")
            project.setValue(assessmentName, forKeyPath: "assessmentName")
            project.setValue(additionalNote, forKeyPath: "additionalNote")
            project.setValue(moduleWeight, forKeyPath: "moduleWeight")
            project.setValue(awardedMark, forKeyPath: "awardedMark")
            
            if editingMode {
                
                project.setValue(editingProject?.startDate, forKeyPath: "startDate")
                
            } else {
                
                project.setValue(now, forKeyPath: "startDate")
                
            }
            
            project.setValue(dueDate, forKeyPath: "dueDate")
            project.setValue(academicLevel, forKeyPath: "academicLevel")
            project.setValue(addedToCalendar, forKeyPath: "includeToCalendar")
            project.setValue(calendarIdentifier, forKey: "calendarIdentifier")
            
            // Assessment will saved, if not display error message
            do {
                
                try managedContext.save()
                projects.append(project)
                
            } catch _ as NSError {
                
                let alert = UIAlertController(title: "Error", message: "An error occured while saving the assessment.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
    
                // Dismiss PopOver
                dismissAddProjectPopOver()
    }
                let alert = UIAlertController(title: "Alert", message: "Assessment saved successfully.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
        
}
    // Creates an event in the EKEventStore
    func createEvent(_ eventStore: EKEventStore, title: String, startDate: Date, dueDate: Date) -> String {
        let event = EKEvent(eventStore: eventStore)
        var identifier = ""
        event.title = title
        event.startDate = startDate
        event.endDate = dueDate
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            
            try eventStore.save(event, span: .thisEvent)
            identifier = event.eventIdentifier
            
        } catch {
            
            let alert = UIAlertController(title: "Error", message: "Calendar event could not be created!", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        
        return identifier
    }
    
    // Removes an event from the EKEventStore
    func deleteEvent(_ eventStore: EKEventStore, eventIdentifier: String) -> Bool {
        var sucess = false
        let eventToRemove = eventStore.event(withIdentifier: eventIdentifier)
        if eventToRemove != nil {
            do {
                
                try eventStore.remove(eventToRemove!, span: .thisEvent)
                sucess = true
                
            } catch {
                
                let alert = UIAlertController(title: "Error", message: "Calendar event could not be deleted!", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                sucess = false
                
            }
        }
        return sucess
    }
    
    func scheduleLocalNotification(_ title: String, subtitle: String, body: String, date: Date) {
        // Create Notification Content
        let notificationContent = UNMutableNotificationContent()
        let identifier = "\(UUID().uuidString)"

        // Configure Notification Content
        notificationContent.title = title
        notificationContent.subtitle = subtitle
        notificationContent.body = body

        // Add Trigger
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        // Create Notification Request
        let notificationRequest = UNNotificationRequest(identifier: identifier, content: notificationContent, trigger: trigger)

        // Add Request to User Notification Center
        notificationCenter.add(notificationRequest) { (error) in
            if let error = error {
                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
            }
        }
    }
    
    func requestAuthorization(completionHandler: @escaping (_ success: Bool) -> ()) {
        // Request Authorization
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }
            completionHandler(success)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return academicLevelType.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return academicLevelType[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        academicLevelValueLabel.text = academicLevelType[row]
        
      //set selected academic level in label
        academicLevelValueLabel.text = academicLevelType[row]

     //get user selected value for persistence purpose
       let defaultValue = UserDefaults.standard
       defaultValue.set(academicLevelValueLabel.text, forKey:"academic_level")
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //If assessment name text field triggered enable add button
    @IBAction func handleProjectNameChange(_ sender: Any) {
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        //get user typed value to persistence purpose
        let defaultValue = UserDefaults.standard
        defaultValue.set(additionalNoteTextView.text, forKey:"additional_note")
        
        if textView.text.isEmpty {
            textView.text = "Additional Note"
            textView.textColor = UIColor.lightGray
        }
    }
    
    // Dismiss Popover
    func dismissAddProjectPopOver() {
        dismiss(animated: true, completion: nil)
        popoverPresentationController?.delegate?.popoverPresentationControllerDidDismissPopover?(popoverPresentationController!)
    }

    // MARK: - Get User typed data
    
    @IBAction func moduleNameDefaultSave(_ sender: UITextField) {
        
        //get user selected value in temporary - persistance purpose
        let defaultValue = UserDefaults.standard
        defaultValue.set(moduleNameTextField.text, forKey:"module_name")
    }
    
    @IBAction func assessmentNameDefaultSave(_ sender: UITextField) {
        
        //get user selected value in temporary - persistance purpose
        let defaultValue = UserDefaults.standard
        defaultValue.set(assessmentNameTextField.text, forKey:"assessment_name")
    }
    
    @IBAction func moduleWeightDefaultSave(_ sender: UITextField) {
        
       
        //get user selected value in temporary - persistance purpose
        let defaultValue = UserDefaults.standard
        defaultValue.set(moduleWeightTextField.text, forKey:"module_weight")
      
    }
    
    @IBAction func handleDateChange(_ sender: UIDatePicker) {
        
        //set user selected value in date picket to label
        dueDateLebel.text = formatter.formatDate(sender.date)
        
        //get user selected value for persistence purpose
        let defaultValue = UserDefaults.standard
        defaultValue.set(dueDatePicker.date, forKey:"due_date")
        defaultValue.set(dueDateLebel.text, forKey:"due_date_text")
    }
    
    @IBAction func awardedMarkDefaultSave(_ sender: Any) {
        
        //get user selected value in temporary - persistance purpose
        let defaultValue = UserDefaults.standard
        defaultValue.set(awardedMarkTextField.text, forKey:"awarded_mark")
    }
    
    
    // MARK: - Set previuos data
    // load data to the text boxes when app reopen
      func loadInputWhenAppOpen(){
        
          let defaultValue =  UserDefaults.standard
        
          //recieved saved data from UserDefaults
          let moduleNameDefault = defaultValue.string(forKey:"module_name")
          let assessmentNameDefault = defaultValue.string(forKey:"assessment_name")
          let moduleWeightDefault = defaultValue.integer(forKey:"module_weight")
          let awardedMarkDefault = defaultValue.integer(forKey:"awarded_mark")
          let academicLevelDefault = defaultValue.string(forKey:"academic_level")

          let dueDateDefault = defaultValue.object(forKey: "due_date") as? Date

        //set and select default value when failed to capture previouse values
        if defaultValue.object(forKey: "due_date") == nil || dueDateDefault == nil  {

        dueDatePicker.minimumDate = now
        var time = Date()
        time.addTimeInterval(TimeInterval(60.00 * 60.00))
        dueDateLebel.text = formatter.formatDate(time)
            
        } else
        {
         let dueDateDefault = defaultValue.object(forKey: "due_date") as! Date
         let dueDateTextDefault = defaultValue.string(forKey: "due_date_text")
   
         //set default value
         dueDatePicker.date = dueDateDefault
         dueDateLebel.text = dueDateTextDefault
            
        }
        
        let additionalNoteDefault = defaultValue.string(forKey: "additional_note")
        
        //set default value
        moduleNameTextField.text = moduleNameDefault
        assessmentNameTextField.text = assessmentNameDefault
        
        if moduleWeightDefault == 0 && awardedMarkDefault == 0 {
            
            print("")
            
        } else if moduleWeightDefault == 0 {
        
            awardedMarkTextField.text = String(awardedMarkDefault)
            
        } else if awardedMarkDefault == 0 {
            
            moduleWeightTextField.text = String(moduleWeightDefault)
            
        } else {
            
        moduleWeightTextField.text = String(moduleWeightDefault)
        awardedMarkTextField.text = String(awardedMarkDefault)
            
        }
        
        academicLevelValueLabel.text = academicLevelDefault
        
        //set saved value or set default value when additional note not available
        if additionalNoteDefault == nil {
            
        additionalNoteTextView.text = "Additional Note"
        additionalNoteTextView.textColor = UIColor.lightGray
            
        }else {
            
        additionalNoteTextView.text = additionalNoteDefault
            
        }

        //set default value when academic level is not selected
        if academicLevelDefault == "" || academicLevelDefault == nil {
            
        academicLevelValueLabel.text = "Level 3"
            
        }
        
      }
    
    
}

