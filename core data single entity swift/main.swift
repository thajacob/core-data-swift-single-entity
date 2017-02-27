//
//  main.swift
//  core data single entity swift
//
//  Created by jakub skrzypczynski on 10/11/2016.
//  Copyright © 2016 test project. All rights reserved.
//

import Foundation
import CoreData

// find the momd

let modelURL = Bundle.main.url(forResource: "MyModel", withExtension: "momd")!

// Make the MOM

let mom = NSManagedObjectModel(contentsOf: modelURL)!

// Create the PSC

let psc = NSPersistentStoreCoordinator(managedObjectModel:mom)

// Create the MOC

let  managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

managedObjectContext.persistentStoreCoordinator = psc

let fileManager =  FileManager.default

let docURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)

let documentsURL = docURL[docURL.count-1]

let storeURL = documentsURL.appendingPathComponent("MyModel.sqlite")

var failureReason = "There was an error creating or loading the application's saved data."
do
{
    try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
}
catch
{
    // Report any error we got.
    var dict = [String: AnyObject]()
    dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
    dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
    dict[NSUnderlyingErrorKey] = error as NSError
    let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
    // Replace this with code to handle the error appropriately.
    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
    abort()
}

print("persistent store initialized")

let computersToAdd =
[
[1,"MacBookAir13.png","MacBook Air 13 inch",849.00,"Apple","Laptop"],
[2,"MacBookAir11.png","MacBook Air 11 inch",749.00,"Apple","Laptop"],
[3,"MacBookAir13.png","MacBook Pro",999.00,"Apple","Laptop"],
[4,"MacBookProretina13.png","MacBook Pro Retina 13 inch",1099.00,"Apple","Laptop"],
[5,"MacBookProretina15.png","MacBook Pro Retina 15 inch",1699.00,"Apple","Laptop"],
[6,"Macmini.png","Mac mini",499.00,"Apple","Desktop"]]

for computers in computersToAdd
{
    var newComputer = NSEntityDescription.insertNewObject(forEntityName: "Computers", into: managedObjectContext)
    
    newComputer.setValue(computers[0], forKey: "id")
    newComputer.setValue(computers[1], forKey: "image")
    newComputer.setValue(computers[2], forKey: "name")
    newComputer.setValue(computers[3], forKey: "price")
    newComputer.setValue(computers[4], forKey: "supplier")
    
    print("creating  \(computers[0]), \(computers[1]), \(computers[2]), \(computers [3]), \(computers[4])")
    
}

if managedObjectContext.hasChanges {
    do
    {try managedObjectContext.save()
        print("managedObjectContext successfully saved!")
    }
    catch
    {
        let nserror = error as NSError
        print("Unresolved error \(nserror), \(nserror.userInfo)")
        abort()
    }
}

//create the request

let request = NSFetchRequest<NSManagedObject>(entityName: "Computers")

//Search for the computer entity in the MOC

request.entity = NSEntityDescription.entity(forEntityName: "Computers", in: managedObjectContext)

//Tell the request that the computers should be sorted by their price

request.sortDescriptors = [NSSortDescriptor(key:"price",ascending:true)]

let computers:[AnyObject]
do
{
    computers = try managedObjectContext.fetch(request)
    for macs in computers
    {
        if let currentMac = macs as? NSManagedObject
        {
            if let id = currentMac.value(forKey:"id"), let image = currentMac.value(forKey: "image"),
                
            let name = currentMac.value(forKey:"name"),
            let price = currentMac.value(forKey:"price"),
            let supplier = currentMac.value(forKey: "supplier")
            {
                print("Found: \(id), \(image), \(name), \(price), \(supplier)")
            }
        }
    }
}

catch
{
    let nserror = error as NSError
    print("Error fething the computers entities: \(nserror), \(nserror.userInfo)")
    abort()
    
}

// make a request with a predicate 

request.predicate = NSPredicate(format:"price > 1000")

do
{
    let computersWithPredicate = try managedObjectContext.fetch(request)
    for macs in computersWithPredicate
    {
        if let currentMac = macs as? NSManagedObject
        {
            if let id = currentMac.value(forKey:"id"),
                let image = currentMac.value(forKey: "image"),
                let name = currentMac.value(forKey: "name"),
                let price = currentMac.value(forKey:"price"),
                let supplier = currentMac.value(forKey: "supplier")
            {
        print("Found price > 1000: \(id), \(image), \(price), \(supplier)")
            }
        }
    }

}
catch
{

            let nserror = error as NSError
NSLog("Error fethching the computers entities: \(nserror), \(nserror.userInfo)")
abort()
}

for macs in computers
{
    managedObjectContext.delete((macs as? NSManagedObject)!)
}

print("about to delete the following objects from POS \(managedObjectContext.deletedObjects)")

if managedObjectContext.hasChanges{
    do {
        try managedObjectContext.save()
         print("managedObjectContext succesfully saved (again)!")
}

catch
{
    
    let nserror = error as NSError
    print("Unresolved error \(nserror), \(nserror.userInfo)")
    abort()
    
}
}


