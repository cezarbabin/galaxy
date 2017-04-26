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
    
    /*
    private override init() {
        self.storage = FIRStorage.storage()
        self.storageRef  = self.storage.reference()
    }
     */
    
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
        
        print (localFile)
        
        // Create a reference to the file you want to upload
        let riversRef : FIRStorageReference
        if fileExt == ".json" {
            riversRef = self.storageRef.child("configs/" + fileName + fileExt)
        } else {
            riversRef = self.storageRef.child("images/" + fileName + fileExt)
        }
        
        //let metadata = FIRStorageMetadata()
        //metadata.contentType = "image/png"
        
        ifFileDoesNotExist(fileName: fileName, fileExt: fileExt) {
            let _ = riversRef.putFile(localFile, metadata: nil) { metadata, error in
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
                print ("No such file exists")
                completion()
            } else {
                // Get the download URL for 'images/stars.jpg'
                //returnValue = false
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
                //returnValue = false
                print ("File Exists So It Will Be Deleted")
                then()
            }
        }
    }


}
