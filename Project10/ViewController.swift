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
        
        // Load saved data from UserDefaults when the view loads
        let defaults = UserDefaults.standard
        if let savedPeople = defaults.object(forKey: "people") as? Data {
            let jsonDecoder = JSONDecoder()

            do {
                // Decode saved data into an array of Person objects
                people = try jsonDecoder.decode([Person].self, from: savedPeople)
            } catch {
                print("Failed to load people")
            }
        }
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
        // Create an alert to let the user choose between taking a photo and picking from the photo library
        let alertController = UIAlertController(title: "Add a Photo", message: nil, preferredStyle: .actionSheet)

        // Add action to use the camera
        alertController.addAction(UIAlertAction(title: "Take a Photo", style: .default) { [weak self] _ in
            self?.showImagePicker(sourceType: .camera)
        })

        // Add action to pick from the photo library
        alertController.addAction(UIAlertAction(title: "Choose from Library", style: .default) { [weak self] _ in
            self?.showImagePicker(sourceType: .photoLibrary)
        })

        // Add cancel action
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // Present the alert to the user
        present(alertController, animated: true, completion: nil)
    }
    
    func showImagePicker(sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let picker = UIImagePickerController()
            picker.sourceType = sourceType
            picker.allowsEditing = true
            picker.delegate = self
            present(picker, animated: true)
        } else {
            // Handle the case where the selected source type is not available
            let alertController = UIAlertController(title: "Source Not Available", message: "The selected source is not available on this device.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
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
        
        // Save the updated people array
        save()
        
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
        
        // Create an alert to ask the user whether to rename or delete the selected person
        let ac = UIAlertController(title: "Options for \(person.name)", message: nil, preferredStyle: .alert)
        
        // Add Rename action to the alert
        ac.addAction(UIAlertAction(title: "Rename", style: .default) { [weak self] _ in
            self?.renamePerson(person)
        })
        
        // Add Delete action to the alert
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deletePerson(at: indexPath)
        })
        
        // Add Cancel action to the alert
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Present the alert to the user
        present(ac, animated: true)
    }
    
    func renamePerson(_ person: Person) {
        let ac = UIAlertController(title: "Rename \(person.name)", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            guard let newName = ac?.textFields?[0].text else { return }
            // Update the person's name and save the changes
            person.name = newName
            self?.save()
            // Reload the collection view to reflect the updated name
            self?.collectionView.reloadData()
        })
        
        present(ac, animated: true)
    }

    func deletePerson(at indexPath: IndexPath) {
        // Remove the person from the array and delete their image file
        let person = people.remove(at: indexPath.item)
        let imagePath = getDocumentsDirectory().appendingPathComponent(person.image)
        
        do {
            try FileManager.default.removeItem(at: imagePath)
        } catch {
            print("Error deleting image: \(error)")
        }
        
        // Reload the collection view to reflect the removal
        collectionView.reloadData()
    }

    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(people) {
            let defaults = UserDefaults.standard
            // Save the encoded data in UserDefaults
            defaults.set(savedData, forKey: "people")
        } else {
            print("Failed to save people.")
        }
    }
}
