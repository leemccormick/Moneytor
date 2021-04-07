//
//  LocationPinController.swift
//  Moneytor
//
//  Created by Lee McCormick on 3/11/21.
//

import CoreData
import MapKit

class LocationPinController {
    
    static let shared = LocationPinController()
    var loctionPins: [PinLocation] = []
    
    func createLocationPin(_ annotation: MKPointAnnotation) -> PinLocation{
        let location = PinLocation(context: CoreDataStack.shared.context)
        location.date = Date()
        location.latitude = annotation.coordinate.latitude
        location.longitude = annotation.coordinate.longitude
        loctionPins.append(location)
        CoreDataStack.shared.saveContext()
        return location
    }
    
    func reloadLocationPins()  {
        let request: NSFetchRequest<PinLocation> = PinLocation.fetchRequest()
       // let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        //request.sortDescriptors = [sortDescriptor]
        request.predicate = NSPredicate(value: true)
        CoreDataStack.shared.context.perform {
            do {
                let pins = try CoreDataStack.shared.context.fetch(request)
                self.loctionPins = pins
            } catch {
                print("Error fetching Pins: \(error.localizedDescription)")
                
            }
        }
    }
    
    func fetchForSpecificLocationPin(_ annotation: MKPointAnnotation) -> PinLocation? {
        let predicate = NSPredicate(format: "longitude = %@ AND latitude = %@", argumentArray: [annotation.coordinate.longitude, annotation.coordinate.latitude])
        let sortDecriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PinLocation")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDecriptor]
        
        do {
            let location = try CoreDataStack.shared.context.fetch(fetchRequest) as! [PinLocation]
            guard let newPinLocation = location.first else {return nil}
            return newPinLocation
        } catch {
            print("Error annotationView in TravelLocationMapVC : \(error.localizedDescription)")
            return nil
        }
    }
    
    func deleteAllPinLocation() {
        let context = CoreDataStack.shared.context
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PinLocation")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do
                {
                    try context.execute(deleteRequest)
                    try context.save()
                }
        catch
        {
            print ("There was an error")
        }
    }
}
