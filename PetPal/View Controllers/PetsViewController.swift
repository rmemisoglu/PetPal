//  Created by Ramazan Memişoğlu on 8.08.2019.
//  Copyright © 2019. All rights reserved.

import UIKit
import CoreData

class PetsViewController: UIViewController {
    @IBOutlet private weak var collectionView:UICollectionView!
    
    var friend: Friend!
    
    private var fetchedRC: NSFetchedResultsController<Pet>!
    private var query = ""
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let formatter = DateFormatter()
    private var isFiltered = false
    private var filtered = [String]()
    private var selected:IndexPath!
    private var picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        formatter.dateFormat = "d MMM yyyy"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
    
    private func refresh() {
        
        let request = Pet.fetchRequest() as NSFetchRequest<Pet>
        if query.isEmpty {
            request.predicate = NSPredicate(format: "owner = %@", friend)
        } else {
            request.predicate = NSPredicate(format: "name CONTAINS[cd] %@ AND owner = %@", query, friend)
        }
        let sort = NSSortDescriptor(key: #keyPath(Pet.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        request.sortDescriptors = [sort]
        do {
            fetchedRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            //fetchedRC.delegate = self
            try fetchedRC.performFetch()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleLongPress (gestureRecognizer: UIGestureRecognizer){
        if gestureRecognizer.state != .ended{
            return
        }
        let point = gestureRecognizer.location(in: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: point) {
            let pet = fetchedRC.object(at: indexPath)
            context.delete(pet)
            appDelegate.saveContext()
            refresh()
            collectionView.deleteItems(at: [indexPath])
        }
    }
    
    // MARK:- Actions
    @IBAction func addPet() {
        let data = PetData()
        let pet = Pet(entity: Pet.entity(), insertInto: context)
        pet.name = data.name
        pet.kind = data.kind
        pet.dob = data.dob as NSDate
        pet.owner = friend
        appDelegate.saveContext()
        refresh()
        collectionView.reloadData()
    }
    
    func collectionViewCellCircle(sender: UICollectionViewCell){
//        if let imageLayer = sender.viewWithTag(10022) as? UIImageView {
//            imageLayer.layer.cornerRadius = 15
//            //imageLayer.layer.masksToBounds = true
//        }
        let contactRect = CGRect(x: sender.bounds.origin.x - 5, y: sender.bounds.origin.y - 5, width: sender.bounds.width + 10, height: sender.bounds.height + 10)
        
        sender.layer.cornerRadius = sender.bounds.height / 2
        //sender.layer.masksToBounds = true
        //sender.contentView.layer.borderWidth = 1.0
        
        sender.layer.shadowColor = UIColor.black.cgColor
        sender.layer.shadowOffset = .zero//CGSize(width: 20, height: 7.0)
        sender.layer.shadowRadius = 10.0
        sender.layer.shadowOpacity = 0.8
        sender.layer.masksToBounds = false
        sender.layer.shadowPath = UIBezierPath(ovalIn: contactRect).cgPath

        
        
    }
}

// Collection View Delegates
extension PetsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let pets = fetchedRC.fetchedObjects else {
            return 0
        }
        return pets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PetCell", for: indexPath) as! PetCell
        
        let pet = fetchedRC.object(at: indexPath)
        cell.nameLabel.text = pet.name
        cell.animalLabel.text = pet.kind
        if let dob = pet.dob as Date? {
            cell.dobLabel.text = formatter.string(from: dob)
        } else {
            cell.dobLabel.text = "Unknown"
        }
        if let data = pet.picture as Data? {
            cell.pictureImageView.image = UIImage(data: data)
        } else {
            cell.pictureImageView.image = UIImage(named: "pet-placeholder")
        }
        collectionViewCellCircle(sender: cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selected = indexPath
        self.navigationController?.present(picker, animated: true, completion: nil)
    }
}

// Search Bar Delegate
extension PetsViewController:UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let txt = searchBar.text else {
            return
        }
        query = txt
        refresh()
        searchBar.resignFirstResponder()
        collectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        query = ""
        searchBar.text = nil
        searchBar.resignFirstResponder()
        refresh()
        collectionView.reloadData()
    }
}
//Fetched Delegata
//extension PetsViewController: NSFetchedResultsControllerDelegate {
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didCahnge andObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        let index = indexPath ?? (newIndexPath ?? nil)
//        guard let cellindex = index else {
//            return
//        }
//        switch type {
//        case .insert:
//            collectionView.insertItems(at: [cellindex])
//        case .delete:
//            collectionView.deleteItems(at: [cellindex])
//        default:
//            break
//        }
//    }
//}

// Image Picker Delegates
extension PetsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let pet = fetchedRC.object(at: selected)
        //        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        pet.picture = UIImagePNGRepresentation(image) as NSData?
        appDelegate.saveContext()
        collectionView?.reloadItems(at: [selected])
        picker.dismiss(animated: true, completion: nil)
    }
}
