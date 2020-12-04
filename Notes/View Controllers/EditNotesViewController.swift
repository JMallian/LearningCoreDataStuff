//
//  EditNotesViewController.swift
//  Notes
//
//  Created by Jessica Mallian on 12/2/20.
//

import UIKit

class EditNotesViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    var note: Note? 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let note = note else {
            fatalError()
        }
        titleTextField.text = note.title
        contentsTextView.text = note.contents
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if let title = titleTextField.text, !title.isEmpty { // recall that the title propety is required 
            note?.title = title
        }
        note?.updatedAt = Date()
        note?.contents = contentsTextView.text
    }
    
}
