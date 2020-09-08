//
//  MasterViewController.swift
//  Project-Scheduler
//
//  Created by user172165 on 5/4/20.
//  Copyright © 2020 MahelManjithaM. All rights reserved.
//M

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate, UIPopoverPresentationControllerDelegate {
    
        var detailViewController: DetailViewController? = nil
        var managedObjectContext: NSManagedObjectContext? = nil
        
 
    @IBOutlet var projectsTable: UITableView!
        
        let calculations: Calculations = Calculations()
        
        override func viewDidLoad() {
            super.viewDidLoad()

            if let split = splitViewController {
                let controllers = split.viewControllers
                detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
            }
            
            // initializing the custom cell
            let nibName = UINib(nibName: "ProjectTableCell", bundle: nil)
            tableView.register(nibName, forCellReuseIdentifier: "ProjectCell")
        }

        override func viewWillAppear(_ animated: Bool) {
            clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
            super.viewWillAppear(animated)
            
            // Set the default selected row
            autoSelectTableRow()
        }


        @objc
        func insertNewObject(_ sender: Any) {
            let context = self.fetchedResultsController.managedObjectContext
            let newProject = Project(context: context)
                 
            // Save the context.
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                self.performSegue(withIdentifier: "showProjectDetails", sender: object)
            }
        }
        

        // MARK: - Segues Add+Edit+Note

        //When user click "view note" will display seague with below configuration
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showProjectDetails" {
                if let indexPath = tableView.indexPathForSelectedRow {
                    let object = fetchedResultsController.object(at: indexPath)
                    let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                    controller.selectedProject = object as Project
                }
            }
            
            //When user click "add assessment" will display seague with below configuration
            if segue.identifier == "addProject" {
                if let controller = segue.destination as? UIViewController {
                    controller.popoverPresentationController!.delegate = self
                    controller.preferredContentSize = CGSize(width: 380, height: 550)
                }
            }
            
            //When user click "edit assessment" will display seague with below configuration
            if segue.identifier == "editProject" {
                if let indexPath = tableView.indexPathForSelectedRow {
                    let object = fetchedResultsController.object(at: indexPath)
                    let controller = (segue.destination as! UINavigationController).topViewController as! ProjectViewController
                    controller.editingProject = object as Project
                    controller.preferredContentSize = CGSize(width: 380, height: 550)
                }
            }
        }

        // MARK: - Table View

        override func numberOfSections(in tableView: UITableView) -> Int {
            return fetchedResultsController.sections?.count ?? 0
        }

        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            let sectionInfo = fetchedResultsController.sections![section]
            return sectionInfo.numberOfObjects
        }

        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell", for: indexPath) as! ProjectTableCell
            let project = fetchedResultsController.object(at: indexPath)
            configureCell(cell, withProject: project)
            cell.cellDelegate = self
            return cell
        }

        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            // Return false if you do not want the specified item to be editable.
            return true
        }

        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
        
        override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
            autoSelectTableRow()
        }

        // Assessment information added to core data attributes throgh this method
        func configureCell(_ cell: ProjectTableCell, withProject project: Project) {
            let projectProgress = calculations.getProjectProgress(project.task!.allObjects as! [Task])
            cell.commonInit(project.assessmentName as! String, taskProgress: CGFloat(projectProgress), academicLevel: project.academicLevel as! String, dueDate: project.dueDate as! Date, additionalNote: project.additionalNote as! String)
        }

        // MARK: - Fetched results controller

        var fetchedResultsController: NSFetchedResultsController<Project> {
            if _fetchedResultsController != nil {
                return _fetchedResultsController!
            }
            
            let fetchRequest: NSFetchRequest<Project> = Project.fetchRequest()
            
            // Set the batch size to a suitable number.
            fetchRequest.fetchBatchSize = 20
            
            // Edit the sort key as appropriate.
            let sortDescriptor = NSSortDescriptor(key: "startDate", ascending: false)
            
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            // nil for section name key path means "no sections".
            let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
            aFetchedResultsController.delegate = self
            _fetchedResultsController = aFetchedResultsController
            
            do {
                try _fetchedResultsController!.performFetch()
            } catch {
                 // Replace this implementation with code to handle the error appropriately.
                 let nserror = error as NSError
                 fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            
            // update UI
            autoSelectTableRow()
            
            return _fetchedResultsController!
        }
        
        var _fetchedResultsController: NSFetchedResultsController<Project>? = nil

        func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            tableView.beginUpdates()
        }

        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
            switch type {
                case .insert:
                    tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
                case .delete:
                    tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
                default:
                    return
            }
        }

        // Configurations for behaviour of assessment cell when assessment add, edit, delete happened
        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
            switch type {
                case .insert:
                    tableView.insertRows(at: [newIndexPath!], with: .fade)
                case .delete:
                    tableView.deleteRows(at: [indexPath!], with: .fade)
                case .update:
                    configureCell(tableView.cellForRow(at: indexPath!)! as! ProjectTableCell, withProject: anObject as! Project)
                case .move:
                    configureCell(tableView.cellForRow(at: indexPath!)! as! ProjectTableCell, withProject: anObject as! Project)
                    tableView.moveRow(at: indexPath!, to: newIndexPath!)
            }
            
            // update UI
            autoSelectTableRow()
        }

        // When changes happen in assessment do update table
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            tableView.endUpdates()
        }

    // Note-popover configurations for assessment
        func showPopoverFrom(cell: ProjectTableCell, forButton button: UIButton, forNotes additionalNote: String) {
            let buttonFrame = button.frame
            var showRect = cell.convert(buttonFrame, to: projectsTable)
            showRect = projectsTable.convert(showRect, to: view)
            showRect.origin.y -= 5
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "NotesViewController") as? NotesViewController
            controller?.modalPresentationStyle = .popover
            controller?.preferredContentSize = CGSize(width: 300, height: 250)
            controller?.notes = additionalNote
            
            if let popoverPresentationController = controller?.popoverPresentationController {
                popoverPresentationController.permittedArrowDirections = .up
                popoverPresentationController.sourceView = self.view
                popoverPresentationController.sourceRect = showRect
                
                if let popoverController = controller {
                    present(popoverController, animated: true, completion: nil)
                }
            }
        }
 
        // When app opened auto select assessment from top
        func autoSelectTableRow() {
            let indexPath = IndexPath(row: 0, section: 0)
            if tableView.hasRowAtIndexPath(indexPath: indexPath as NSIndexPath) {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
                
                if let indexPath = tableView.indexPathForSelectedRow {
                    let object = fetchedResultsController.object(at: indexPath)
                    self.performSegue(withIdentifier: "showProjectDetails", sender: object)
                }
            } else {
                let empty = {}
                self.performSegue(withIdentifier: "showProjectDetails", sender: empty)
            }
        }
    }

    // Display assessment note when button clicked
    extension MasterViewController: ProjectTableViewCellDelegate {
        func customCell(cell: ProjectTableCell, sender button: UIButton, data: String) {
            self.showPopoverFrom(cell: cell, forButton: button, forNotes: data)
        }

}

