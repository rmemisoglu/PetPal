//  Created by Ramazan Memişoğlu on 8.08.2019.
//  Copyright © 2019 Razeware. All rights reserved.

import UIKit

class MainViewController: UIViewController {
	@IBOutlet private weak var collectionView:UICollectionView!
	
	private var friends = [String]()
	private var filtered = [String]()
	private var isFiltered = false
	private var friendPets = [String:[String]]()
	private var selected:IndexPath!
	private var picker = UIImagePickerController()
	private var images = [String:UIImage]()

	override func viewDidLoad() {
		super.viewDidLoad()
		picker.delegate = self
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK:- Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "petSegue" {
			if let index = sender as? IndexPath {
				let pvc = segue.destination as! PetsViewController
				let friend = friends[index.row]
				if let pets = friendPets[friend] {
					pvc.pets = pets
				}
				pvc.petAdded = {
					self.friendPets[friend] = pvc.pets
				}
			}
		}
	}

	// MARK:- Actions
	@IBAction func addFriend() {
		var friend = FriendData()
		while friends.contains(friend.name) {
			friend = FriendData()
		}
		friends.append(friend.name)
		let index = IndexPath(row:friends.count - 1, section:0)
		collectionView?.insertItems(at: [index])
	}
	
	// MARK:- Private Methods
	private func showEditButton() {
		if friends.count > 0 {
			navigationItem.leftBarButtonItem = editButtonItem
		}
	}
}

// Collection View Delegates
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let count = isFiltered ? filtered.count : friends.count
		return count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendCell", for: indexPath) as! FriendCell
		let friend = isFiltered ? filtered[indexPath.row] : friends[indexPath.row]
		cell.nameLabel.text = friend
		if let image = images[friend] {
			cell.pictureImageView.image = image
		}
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
}

// Search Bar Delegate
extension MainViewController:UISearchBarDelegate {
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		guard let query = searchBar.text else {
			return
		}
		isFiltered = true
		filtered = friends.filter({(txt) -> Bool in
			return txt.contains(query)
		})
		searchBar.resignFirstResponder()
		collectionView.reloadData()
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		isFiltered = false
		filtered.removeAll()
		searchBar.text = nil
		searchBar.resignFirstResponder()
		collectionView.reloadData()
	}
}

// Image Picker Delegates
extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		let image = info[UIImagePickerControllerOriginalImage] as! UIImage
		let friend = isFiltered ? filtered[selected.row] : friends[selected.row]
		images[friend] = image
		collectionView?.reloadItems(at: [selected])
		picker.dismiss(animated: true, completion: nil)
	}
}


