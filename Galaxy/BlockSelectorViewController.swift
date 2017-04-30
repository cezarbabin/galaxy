//
//  BlockSelectorViewController.swift
//  Galaxy
//
//  Created by Cezar Babin on 4/26/17.
//  Copyright © 2017 Cezar Babin. All rights reserved.
//

import UIKit
import Photos
import Swifter

class BlockSelectorViewController: UIViewController {
    
    var imagePicker = UIImagePickerController()
    var session : WebSocketSession?
    var element : String? 
    
    @IBOutlet weak var dismissBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var colorBtn: UIButton!
    @IBOutlet weak var videoBtn: UIButton!
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        self.dismissBtn.layer.cornerRadius = 15
        self.dismissBtn.layer.borderWidth = 1
        self.dismissBtn.layer.borderColor = UIColor.clear.cgColor
        
        self.confirmBtn.layer.cornerRadius = 15
        self.confirmBtn.layer.borderWidth = 1
        self.confirmBtn.layer.borderColor = UIColor.clear.cgColor
        
        self.cameraBtn.layer.cornerRadius = 20
        self.cameraBtn.layer.borderWidth = 1
        self.cameraBtn.layer.borderColor = UIColor.clear.cgColor
        
        self.colorBtn.layer.cornerRadius = 20
        self.colorBtn.layer.borderWidth = 1
        self.colorBtn.layer.borderColor = UIColor.clear.cgColor
        
        self.videoBtn.layer.cornerRadius = 20
        self.videoBtn.layer.borderWidth = 1
        self.videoBtn.layer.borderColor = UIColor.clear.cgColor
        
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = .savedPhotosAlbum;
        self.imagePicker.allowsEditing = false
    }
    
    @IBAction func imagePickerPressed(sender: UIButton) {
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
}

extension BlockSelectorViewController : UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: { () -> Void in
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let currentDirectoryURL = URL(fileURLWithPath: Bundle.main.resourcePath!)
        let currentUrl = info["UIImagePickerControllerReferenceURL"] as! URL
        let imageName = (currentUrl.absoluteString as NSString)
            .replacingOccurrences(of: "assets-library://asset/asset.PNG?id=", with: "")
            .replacingOccurrences(of:"&ext=PNG", with:"")
            .replacingOccurrences(of: "assets-library://asset/asset.JPG?id=", with: "")
            .replacingOccurrences(of:"&ext=JPG", with:"")
        
        var item: PHAsset = PHAsset.fetchAssets(withALAssetURLs: [currentUrl], options: nil)[0]
        let phManager = PHImageManager.default
        let options = PHImageRequestOptions()
        options.isSynchronous = true; // do it if you want things running in background thread
        phManager().requestImageData(for: item, options: options) { imageData,dataUTI,orientation,info in
            if let newData:NSData = imageData! as NSData
            {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                newData.write(toFile: documentsPath + "/\(imageName).png", atomically: true)
                if self.session != nil {
                    self.session?.writeText("/\(imageName).png")
                    JSONUtil.saveJsonData(type:"image", name:"\(imageName).png", element:self.element!)
                }
            }
        }
        self.dismiss(animated: true, completion: { () -> Void in })
    }
}

extension BlockSelectorViewController : UINavigationControllerDelegate {
    
}
