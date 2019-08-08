//  Created by Ramazan Memişoğlu on 8.08.2019.
//  Copyright © 2019 Razeware. All rights reserved.

import UIKit
import CoreData

class MainViewController: UIViewController {
	@IBOutlet private weak var collectionView:UICollectionView!
	
    private var fetchedRC: NSFetchedResultsController<Friend>!
	private var friendPets = [String:[String]]()
	private var selected:IndexPath!
	private var picker = UIImagePickerController()
    private var images = [String:UIImage]()
    private var query = ""
	
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    

	override func viewDidLoad() {
		super.viewDidLoad()
		picker.delegate = self
	}
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
        showEditButton()
    }
    
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
    func collectionViewCellShadow(sender: UICollectionViewCell){
        let shadowSize: CGFloat = 15
        let contactRect = CGRect(x: -shadowSize, y: sender.bounds.height - (shadowSize * 0.4), width: sender.bounds.width + shadowSize * 2, height: shadowSize)
        
        sender.layer.cornerRadius = 10
        sender.contentView.layer.cornerRadius = 10
        sender.contentView.layer.borderWidth = 1.0

        sender.layer.shadowOpacity = 1
        sender.contentView.layer.borderColor = UIColor.clear.cgColor
        sender.contentView.layer.masksToBounds = true

        sender.layer.shadowColor = UIColor.black.cgColor

        sender.layer.shadowOffset = .zero//CGSize(width: 20, height: 7.0)
        sender.layer.shadowRadius = 2.0
        sender.layer.shadowOpacity = 0.4
        sender.layer.masksToBounds = false
        sender.layer.shadowPath = UIBezierPath(ovalIn: contactRect).cgPath
        //sender.layer.shadowPath = UIBezierPath.init(roundedRect: CGRect(x: sender.bounds.origin.x - 10, y: sender.bounds.origin.y, width: sender.bounds.width+20, height: sender.bounds.height+5), cornerRadius: sender.contentView.layer.cornerRadius).cgPath

        

    }
	// MARK:- Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "petSegue" {
			if let index = sender as? IndexPath {
				let pvc = segue.destination as! PetsViewController
				let friend = fetchedRC.object(at: index)
				if let pets = friendPets[friend.name!] {
					pvc.pets = pets
				}
				pvc.petAdded = {
					self.friendPets[friend.name!] = pvc.pets
				}
			}
		}
	}

	// MARK:- Actions
	@IBAction func addFriend() {
		let data = FriendData()
        let friend = Friend(entity: Friend.entity(), insertInto: context)
        friend.name = data.name
        friend.address = data.address
        friend.dob = data.dob as NSDate
        friend.eyeColor = data.eyeColor
        appDelegate.saveContext()
        refresh()
        collectionView.reloadData()
        
    }
	
	// MARK:- Private Methods
	private func showEditButton() {
        guard let objs = fetchedRC.fetchedObjects else {
            return
        }
		if objs.count > 0 {
			navigationItem.leftBarButtonItem = editButtonItem
		}
	}
}

// Collection View Delegates
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let count = fetchedRC.fetchedObjects?.count ?? 0
		return count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendCell", for: indexPath) as! FriendCell
		let friend = fetchedRC.object(at: indexPath)
		cell.nameLabel.text = friend.name!
        cell.addressLabel.text = friend.address
        cell.ageLabel.text = "Age: \(friend.age)"
        cell.eyeColorView.backgroundColor = friend.eyeColor as? UIColor
        if let data = friend.photo as Data? {
            cell.pictureImageView.image = UIImage(data: data)
        } else {
            cell.pictureImageView.image = UIImage(named: "person-placeholder")
        }
        collectionViewCellShadow(sender: cell)
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if isEditing {
			selected = indexPath
			self.navigationController?.present(picker, animated: true, completion: nil)
		} else {
			performSegue(withIdentifier: "petSegue", sender: indexPath)
		}
	}
    
    private func refresh(){
        let request = Friend.fetchRequest() as NSFetchRequest<Friend>
        
        //let sort = NSSortDescriptor(keyPath: \Friend.name, ascending: true)
        if !query.isEmpty {
            request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", query)
        }
        let sort = NSSortDescriptor(key: #keyPath(Friend.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        request.sortDescriptors = [sort]
        
        do {
            fetchedRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            try fetchedRC.performFetch()
        } catch let error as NSError {
            print("Could have an error: \(error)")
        }
    }
}

// Search Bar Delegate
extension MainViewController:UISearchBarDelegate {
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
        refresh()
		searchBar.text = nil
		searchBar.resignFirstResponder()
		collectionView.reloadData()
	}
}

// Image Picker Delegates
extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		let image = info[UIImagePickerControllerOriginalImage] as! UIImage
		let friend = fetchedRC.object(at: selected)
		friend.photo = UIImagePNGRepresentation(image) as NSData?
        appDelegate.saveContext()
		collectionView?.reloadItems(at: [selected])
		picker.dismiss(animated: true, completion: nil)
	}
}


