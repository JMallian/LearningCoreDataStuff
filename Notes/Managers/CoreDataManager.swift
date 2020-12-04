//
//  CoreDataManager.swift
//  Notes
//
//  Created by Jessica Mallian on 11/29/20.
//
//  The CoreDataManager class is in charge of the Core Data stack of the application
//  Need to instantiate 3 objects to set up the Core Data stack:
//  - a managed object model
//  - a managed object context
//  - a persistent store coordinator

import CoreData
import UIKit

final class CoreDataManager {
    // MARK: - Properties
    private let modelName: String
    
    private(set) lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            fatalError("Unable to Find Data Model")
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unable to Load Data Model")
        }
        
        return managedObjectModel
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let fileManager = FileManager.default
        let storeName = "\(self.modelName).sqlite"
        
        // URL Documents Directory (gonna store the persistent store in the Documents directory of the application's sandbox, but Library could have been used
        let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let persistentStoreURL = documentsDirectoryURL.appendingPathComponent(storeName)
        
        do {
            let options = [
                NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true
            ]
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistentStoreURL, options: options)
        } catch {
            fatalError("Unable to add Persistent Store")
        }
        
        return persistentStoreCoordinator
    }()
    
    // MARK: - Initalization
    init(modelName: String) {
        self.modelName = modelName
        setupNotificationHandling()
    }
    
    private func setupNotificationHandling() {
        // add the CoreDataManager instance as an observer of 2 notifications sent by the UIApplication singleton: UIApplicationWillTerminate and UIApplicationDidEnterBackground
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(saveChanges(_:)), name: UIApplication.willTerminateNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(saveChanges(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc private func saveChanges(_ notification: Notification) {
        saveChanges()
    }
    
    private func saveChanges() {
        print("saveChanges called...")
        guard managedObjectContext.hasChanges else { return }
        
        do {
            try managedObjectContext.save()
        } catch {
            print("Unable to Save Managed Object Context")
            print("\(error), \(error.localizedDescription)")
        }
    }
}
