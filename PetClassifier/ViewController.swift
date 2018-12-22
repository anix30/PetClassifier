//
//  ViewController.swift
//  PetClassifier
//
//  Created by xlconnie on 2018/12/22.
//  Copyright © 2018 Home. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.isEditing = false
    }
    
    //MARK: - Image picker delegate method
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickerImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
        
            imageView.image = pickerImage
            
            guard let ciimage = CIImage(image: pickerImage) else {fatalError("Convert UIImage to CIImage Failed!")}
            
            detect(ciImage: ciimage)
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func detect(ciImage: CIImage) {
        
        // First, create model
        
        guard let model = try? VNCoreMLModel(for: PetClassifier().model) else {fatalError("Loading CoreML Model Failed!")}
        
        // Second, set up request
        let request = VNCoreMLRequest(model: model) { (request, error) in
            
            guard let classifier = request.results?.first as? VNClassificationObservation else {fatalError("Model failed to process images") }
            
            self.navigationItem.title = classifier.identifier.capitalized
        }
        
        // Third, create handler
        let handler = VNImageRequestHandler(ciImage: ciImage)
        
        // Fourth, manipulate request by handler
        do {
            try handler.perform([request])
        }catch {
                print("Failed to perform vision request, \(error)")
        }
        
    }

}

