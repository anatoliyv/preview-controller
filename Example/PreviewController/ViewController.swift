//
//  ViewController.swift
//  PreviewController
//
//  Created by Anatoliy Voropay on 03/22/2017.
//  Copyright (c) 2017 Anatoliy Voropay. All rights reserved.
//

import UIKit
import PreviewController

class ViewController: UIViewController {
    
    @IBOutlet var byURLButton: UIButton!
    @IBOutlet var byPathButton: UIButton!
    @IBOutlet var byImageButton: UIButton!
    
    private var previewController: ImagePreviewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        previewController = ImagePreviewController()
        previewController?.delegate = self
    }

    @IBAction func pressed(sender: AnyObject) {
        guard let button = sender as? UIButton else { return }
        
        present(previewController, animated: true, completion: nil)
        
        if button == byURLButton {
            previewController?.preview(byURL: URL(string: "https://static.pexels.com/photos/20974/pexels-photo.jpg")!)
        } else if button == byPathButton {
            previewController.preview(byPath: "https://static.pexels.com/photos/33109/fall-autumn-red-season.jpg")
        } else if button == byImageButton {
            let image = UIImage(named: "test.png")!
            previewController.preview(image: image)
        }
    }
}

extension ViewController: ImagePreviewControllerDelegate {
    
    func imagePreviewControllerDidPressedClose(_ controller: ImagePreviewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func imagePreviewControllerDidPressedShare(_ controller: ImagePreviewController, withImage image: UIImage) {
        let activityController = UIActivityViewController(
            activityItems: [ image ],
            applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = view
        controller.present(activityController, animated: true, completion: nil)
    }
}

