//
//  JSONUtil.swift
//  Galaxy
//
//  Created by Cezar Babin on 4/28/17.
//  Copyright © 2017 Cezar Babin. All rights reserved.
//

import UIKit

class JSONUtil: NSObject {
    static var path = NSSearchPathForDirectoriesInDomains(
        .documentDirectory,
        .userDomainMask,
        true)[0] + "/data.json"
    
    public static func saveJsonData(type:String, name:String, element:String){
        var validDictionary : [String : Any]
        let jsonData = NSData(contentsOfFile: path)
        do{
            validDictionary = try JSONSerialization.jsonObject(with: jsonData! as Data, options: .mutableContainers) as! [String : Any]
            let x = (validDictionary[element] as! [String : Any])["x"]!
            let y = (validDictionary[element] as! [String : Any])["y"]!
            let scale = (validDictionary[element] as! [String : Any])["scale"]!
            validDictionary[element] = ["type":type, "name":name, "x":x, "y":y, "scale":scale]
            writeDictionaryToJson(validDictionary)
        } catch {
            print("Didnt open")
            print(error)
        }
    }
    
    public static func saveJsonDataPosition(index:String, x:String, y:String){
        var validDictionary : [String : Any]
        let jsonData = NSData(contentsOfFile: path)
        do{
            validDictionary = try JSONSerialization.jsonObject(with: jsonData! as Data, options: .mutableContainers) as! [String : Any]
            let name = (validDictionary[index] as! [String : Any])["name"]!
            let type = (validDictionary[index] as! [String : Any])["type"]!
            let scale = (validDictionary[index] as! [String : Any])["scale"]!
            validDictionary[index] = ["name":name , "type":type, "x":x, "y":y, "scale":scale]
            writeDictionaryToJson(validDictionary)
        } catch {
            print("Didnt open")
            print(error)
        }
    }
    
    public static func saveJsonDataScale(index:String, scale:String){
        var validDictionary : [String : Any]
        let jsonData = NSData(contentsOfFile: path)
        do{
            validDictionary = try JSONSerialization.jsonObject(with: jsonData! as Data, options: .mutableContainers) as! [String : Any]
            let name = (validDictionary[index] as! [String : Any])["name"]!
            let type = (validDictionary[index] as! [String : Any])["type"]!
            let x = (validDictionary[index] as! [String : Any])["x"]!
            let y = (validDictionary[index] as! [String : Any])["y"]!
            validDictionary[index] = ["name":name , "type":type, "x":x, "y":y, "scale":scale]
            writeDictionaryToJson(validDictionary)
        } catch {
            print("Didnt open")
            print(error)
        }
    }
    
    private static func writeDictionaryToJson(_ validDictionary:[String : Any]) {
        let rawData: NSData!
        if JSONSerialization.isValidJSONObject(validDictionary) { // True
            do {
                rawData = try JSONSerialization.data(withJSONObject: validDictionary, options: .prettyPrinted) as NSData
                try rawData.write(toFile: path , options: .atomic)
                print ("JSON WRITE SUCCEEDED")
            } catch {
                print(error)
            }
        }
    }
    
    public static func retrieveJsonData() -> [String : Any]? {
        var validDictionary : [String : Any]
        let jsonData = NSData(contentsOfFile: path)
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
