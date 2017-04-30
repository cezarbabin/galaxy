//
//  FileUploader.swift
//  Galaxy
//
//  Created by Cezar Babin on 4/26/17.
//  Copyright © 2017 Cezar Babin. All rights reserved.
//

import UIKit
import Firebase

class FileUploader: NSObject {
    
    static var storageRef : FIRStorageReference {
        get {
            return FIRStorage.storage().reference()
        }
    }
    
    public static func uploadAndUpdateFileWith(filePath:String, fileName:String, fileExt:String, completion: @escaping (_ fileUrl: URL?, _ error: Error?) -> Void) {
        if fileExt == ".json" {
            ifFileExists(fileName: fileName, fileExt: fileExt, then: {
                removeOldConfig(fileName: fileName,
                                fileExt: fileExt) {
                                    uploadFileWith(filePath: filePath,
                                                   fileName: fileName,
                                                   fileExt: fileExt,
                                                   completion: completion)
                }
            }, otherwise: {
                uploadFileWith(filePath: filePath,
                               fileName: fileName,
                               fileExt: fileExt,
                               completion: completion)
            })
        } else {
            ifFileExists(fileName: fileName, fileExt: fileExt, then: {
                print("No uploading because file exists")
            }, otherwise: {
                uploadFileWith(filePath: filePath,
                               fileName: fileName,
                               fileExt: fileExt,
                               completion: completion)
            })
        }
    }
    
    public static func uploadFileWith(filePath:String, fileName:String, fileExt:String, completion: @escaping (_ fileUrl: URL?, _ error: Error?) -> Void) {

        // Get a pointer to the local file
        let localFile = URL(string: "file://" + filePath)!

        // Create a reference to the file you want to upload
        let storageRef : FIRStorageReference
        if fileExt == ".json" {
            storageRef = self.storageRef.child("configs/" + fileName + fileExt)
        } else {
            storageRef = self.storageRef.child("images/" + fileName + fileExt)
        }
        
        ifFileDoesNotExist(fileName: fileName, fileExt: fileExt) {
            let _ = storageRef.putFile(localFile, metadata: nil) { metadata, error in
                if let error = error {
                    // Uh-oh, an error occurred!
                    print("An error occured in uploading file \(fileName). Error: \(error)")
                    completion(nil, error)
                } else {
                    // Metadata contains file metadata such as size, content-type, and download URL.
                    completion(metadata!.downloadURL(), nil)
                }
            }
        }
    }
    
    public static func removeOldConfig(fileName:String, fileExt:String, completion: @escaping() -> Void) {
        let dataRef = self.storageRef.child("configs/data.json")
        
        dataRef.delete { error in
            if let error = error {
                // Uh-oh, an error occurred!
                print ("Previous config file deleted unsuccesfully \(error)")
            } else {
                // File deleted successfully
                print ("Previous config file deleted succesfully")
                completion()
            }
        }
    }
    
    private static func ifFileDoesNotExist(fileName:String, fileExt:String, completion: @escaping () -> Void)  {
        
        // Create a reference to the file you want to download
        let starsRef = storageRef.child("images/" + fileName + fileExt)
        
        // Fetch the download URL
        starsRef.downloadURL { url, error in
            if let error = error {
                completion()
            } else {
                print ("Couldn't find the download URL")
                // Get the download URL for 'images/stars.jpg'
            }
        }
    }
    
    private static func ifFileExists(fileName:String, fileExt:String, then: @escaping () -> Void, otherwise: @escaping () -> Void )  {
        
        // Create a reference to the file you want to download
        let starsRef = storageRef.child("images/" + fileName + fileExt)
        
        // Fetch the download URL
        starsRef.downloadURL { url, error in
            if let error = error {
                print ("File Doesn't Exist And Won't Be Deleted")
                otherwise()
            } else {
                // Get the download URL for 'images/stars.jpg'
                print ("File Exists So It Will Be Deleted")
                then()
            }
        }
    }


}
