//
//  AddNoteViewController.swift
//  Notes
//
//  Created by Jessica Mallian on 11/29/20.
//

import UIKit
import CoreData

class AddNoteViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    var managedObjectContext: NSManagedObjectContext? 
    
    override func viewDidLoad() {
        contentsTextView.backgroundColor = .gray
    }
    
    
    // would like to dimiss when the keyboard return button is pressed but though this can easily be done in the UITextFieldDelegate method textFieldShouldReturn, UITextViewDelegate does not have a corresponding method
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    
    @IBAction func saveNoteButtonPressed(_ sender: UIBarButtonItem) {
        guard let title = titleTextField.text, !title.isEmpty else {
            showAlert(with: "Title Missing", and: "Please enter a title for your note.")
            return
        }
        
        guard let managedObjectContext = managedObjectContext else {
            fatalError()
        }
        
        let note = Note(context: managedObjectContext)
        note.createdAt = Date()
        note.updatedAt = Date()
        note.title = title
        note.contents = contentsTextView.text
        resetTextInputs()
    }
    
    private func resetTextInputs() {
        titleTextField.text = ""
        contentsTextView.text = "Contents..."
    }
}

