//
//  ViewController.swift
//  Notes
//
//  Created by Jessica Mallian on 11/29/20.
//

import UIKit
import CoreData

class NotesViewController: UIViewController {
    // MARK: - Properties 
    private var coreDataManager = CoreDataManager(modelName: "Notes")
    @IBOutlet weak var notesTableView: UITableView!
    private var cellReuseID = "NotesCell"
    private var notes: [Note]? {
        didSet {
            updateView()
        }
    }
    private var hasNotes: Bool {
        guard let notes = notes else { return false }
        return notes.count > 0
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupTableView()
        fetchNotes()
        setupNotificationHandling()
    }
    
    private func setupNotificationHandling() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange(_:)), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: coreDataManager.managedObjectContext)
    }
    
    @objc private func managedObjectContextObjectsDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            fatalError()
        }
        var notesDidChange = false
        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject> {
            for insert in inserts {
                if let note = insert as? Note {
                    notes?.append(note)
                    notesDidChange = true
                }
            }
        }
        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
            for update in updates {
                if let _ = update as? Note {
                    notesDidChange = true
                }
            }
        }
        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject> {
            for delete in deletes {
                if let note = delete as? Note {
                    if let index = notes?.firstIndex(of: note) {
                        notes?.remove(at: index)
                        notesDidChange = true
                    }
                }
            }
        }
        
        if notesDidChange {
            notes?.sort(by: { ($0.updatedAt ?? Date()) > ($1.updatedAt ?? Date()) })
            
            notesTableView.reloadData()
            
            updateView()
        }
    }
    
    private func setupTableView() {
        notesTableView.dataSource = self
        notesTableView.delegate = self
        notesTableView.register(UINib(nibName: "NotesTableViewCell", bundle: nil), forCellReuseIdentifier: cellReuseID)
    }
    
    private func updateView() {
        notesTableView.isHidden = !hasNotes
        // TODO: something
        // in the example app there is messageLabel.isHidden = hasNotes
        // but I've not created a messageLabel behind the table view so there's no real point in hiding the table at all, but perhaps do later
    }
    
    private func fetchNotes() {
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Note.updatedAt), ascending: false)] // #keyPath syntax? wow, new
        coreDataManager.managedObjectContext.performAndWait {
            // yes this blocks the main thread, but with Core Data that should be fine, can optimze later if not
            do {
                let notes = try fetchRequest.execute()
                self.notes = notes
                self.notesTableView.reloadData()
            } catch {
                print("unable to execute fetch request: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Navigtion
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            fatalError()
        }
        switch identifier {
        case "AddNote":
            guard let destination = segue.destination as? AddNoteViewController else { fatalError() }
            destination.managedObjectContext = coreDataManager.managedObjectContext
        default:
            break
        }
    }
}

extension NotesViewController: UITableViewDelegate {
    
}

extension NotesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let notes = notes else { return 0 }
        return notes.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return hasNotes ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = notesTableView.dequeueReusableCell(withIdentifier: cellReuseID) as? NotesTableViewCell else {
            fatalError()
        }
        guard let note = notes?[indexPath.row] else {
            fatalError("unexpected indexPath")
        }
        cell.titleLabel.text = note.title
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        cell.updatedAtLabel.text = dateFormatter.string(for: note.updatedAt) ?? ""
        cell.contentLabel.text = note.contents
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = notes?[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "EditNotesViewController") as EditNotesViewController
        vc.note = note 
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        guard let note = notes?[indexPath.row] else {
            fatalError()
        }
        note.managedObjectContext?.delete(note)
        // could have also used
        // coreDataManager.managedObjectContext.delete(note)
        // because it's the same context!
    }
    
}

