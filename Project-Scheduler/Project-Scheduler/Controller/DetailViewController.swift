//
//  DetailViewController.swift
//  Project-Scheduler
//
//  Created by user172165 on 5/4/20.
//  Copyright © 2020 MahelManjithaM. All rights reserved.
//

import UIKit
import CoreData
import EventKit

class DetailViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    
    
    @IBOutlet weak var projectProgressBar: CircularProgressBar!
    @IBOutlet weak var remainingDaysProgressBar: CircularProgressBar!
    @IBOutlet weak var taskTable: UITableView!
    @IBOutlet weak var academicLevelLabel: UILabel!
    @IBOutlet weak var moduleNameLabel: UILabel!
    @IBOutlet weak var assessmentNameLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var projectInfoView: UIStackView!
    @IBOutlet weak var taskAddButton: UIBarButtonItem!
    @IBOutlet weak var taskEditButton: UIBarButtonItem!
    @IBOutlet weak var includeToCalendarButton: UIBarButtonItem!
    @IBOutlet weak var moduleWeightLabel: UILabel!
    @IBOutlet weak var awardedMarkLabel: UILabel!
    
    
        let formatter: Formatter = Formatter()
        let calculations: Calculations = Calculations()
        let colours: Colours = Colours()
    
        var detailViewController: DetailViewController? = nil
        var managedObjectContext: NSManagedObjectContext? = nil
        
        let now = Date()
        
        var selectedProject: Project? {
            didSet {
                // Update the view.
                configureView()
            }
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // Configure the view
            configureView()
            
            //Handle special UIApplication states
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            
            //Creation and management of the Core Data stack by handling the creation of the managed object model
            self.managedObjectContext = appDelegate.persistentContainer.viewContext
            
            // initializing the custom cell
            let nibName = UINib(nibName: "TaskTableCell", bundle: nil)
            taskTable.register(nibName, forCellReuseIdentifier: "TaskCell")
        }
        
        override func viewWillAppear(_ animated: Bool) {
            
            super.viewWillAppear(animated)
            
            // Set the default selected row
            let indexPath = IndexPath(row: 0, section: 0)
            if taskTable.hasRowAtIndexPath(indexPath: indexPath as NSIndexPath) {
                taskTable.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
            }
        }
        
        @objc
        func insertNewObject(_ sender: Any) {
            let context = self.fetchedResultsController.managedObjectContext
            let newTask = Task(context: context)
                        
            // Save the context.
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        
        // MARK: - Info for Detail Custom View
        func configureView() {
            
            // Update the user interface for the detail labels.
            if let project = selectedProject {
                
                if let moduleNameLabel = moduleNameLabel {
                    moduleNameLabel.text = project.moduleName
                }
                if let assessmentNameLabel = assessmentNameLabel {
                    assessmentNameLabel.text = project.assessmentName
                }
                if let dueDateLabel = dueDateLabel {
                    dueDateLabel.text = "Due Date \(formatter.formatDate(project.dueDate as! Date))"
                }
                if let academicLevelLabel = academicLevelLabel {
                    academicLevelLabel.text = "Academic \(NSString(string: project.academicLevel!))"
                }
                if let moduleWeightLabel = moduleWeightLabel {
                    moduleWeightLabel.text = "Module Weight \(String(project.moduleWeight))%"
                }
                if let awardedMarkLabel = awardedMarkLabel {
                    awardedMarkLabel.text = "Awarded Mark \(String(project.awardedMark))%"
                }
                
                
                let tasks = (project.task!.allObjects as! [Task])
                let projectProgress = calculations.getProjectProgress(tasks)
                let daysLeftProgress = calculations.getRemainingTimePercentage(project.startDate as! Date, end: project.dueDate as! Date)
                var daysRemaining = self.calculations.getDateDiff(self.now, end: project.dueDate as! Date)
                
                if daysRemaining < 0 {
                    daysRemaining = 0
                }
                
                //Assessment progressbar information display configurations
                DispatchQueue.main.async {
                    let colours = self.colours.getProgressGradient(projectProgress)
                    self.projectProgressBar?.customSubtitle = "Completed"
                    self.projectProgressBar?.startGradientColor = colours[0]
                    self.projectProgressBar?.endGradientColor = colours[1]
                    self.projectProgressBar?.progress = CGFloat(projectProgress) / 100
                }
                
                //Assessment remaining days information configuration
                DispatchQueue.main.async {
                    let colours = self.colours.getProgressGradient(daysLeftProgress, negative: true)
                    self.remainingDaysProgressBar?.customTitle = "\(daysRemaining)"
                    self.remainingDaysProgressBar?.customSubtitle = "Days Left"
                    self.remainingDaysProgressBar?.startGradientColor = colours[0]
                    self.remainingDaysProgressBar?.endGradientColor = colours[1]
                    self.remainingDaysProgressBar?.progress =  CGFloat(daysLeftProgress) / 100
                }
            }
            
            if selectedProject == nil {
                taskTable.isHidden = false
                projectInfoView.isHidden = true
            }
        }

    // MARK: - Add to calendar only
    @IBAction func includeToCalendarEvent(_ sender: Any) {
            let eventStore = EKEventStore()
            
            if let project = selectedProject {
                if !project.includeToCalendar {
                    if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
                        eventStore.requestAccess(to: .event, completion: {
                            granted, error in
                            self.createEvent(eventStore, title: project.assessmentName as! String, startDate: project.startDate as! Date, endDate: project.dueDate as! Date)
                        })
                    } else {
                        
                        createEvent(eventStore, title: project.assessmentName as! String, startDate: project.startDate as! Date, endDate: project.dueDate as! Date)
                    }
                    let alert = UIAlertController(title: "Success", message: "The assessment was added to the Calendar!", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Warning", message: "The assessment is already on the Calendar!", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
  
 
        
        // MARK: - Segues, Add+Edit+Note
        
       //When user click "add task" will display seague with below configuration
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "addTask" {
                let controller = (segue.destination as! UINavigationController).topViewController as! TaskViewController
                controller.selectedProject = selectedProject
                if let controller = segue.destination as? UIViewController {
                    controller.popoverPresentationController!.delegate = self
                    controller.preferredContentSize = CGSize(width: 380, height: 500)
                }
            }
            
            //When user click "View Note" will display seague with below configuration
            if segue.identifier == "showProjectNote" {
                let controller = segue.destination as! NotesViewController
                controller.notes = selectedProject!.additionalNote
                if let controller = segue.destination as? UIViewController {
                    controller.popoverPresentationController!.delegate = self
                    controller.preferredContentSize = CGSize(width: 300, height: 250)
                }
            }
            
            //When user click "edit task" will display seague with below configuration
            if segue.identifier == "editTask" {
                if let indexPath = taskTable.indexPathForSelectedRow {
                    let object = fetchedResultsController.object(at: indexPath)
                    let controller = (segue.destination as! UINavigationController).topViewController as! TaskViewController
                    controller.editingTask = object as Task
                    controller.selectedProject = selectedProject
                    controller.preferredContentSize = CGSize(width: 380, height: 500)
                }
            }
        }
        
        // MARK: - Table View Functions
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return fetchedResultsController.sections?.count ?? 0
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            let sectionInfo = fetchedResultsController.sections![section]
            
            if selectedProject == nil {
                projectInfoView.isHidden = true
                projectProgressBar.isHidden = true
                remainingDaysProgressBar.isHidden = true
                taskAddButton.isEnabled = false
                taskEditButton.isEnabled = false
                includeToCalendarButton.isEnabled = false
                taskTable.setEmptyMessage("Add a new assessment or select an assessment to manage task(s).", UIColor.black)
                return 0
            }
            
            if sectionInfo.numberOfObjects == 0 {
                taskEditButton.isEnabled = false
                taskTable.setEmptyMessage("No task(s) available for this assessment.", UIColor.black)
            }
            
            return sectionInfo.numberOfObjects
        }
        
        //set task cell in the table
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskTableCell
            let task = fetchedResultsController.object(at: indexPath)
            configureCell(cell, withTask: task, index: indexPath.row)
            cell.cellDelegate = self
            return cell
        }
        
        func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            // Return false if you do not want the specified item to be editable.
            return true
        }
        
        
        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                let context = fetchedResultsController.managedObjectContext
                context.delete(fetchedResultsController.object(at: indexPath))
                
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
        
        //set task cell with added or updated information in the table
        func configureCell(_ cell: TaskTableCell, withTask task: Task, index: Int) {
            cell.commonInit(task.taskName as! String, taskProgress: CGFloat(task.progress), startDate: task.startDate as! Date, endDate: task.endDate as! Date, additionalNote: task.additionalNote as! String, taskNo: index + 1)
        }
        
        // MARK: - Fetched results controller
        
        var fetchedResultsController: NSFetchedResultsController<Task> {
            if _fetchedResultsController != nil {
                return _fetchedResultsController!
            }
            
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            
            // Set the batch size to a suitable number.
            fetchRequest.fetchBatchSize = 20
            
            if selectedProject != nil {
                // Setting a predicate
                let predicate = NSPredicate(format: "%K == %@", "project", selectedProject as! Project)
                fetchRequest.predicate = predicate
            }

            
            // Edit the sort key as appropriate.
            let sortDescriptor = NSSortDescriptor(key: "startDate", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]

            // Edit the section name key path and cache name if appropriate.
            // nil for section name key path means "no sections".
            let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "\(UUID().uuidString)-project")
            aFetchedResultsController.delegate = self
            _fetchedResultsController = aFetchedResultsController
            
            do {
                try _fetchedResultsController!.performFetch()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            
            return _fetchedResultsController!
        }
        
        var _fetchedResultsController: NSFetchedResultsController<Task>? = nil
        
        func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            taskTable.beginUpdates()
        }
        
        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
            switch type {
            case .insert:
                taskTable.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                taskTable.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
            }
        }
        
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
           // taskTable.endUpdates()
        }
        
        //Display configured note on selected task cell
        func showPopoverFrom(cell: TaskTableCell, forButton button: UIButton, forNotes notes: String) {
            let buttonFrame = button.frame
            var showRect = cell.convert(buttonFrame, to: taskTable)
            showRect = taskTable.convert(showRect, to: view)
            showRect.origin.y -= 5
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "NotesViewController") as? NotesViewController
            controller?.modalPresentationStyle = .popover
            controller?.preferredContentSize = CGSize(width: 300, height: 250)
            controller?.notes = notes
            
            if let popoverPresentationController = controller?.popoverPresentationController {
                popoverPresentationController.permittedArrowDirections = .up
                popoverPresentationController.sourceView = self.view
                popoverPresentationController.sourceRect = showRect
                
                if let popoverController = controller {
                    present(popoverController, animated: true, completion: nil)
                }
            }
        }
        
        // Creates an event in the EKEventStore
    func createEvent(_ eventStore: EKEventStore, title: String, startDate: Date, endDate: Date) -> String {
            let event = EKEvent(eventStore: eventStore)
            var identifier = ""
            
            event.title = title
            event.startDate = startDate
            event.endDate = endDate
            //event.dueDate = dueDate
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
    }

    //Display task note when button clicked
    extension DetailViewController: TaskTableViewCellDelegate {
        func viewNotes(cell: TaskTableCell, sender button: UIButton, data: String) {
            self.showPopoverFrom(cell: cell, forButton: button, forNotes: data)
        }


}

//Button layout configuration to enable button configuration in storyboard
@IBDesignable extension UIButton {

    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }

    @IBInspectable var borderColor: UIColor? {
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
