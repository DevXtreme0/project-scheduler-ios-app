//
//  TaskViewController.swift
//  Project-Scheduler
//
//  Created by user172177 on 5/11/20.
//  Copyright © 2020 MahelManjithaM. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import EventKit

class TaskViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UITextViewDelegate, UNUserNotificationCenterDelegate {
    
    var tasks: [NSManagedObject] = []
    let dateFormatter : DateFormatter = DateFormatter()
    var selectedProject: Project?
    var editingMode: Bool = false
    let now = Date()
    let formatter: Formatter = Formatter()
    let notificationCenter = UNUserNotificationCenter.current()
    
    
    @IBOutlet weak var includeToCalendarSwitch: UISwitch!
    @IBOutlet weak var taskNameTextField: UITextField!
    @IBOutlet weak var additionalNoteTextView: UITextView!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var taskAddButton: UIBarButtonItem!
    @IBOutlet weak var progressPercentageLabel: UILabel!
    @IBOutlet weak var progressSliderLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var progressValueLabel: UILabel!
    
    
    var editingTask: Task? {
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

        if progressValueLabel == nil || progressValueLabel.text == "0" {
            
        //set progress slider value to zero
        progressSlider.value = 0.0
            
        }else{
            
        //set progress slider value to prevously selected value
        progressSlider.value = Float(progressValueLabel.text!)!
        progressPercentageLabel.text = "\(String(format: "%.0f", progressSlider.value*100))%"
        progressSliderLabel.text = "\(String(format: "%.0f", progressSlider.value*100))% Completed"
            
        }
        
        // Configure User Notification Center
        notificationCenter.delegate = self
        
        // set end date picker maximum date to project end date
        endDatePicker.maximumDate = selectedProject!.dueDate as? Date
    
        configureView()
        
        // Disable add button
        toggleAddButtonEnability()
    }
    
    //when task editing intiated screen title and submit button naming will change
    func configureView() {
        
        if editingMode {
            
            self.navigationItem.title = "Edit Task"
            self.navigationItem.rightBarButtonItem?.title = "Update"
            
        }
        
        // MARK: - Set update information
        //when task ediding initiated values will be set in the relevent items
        if let task = editingTask {
            
            if let taskNameTextField = taskNameTextField {
                taskNameTextField.text = task.taskName
            }
            if let additionalNoteTextView = additionalNoteTextView {
                additionalNoteTextView.text = task.additionalNote
            }
            if let startDateLabel = startDateLabel {
                startDateLabel.text = formatter.formatDate(task.startDate as! Date)
            }
            if let startDatePicker = startDatePicker {
                startDatePicker.date = task.startDate as! Date
            }
            if let endDateLabel = endDateLabel {
                endDateLabel.text = formatter.formatDate(task.endDate as! Date)
            }
            if let endDatePicker = endDatePicker {
                endDatePicker.date = task.endDate as! Date
            }
            if let includeToCalendarSwitch = includeToCalendarSwitch {
                includeToCalendarSwitch.setOn(task.includeToCalendar, animated: true)
            }
            if let progressSliderLabel = progressSliderLabel {
                progressSliderLabel.text = "\(Int(task.progress))% Completed"
            }
            if let progressPercentageLabel = progressPercentageLabel {
                progressPercentageLabel.text = "\(Int(task.progress))%"
            }
            if let progressSlider = progressSlider {
                progressSlider.value = task.progress / 100
            }
        }
    }
 
    //When clicked Cancel button
    @IBAction func handleCancelButtonClick(_ sender: UIBarButtonItem) {
        dismissAddTaskPopOver()
    }
    
