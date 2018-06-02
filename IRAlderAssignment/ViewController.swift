//
//  ViewController.swift
//  IRAlderAssignment
//
//  Created by Ihor Rudych on 5/30/18.
//  Copyright © 2018 Ihor Rudych. All rights reserved.
//

import UIKit
import CoreData


class ViewController: UIViewController, UITableViewDataSource,UITableViewDelegate, NSFetchedResultsControllerDelegate {
    // coredata variables
    let managedObjectContext:NSManagedObjectContext? = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fetchedResultsController:NSFetchedResultsController<NSFetchRequestResult>?
    // fetch variables
    var person:Person?
    
    var personID:UUID!
    
    var force:String! = "Unknown"
    
    var refreshCtrl = UIRefreshControl()
    
    var imageCache = NSCache<AnyObject, AnyObject>()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView and refresh setup
        //self.refreshCtrl.tintColor = UIColor(red:0.75, green:0.52, blue:0.25, alpha:1.0)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.refreshControl = refreshCtrl
        
        //grab data from CoreData
        let context:NSManagedObjectContext = self.managedObjectContext!
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SWCharacter")
        request.returnsObjectsAsFaults = false
        
        //since using NSFetchresultsController need to sort records
        let sectionSortDescriptor = NSSortDescriptor(key: "firstName", ascending: true)
        
        let sortDescriptors = [sectionSortDescriptor]
        request.sortDescriptors = sortDescriptors
        
        // creating the instance of NSFetchresultsController
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        aFetchedResultsController.delegate = self
        self.fetchedResultsController = aFetchedResultsController
        
        do{
            //performing the fetch
            try fetchedResultsController?.performFetch()
            
        } catch  {
            fatalError("fetchresult controller failed to fetch data \(error)")
        }
        //intiating refresh on fetchStars function
        //self.refreshCtrl.addTarget(self, action: #selector (fetchStars), for: .valueChanged)
        self.fetchStars()
    }
    
    
    //tableView overrides
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let section = fetchedResultsController?.sections?.count else {
            return 0
        }
        return section
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections else {
            return 0
        }
        
        let sect = sections[section]
        return sect.numberOfObjects
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //intitiate the cell with identifier to reuse it for all objects
       let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath)
        //grabing person information from coredata
        let person = fetchedResultsController?.object(at: indexPath) as! SWCharacter
        
        //setting up cell
        cell.textLabel?.text = "\(person.firstName ?? "Uknown") \(person.lastName ?? "Uknown")"
        cell.detailTextLabel?.text = "\(person.affiliation ?? "Unknown")"
        //set profile picture in cell
        let url = URL(string: person.profilePicture!)
        
        let imgdata = NSData(contentsOf: url!)
        let img = UIImage(data: imgdata! as Data)
        self.imageCache.setObject(img!, forKey: "gert359" as AnyObject)
        DispatchQueue.main.async {
           
            cell.imageView?.image = img
        }
    
        //accessory
        cell.accessoryType = .disclosureIndicator
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person = fetchedResultsController?.object(at: indexPath) as! SWCharacter
        
        self.personID = person.id
        //print(self.personID)
        self.performSegue(withIdentifier: "gotodetail", sender: tableView.cellForRow(at: indexPath))
    }
    
    // download data triger
    
     func fetchStars(){
        self.refreshCtrl.beginRefreshing()
        //erase existing data in coredata
        let context:NSManagedObjectContext = self.managedObjectContext!
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SWCharacter")
        do{
            let fetched = try context.fetch(request) as! [SWCharacter]
            for person in fetched {
                context.delete(person)
            }
        } catch let error{
            print("failed to erase data from CoreData \(error)")
        }
        
        //grab data from heroku
        let endPoint = "https://starwarstest16.herokuapp.com/api/characters"
        guard let url = URL(string: endPoint) else { return }
        //DispatchQueue.main.async {
    
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else { return }
            guard let data = data else { return }
            do {
                //lets get the data into JSON
                if let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? [String: AnyObject] {
                    // some concurrency settings for memory management
                    //DispatchQueue.main.async {
                        //We go to next function to parce JSON
                       self.parseJSONResult(json: json as AnyObject)
                        
                    //}
                
            }
                
            } catch let error {
                print("Can't serialize JSON:\(error)")
            }
            }.resume()
       
    }
    private func parseJSONResult(json: AnyObject){
        let context:NSManagedObjectContext = self.managedObjectContext!
        
        //checking if results exist
        if let results = json["individuals"] as? [[String: AnyObject]] {
            //looping through JSON to get values
            for result in results {
                
                //variables with values
                let id = result["id"] as? String ?? ""
                let firstName = result["firstName"] as? String ?? ""
                let lastName = result["lastName"] as? String ?? ""
                let dateOfBirth = result["birthdate"] as? String ?? ""
                let profilePicture = result["profilePicture"] as? String ?? ""
                let forceSensitive = result["forceSensitive"] as? Bool ?? false
                
                let affiliation = result["affiliation"] as? String ?? ""
                
                
                //assigning all the values from JSON to an instance of Person class
                self.person = Person(id: id, firstName: firstName, lastName: lastName, birthDate: dateOfBirth, profilePicture:profilePicture, forceSensitive:forceSensitive, affiliation: affiliation)
                
                
                //insert JSON in core data
                
                //CoreData variables
                
                let idx = UUID()
                let name1 = self.person?.firstName
                let name2 = self.person?.lastName
                let birth = self.person?.birthDate
                
                let imgdata = self.person?.profilePicture
                let force = forceSensitive
                let affili = self.person?.affiliation
                
                //New Person added to CoreData
                let newPerson:AnyObject! = NSEntityDescription.insertNewObject(forEntityName: "SWCharacter", into: context) as AnyObject
                newPerson.setValue(idx, forKey: "id")
                newPerson.setValue(name1, forKey: "firstName")
                newPerson.setValue(name2, forKey: "lastName")
                newPerson.setValue(birth, forKey: "birthDate")
                newPerson.setValue(imgdata, forKey: "profilePicture")
                newPerson.setValue(force, forKey: "forceSensetive")
                newPerson.setValue(affili, forKey: "affiliation")
                do {
                    try context.save()
                } catch let error {
                    print("failed to save downloaded users \(error)")
                }
            }
        }
            
        else {
            print("Error! Unable to parse the JSON")
            
        }
        self.refreshCtrl.endRefreshing()
    }
    
    //pass data to controllers
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "gotodetail"{
            let detail:SWCharDetailController = segue.destination as! SWCharDetailController
            detail.personID = personID
            
        }
    }
    //This one is just to refresh the content of Tableview when data is updated.
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.reloadData()
    }


}

