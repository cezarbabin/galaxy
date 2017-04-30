//
//  PublishViewController.swift
//  Galaxy
//
//  Created by Cezar Babin on 4/28/17.
//  Copyright © 2017 Cezar Babin. All rights reserved.
//

import UIKit

class PublishViewController: UIViewController {
    
    @IBOutlet weak var publishButton: UIButton!
    @IBAction func publishButtonPressed(_ sender: Any) {
        //open the json file
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true)[0]
        
        let json : [String : Any]? = JSONUtil.retrieveJsonData()
        
        if json != nil {
            for (element, properties) in json! {
                if element != "config" {
                    let properties = properties as! [String : Any]
                    if properties != nil {
                        let name = properties["name"] as! String?
                        let fileName = name!.replacingOccurrences(of: ".png", with: "")
                        FileUploader.uploadAndUpdateFileWith(filePath: (path + "/" + name!), fileName: fileName, fileExt: ".png"){ (url, error) in
                            print(url)
                        }
                        
                    }
                }
            }
        }
        
        FileUploader.uploadAndUpdateFileWith(filePath: path + "/data.json", fileName: "data", fileExt: ".json"){ (url, error) in
            print(url)
        }

    }
    @IBOutlet weak var dimiss: UIButton!
    @IBAction func dismissClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func visitWebsite(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://tranquil-falls-49748.herokuapp.com/")!, options:[:], completionHandler: nil)
    }
    
    override func viewDidLoad() {
        self.publishButton.layer.cornerRadius = 15
        self.publishButton.layer.borderWidth = 1
        self.publishButton.layer.borderColor = UIColor.clear.cgColor
    }

    
}