    // MARK: - Add+Calendar+Reminder
    @IBAction func handleAddButtonClick(_ sender: UIBarButtonItem) {
        
        // Check value with boolean validate function. if true - add data If not - display error message
        if validate() {
            
            let taskName = taskNameTextField.text
            let endDate = endDatePicker.date
            var calendarIdentifier = ""
            var addedToCalendar = false
            var eventDeleted = false
            let eventStore = EKEventStore()
            let startDate = startDatePicker.date
            let progress = Float(progressSlider.value * 100)
            let includeToCalendar = Bool(includeToCalendarSwitch.isOn)
            let includeToReminder = Bool(includeToCalendarSwitch.isOn)
            
            //Handle special UIApplication states
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            
            //Creation and management of the Core Data stack by handling the creation of the managed object model
            let managedContext = appDelegate.persistentContainer.viewContext
            
            //Managed core data under "Task" class
            let entity = NSEntityDescription.entity(forEntityName: "Task", in: managedContext)!
            
            // implements the behavior required of a Core Data model object
            var task = NSManagedObject()
            
            if editingMode {
                
                task = (editingTask as? Task)!
                
            } else {
                
                task = NSManagedObject(entity: entity, insertInto: managedContext)
            }
            
            //Add, upadte calendar event in the calendar app
            if includeToCalendar {
                if editingMode {
                    if let project = editingTask {
                        if !project.includeToCalendar {
                            if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
                                eventStore.requestAccess(to: .event, completion: {
                                    granted, error in
                                    calendarIdentifier = self.createEvent(eventStore, title: taskName!, startDate: self.now, endDate: endDate)
                                })
                            } else {
                                calendarIdentifier = createEvent(eventStore, title: taskName!, startDate: now, endDate: endDate)
                            }
                        }
                    }
                } else {
                    if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
                        eventStore.requestAccess(to: .event, completion: {
                            granted, error in
                            calendarIdentifier = self.createEvent(eventStore, title: taskName!, startDate: self.now, endDate: endDate)
                        })
                    } else {
                        calendarIdentifier = createEvent(eventStore, title: taskName!, startDate: now, endDate: endDate)
                    }
                }
                
                //Check whether calendar event already exist or not, if not add calendar event
                if calendarIdentifier != "" {
                    addedToCalendar = true
                }
            } else {
                if editingMode {
                    if let project = editingTask {
                        if project.includeToCalendar {
                            if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
                                eventStore.requestAccess(to: .event, completion: { (granted, error) -> Void in
                                    eventDeleted = self.deleteEvent(eventStore, eventIdentifier: project.calendarIdentifier!)
                                })
                            } else {
//                                eventDeleted = deleteEvent(eventStore, eventIdentifier: project.calendarIdentifier!)
                            }
                        }
                    }
                }
                //tableView.endUpdates()
            }
            
            //Add reminder when notification permission authorized
            if includeToReminder {
                notificationCenter.getNotificationSettings { (notificationSettings) in
                    switch notificationSettings.authorizationStatus {
                    case .notDetermined:
                        self.requestAuthorization(completionHandler: { (success) in
                            guard success else { return }
 
                            // Schedule Local Notification
                            self.scheduleLocalNotification("Task Reminder!", subtitle: "Deadline Reminder for task '\(taskName!)'.", body: "which was due on \(self.formatter.formatDate(endDate)).", date: endDate)
                                
                            })
                        
                    case .authorized:

                        // Schedule Reminder
                        self.scheduleLocalNotification("Task Reminder!", subtitle: "Deadline Reminder for task '\(taskName!)'.", body: "which was due on \(self.formatter.formatDate(endDate)).", date: endDate)
                        
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
            task.setValue(taskName, forKeyPath: "taskName")
            task.setValue(additionalNoteTextView.text, forKeyPath: "additionalNote")
            task.setValue(startDate, forKeyPath: "startDate")
            task.setValue(endDate, forKeyPath: "endDate")
            task.setValue(includeToReminder, forKeyPath: "includeToCalendar")
            task.setValue(progress, forKey: "progress")
            
            //Selected project, "task add" core data function will add above set values
            selectedProject?.addToTask((task as? Task)!)
            
            // Task will saved to the project, if not display error message
            do {
                
                try managedContext.save()
                tasks.append(task)
                
            } catch _ as NSError {
                
                let alert = UIAlertController(title: "Error", message: "An error occured while saving the task.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
        } else {
            
            let alert = UIAlertController(title: "Error", message: "Please fill the required fields.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        
        
        // Dismiss PopOver
        dismissAddTaskPopOver()
    }
    
    // Creates an event in the EKEventStore - Calendar
    func createEvent(_ eventStore: EKEventStore, title: String, startDate: Date, endDate: Date) -> String {
        let event = EKEvent(eventStore: eventStore)
        var identifier = ""
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        // Save event in calendar, if not display error alert
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
        
        // Delete event from calendar if not display error alert
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

    //If task name text field triggered enable add button
    @IBAction func handleTaskNameChange(_ sender: Any) {
        toggleAddButtonEnability()
    }
    
    //Change label value according to progress slider value changes and save its stats in core data
    @IBAction func handleProgressChange(_ sender: UISlider) {
        
        //change label value according to the progress slider value change
        let progress = Int(sender.value * 100)
        progressPercentageLabel.text = "\(progress)%"
        progressSliderLabel.text = "\(progress)% Completed"
        
        //get user selected value in temporary - persistance purpose
        let defaultValue = UserDefaults.standard
        defaultValue.set(progress, forKey:"task_progress")
    }
    
    //Clear previouse data or typed dat when "clear" button clicked and set to default state
    @IBAction func onClearPreviousData(_ sender: UIButton) {
        
        taskNameTextField.text = ""
        additionalNoteTextView.text = ""
        additionalNoteTextView.text = "Additional Note"
        additionalNoteTextView.textColor = UIColor.lightGray
        progressSlider.value = 0
        progressValueLabel.text = "0"
        progressPercentageLabel.text = "0%"
        progressSliderLabel.text = "0% Completed"
        
        // Set start date to current
        startDatePicker.minimumDate = now
        startDateLabel.text = formatter.formatDate(now)
        startDatePicker.setDate(now, animated: true)
        
        // Set end date to one minute ahead of current time
        var time = Date()
        time.addTimeInterval(TimeInterval(60.00))
        endDateLabel.text = formatter.formatDate(time)
        endDatePicker.minimumDate = time
        endDatePicker.setDate(time, animated: true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray {
            
            textView.text = nil
            textView.textColor = UIColor.black
        }
        
        toggleAddButtonEnability()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        toggleAddButtonEnability()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text.isEmpty {
            
            textView.text = "Additional Note"
            textView.textColor = UIColor.lightGray
        }
        
        //get user selected value in temporary - persistance purpose
        let defaultValue = UserDefaults.standard
        defaultValue.set(additionalNoteTextView.text, forKey:"task_additional_note")
        
        toggleAddButtonEnability()
    }
    
    // Handles the add button enable state
    func toggleAddButtonEnability() {
        
        if validate() {
            
            taskAddButton.isEnabled = true;
            
        } else {
            
            taskAddButton.isEnabled = false;
        }
    }
    
    // Dismiss Popover
    func dismissAddTaskPopOver() {
        
        dismiss(animated: true, completion: nil)
        popoverPresentationController?.delegate?
            .popoverPresentationControllerDidDismissPopover?(popoverPresentationController!)
    }
    
    // Check if the required fields are empty or not
    func validate() -> Bool {
        
        if !(taskNameTextField.text?.isEmpty)! && !(additionalNoteTextView.text == "Additional Note") && !(additionalNoteTextView.text?.isEmpty)! {
            return true
        }
        return false
    }
    
    
    // MARK: - Get User typed data
    //Change label value according to date picker value and save stats in userDefaults
    @IBAction func handleStartDateChange(_ sender: UIDatePicker) {
        
               //set date in the label according to the date paicker value
               startDateLabel.text = formatter.formatDate(sender.date)
               
               // Set end date minimum to one minute ahead the start date
               let endDate = sender.date.addingTimeInterval(TimeInterval(60.00))
               endDatePicker.minimumDate = endDate
               endDateLabel.text = formatter.formatDate(endDate)
               
               //get user selected value in temporary - persistance purpose
               let defaultValue = UserDefaults.standard
               defaultValue.set(startDatePicker.date, forKey:"start_date")
               defaultValue.set(startDateLabel.text, forKey:"start_date_text")
    }
    
    //Change label value according to date picker value and save stats in userDefaults
    @IBAction func handleEndDateChange(_ sender: UIDatePicker) {
        
        //set date in the label according to the date paicker value
        endDateLabel.text = formatter.formatDate(sender.date)
        
        // Set start date maximum to one minute before the end date
        startDatePicker.maximumDate = sender.date.addingTimeInterval(-TimeInterval(60.00))
        
        //get user selected value in temporary - persistance purpose
        let defaultValue = UserDefaults.standard
        defaultValue.set(endDatePicker.date, forKey:"end_date")
        defaultValue.set(endDateLabel.text, forKey:"end_date_text")
    }
    
    @IBAction func taskNameDefaultSave(_ sender: UITextField) {
        
          //get user selected value in temporary - persistance purpose
          let defaultValue = UserDefaults.standard
          defaultValue.set(taskNameTextField.text, forKey:"task_name")
      }
      
    @IBAction func taskProgressDefaultSave(_ sender: UISlider) {
        
        //get user selected value in temporary - persistance purpose
        let defaultValue = UserDefaults.standard
        defaultValue.set(progressSlider.value, forKey:"task_progress")
    }
    
     // MARK: - Set previous data 
      // load data to the text boxes when task add or edit opens
         func loadInputWhenAppOpen(){
          
             let defaultValue =  UserDefaults.standard
          
             //recieved saved data from UserDefaults
             let taskNameDefault = defaultValue.string(forKey:"task_name")
             let taskAdditionalNoteDefault = defaultValue.string(forKey: "task_additional_note")
             let taskProgressDefault = defaultValue.string(forKey: "task_progress")
            
              //set user selected value in temporary - persistance purpose
              taskNameTextField.text = taskNameDefault
          
          if taskAdditionalNoteDefault == nil {
              
              
              additionalNoteTextView.text = "Additional Note"
              additionalNoteTextView.textColor = UIColor.lightGray
              
          }else {
              
              //set user selected value in temporary - persistance purpose
              additionalNoteTextView.text = taskAdditionalNoteDefault
              
          }
          
          if defaultValue.object(forKey: "start_date") == nil{
              
              
             startDatePicker.minimumDate = now
             startDateLabel.text = formatter.formatDate(now)
              
          }else {
              
            let startDateDefault = defaultValue.object(forKey: "start_date") as! Date
            let startDateTextDefault = defaultValue.string(forKey: "start_date_text")
              
              //set user selected value in temporary - persistance purpose
              startDatePicker.date = startDateDefault
              startDateLabel.text = startDateTextDefault
          }
          if defaultValue.object(forKey: "end_date") == nil{
              
              // set end date picker maximum date to project end date
              endDatePicker.maximumDate = selectedProject!.dueDate as? Date
              var time = Date()
              time.addTimeInterval(TimeInterval(60.00))
              endDateLabel.text = formatter.formatDate(time)
              endDatePicker.minimumDate = time
              
          }else{
            let endDateDefault = defaultValue.object(forKey: "end_date") as! Date
            let endDateTextDefault = defaultValue.string(forKey: "end_date_text")
              
              endDatePicker.date = endDateDefault
              endDateLabel.text = endDateTextDefault
          }
         
          if taskProgressDefault == nil {
              progressSlider.value = 0.0
              progressValueLabel.text = "0"
              progressPercentageLabel.text = "0%"
              progressSliderLabel.text = "0% Completed"
          }else {
              progressValueLabel.text = taskProgressDefault
              progressPercentageLabel.text = "\(String(taskProgressDefault!))%"
              progressSliderLabel.text = "\(String(taskProgressDefault!))% Completed"
         }
    }
}

