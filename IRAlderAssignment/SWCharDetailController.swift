//
//  SWCharDetailController.swift
//  IRAlderAssignment
//
//  Created by Ihor Rudych on 5/30/18.
//  Copyright © 2018 Ihor Rudych. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SWCharDetailController: UIViewController {
    var personID:UUID! 
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var birthDateLabel: UILabel!
    
    @IBOutlet weak var affiliationLabel: UILabel!
    
    @IBOutlet weak var forceLabel: UILabel!
    
    let managedObjectContext:NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //referencing coredata
        let context:NSManagedObjectContext = self.managedObjectContext
        //creating fetch request
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SWCharacter")
        //creating predicate to fetch only record we want
        let predicate = NSPredicate(format: "id == %@", argumentArray: [self.personID!])
        request.predicate = predicate
        //return only valid objects
        request.returnsObjectsAsFaults = false
        
        do {
            //grabing data from core data as an array
            let stars = try context.fetch(request) as! [SWCharacter]
            //grabing first and hopefully only one object from that array
            let person = stars.first
            //setting up an image to display
            let url = URL(string: (person?.profilePicture)!)
            let imgdata = NSData(contentsOf: url!)
            let imagex = UIImage(data: imgdata! as Data)
            self.imageView.image = imagex
            //setting up labels to display the information
            self.nameLabel.text = "\(person?.firstName ?? "") \(person?.lastName ?? "")"
            self.birthDateLabel.text = "DOB: \(person?.birthDate ?? "")"
            self.affiliationLabel.text = "Affiliation: \(person?.affiliation ?? "")"
            self.forceLabel.text = "Force?: \(person?.forceSensetive ?? false)"
        } catch let error{
            print("failed to fetch user \(error)")
        }
    }
    
    @IBAction func donePressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
