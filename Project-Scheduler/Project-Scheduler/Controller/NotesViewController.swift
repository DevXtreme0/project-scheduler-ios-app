//
//  NotesViewController.swift
//  Project-Scheduler
//
//  Created by user172177 on 5/11/20.
//  Copyright © 2020 MahelManjithaM. All rights reserved.
//

import Foundation
import UIKit

class NotesViewController: UIViewController {
    
    @IBOutlet weak var additionalNoteTextView: UITextView!
    
    //set notes text when recieved words
    var notes: String? {
        didSet {
            configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    
    func configureView() {
        if let notes = notes {
            
            //Get Notes text throghe text view
            if let notesTextView = additionalNoteTextView {
                notesTextView.text = notes
            }
        }
    }
}
