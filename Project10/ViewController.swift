//
//  ViewController.swift
//  Project10
//
//  Created by Guga Dolidze on 9/5/23.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // An array to store Person objects
    var people = [Person]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up a "+" button in the navigation bar to add a new person
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPerson))
    }
    
    // MARK: Collection View Data Source
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return the number of items (people) in the collection view
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Dequeue a reusable cell for the collection view
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            // If there's an issue with dequeuing, raise a fatal error
            fatalError("Unable to dequeue PersonCell.")
        }
        
        // Get the person object for the current cell
        let person = people[indexPath.item]
        
        // Set the cell's name label to the person's name
        cell.name.text = person.name
        
        // Load and set the person's image in the cell
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        // Apply styling to the image view and cell
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        // Return the configured cell
        return cell
    }
    
    // MARK: Add Person Function
    
    @objc func addPerson() {
        // Create an image picker controller to select a photo
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        
        // Present the image picker to the user
        present(picker, animated: true)
    }
    
    // MARK: Image Picker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Retrieve the edited image from the image picker
        guard let image = info[.editedImage] as? UIImage else { return }
        
        // Generate a unique image name using UUID
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        // Compress and save the image as JPEG
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        // Create a Person object with the image name and add it to the people array
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        
        // Reload the collection view to display the new person
        collectionView.reloadData()
        
        // Dismiss the image picker
        dismiss(animated: true)
    }
    
    // MARK: Helper Function to Get Documents Directory
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // MARK: Collection View Delegate - Handle Cell Selection
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = people[indexPath.item]
        
        // Create an alert to rename the selected person
        let ac = UIAlertController(title: "Rename Person", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        // Add Cancel and OK actions to the alert
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            // Update the person's name with the new name entered by the user
            guard let newName = ac?.textFields?[0].text else { return }
            person.name = newName
            
            // Reload the collection view to reflect the updated name
            self?.collectionView.reloadData()
        })
        
        // Present the alert to the user
        present(ac, animated: true)
    }
}

