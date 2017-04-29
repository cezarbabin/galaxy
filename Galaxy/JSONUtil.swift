//
//  JSONUtil.swift
//  Galaxy
//
//  Created by Cezar Babin on 4/28/17.
//  Copyright © 2017 Cezar Babin. All rights reserved.
//

import UIKit

class JSONUtil: NSObject {
    public static func saveJsonData(type:String, name:String, element:String){
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true)[0] + "/data.json"
        
        var validDictionary : [String : Any]
        var jsonData = NSData(contentsOfFile: path)
        do{
            validDictionary = try JSONSerialization.jsonObject(with: jsonData! as Data, options: .mutableContainers) as! [String : Any]
            
            let x = (validDictionary[element] as! [String : Any])["x"]!
            let y = (validDictionary[element] as! [String : Any])["y"]!
            
            validDictionary[element] = ["type" : type, "name" : name, "x":x, "y":y]
            let rawData: NSData!
            
            if JSONSerialization.isValidJSONObject(validDictionary) { // True
                do {
                    rawData = try JSONSerialization.data(withJSONObject: validDictionary, options: .prettyPrinted) as NSData
                    let success = try rawData.write(toFile: path , options: .atomic)
                    print ("JSON WRITE SUCCEEDDE \(success)")
                    
                    
                    //var jsonData = NSData(contentsOfFile: "newdata.json")
                    //var jsonDict = try JSONSerialization.jsonObject(with: jsonData! as Data, options: .mutableContainers)
                    // -> ["stringValue": "JSON", "arrayValue": [0, 1, 2, 3, 4, 5], "numericalValue": 1]
                    
                } catch {
                    print(error)
                }
            }
        } catch {
            print("Didnt open")
            print(error)
        }
    }
    
    public static func saveJsonDataPosition(index:String, x:String, y:String){
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true)[0] + "/data.json"
        
        var validDictionary : [String : Any]
        var jsonData = NSData(contentsOfFile: path)
        do{
            validDictionary = try JSONSerialization.jsonObject(with: jsonData! as Data, options: .mutableContainers) as! [String : Any]
            
            let name = (validDictionary[index] as! [String : Any])["name"]!
            let type = (validDictionary[index] as! [String : Any])["type"]!
            validDictionary[index] = ["name":name , "type":type, "x" : x, "y" : y]
            let rawData: NSData!
            
            if JSONSerialization.isValidJSONObject(validDictionary) { // True
                do {
                    rawData = try JSONSerialization.data(withJSONObject: validDictionary, options: .prettyPrinted) as NSData
                    let success = try rawData.write(toFile: path , options: .atomic)
                    print ("JSON WRITE SUCCEEDDE \(success)")
                    
                    
                    //var jsonData = NSData(contentsOfFile: "newdata.json")
                    //var jsonDict = try JSONSerialization.jsonObject(with: jsonData! as Data, options: .mutableContainers)
                    // -> ["stringValue": "JSON", "arrayValue": [0, 1, 2, 3, 4, 5], "numericalValue": 1]
                    
                } catch {
                    print(error)
                }
            }
        } catch {
            print("Didnt open")
            print(error)
        }
    }
    
    public static func retrieveJsonData() -> [String : Any]? {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true)[0] + "/data.json"
        
        var validDictionary : [String : Any]
        var jsonData = NSData(contentsOfFile: path)
        do{
            validDictionary = try JSONSerialization.jsonObject(with: jsonData! as Data, options: .mutableContainers) as! [String : Any]
            
            return validDictionary
        } catch {
            print("There was an error opening the file")
            print(error)
        }
        return nil
    }
}
