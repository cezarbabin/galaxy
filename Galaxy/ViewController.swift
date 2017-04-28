//
//  ViewController.swift
//  Galaxy
//
//  Created by Cezar Babin on 4/22/17.
//  Copyright © 2017 Cezar Babin. All rights reserved.
//

import UIKit
import Swifter
import Starscream
import Photos
import WebKit
import Firebase

class ViewController: UIViewController {

    var webView: WKWebView!
    
    var socket = WebSocket(url: URL(string: "ws://127.0.0.1:8080/websocket-echo")!, protocols: ["chat", "superchat"])
    
    var imagePicker = UIImagePickerController()
    
    var blockSelector : BlockSelectorViewController?
    
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var editorView: UIView!
    
    
    @IBAction func temporary(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "BlockViewController")
        controller.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.blockSelector = controller as? BlockSelectorViewController
        
        //self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func alternateView(_ sender: Any) {
        self.alternateView(toMain:false)
    }
    
    @IBOutlet weak var editModeSwitchView: UISwitch!
    @IBAction func editModeSwitch(_ sender: Any) {
        if self.session != nil {
            print("YES SWITCH");
            session?.writeText("switch")
        }
    }
    
    @IBAction func doneEditing(_ sender: Any) {
        self.alternateView(toMain:true)
    }
    
    @IBAction func imagePickerPressed(sender: UIButton) {
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func publishPage(_ sender: Any) {
        //open the json file
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true)[0]
        
        let json : [String : Any]? = retrieveJsonData()
        
        print (json)
        
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
    
    var session : WebSocketSession?
    var element : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView(frame: .zero)
        webView.uiDelegate = self
        webView.frame = CGRect(x: self.view.frame.origin.x,
                               y: self.view.frame.origin.y,
                               width: self.view.frame.size.width,
                               height: self.view.frame.size.height)

        view.addSubview(webView)
        view.bringSubview(toFront: webView)
        view.addSubview(topView)
        view.bringSubview(toFront: topView)
        view.addSubview(editorView)
        view.bringSubview(toFront: editorView)
        editorView.isHidden = true
        
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = .savedPhotosAlbum;
        self.imagePicker.allowsEditing = false
        
        setupBlockSelector()
        moveFilesToDocs()
        
        let server = HttpServer()
        server["/websocket-echo"] = websocket({ (session, text) in
            print (text)
            self.session = session
            
            var message = text.characters.split{$0 == "#"}.map(String.init)
            if message[0] == "COORD" {
                print ("we got coordinates")
               
               
                
                self.saveJsonDataPosition(index: message[1], x: message[2], y: message[3])
               
                
            // HANDLE ALL EVENTS
            } else if message[0] == "PING" {
                //print ("we got preliminary coordinates")
                /*
                let path = NSSearchPathForDirectoriesInDomains(
                    .documentDirectory,
                    .userDomainMask,
                    true)[0]
                
                let json : [String : Any]? = self.retrieveJsonData()
                
                print (json)
                */
                
            } else if text != "Ping" {
                DispatchQueue.main.async {
                    if self.blockSelector != nil {
                        self.present(self.blockSelector!, animated: true, completion: nil)
                    }
                }
                
                self.element = text
            }
            
        }, { (session, binary) in
            session.writeBinary(binary)
        })
        
        do {
            try server.start(8080)
        } catch {
            print("server could not start")
        }
        
        startServer()
        startWebSocket()
    }

    override func viewWillAppear(_ animated: Bool) {
        //view.bringSubview(toFront: btn)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupBlockSelector() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "BlockViewController")
        controller.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.blockSelector = controller as? BlockSelectorViewController
    }
    
    func moveFilesToDocs(){
        copyBundleToDocs(name:"index", ext:".html")
        copyBundleToDocs(name:"pixi", ext:".js")
        copyBundleToDocs(name:"mini", ext:".jpg")
        copyBundleToDocs(name:"index", ext:".html")
        copyBundleToDocs(name:"data", ext:".json")
        copyBundleToDocs(name:"square_green", ext:".png")
    }
    
    func startWebSocket () {
        self.socket.delegate = self
        self.socket.connect()
    }

    func startServer () {
        let server = demoServer(Bundle.main.resourcePath!)
        
        let currentDirectoryURL =  URL(string: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])!
        let editorURL = URL(string: "Editor", relativeTo:currentDirectoryURL)
        
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: currentDirectoryURL, includingPropertiesForKeys: nil, options: [])
            //print(directoryContents)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        server["/:path"] = shareFilesFromDirectory(currentDirectoryURL.path)
        do {
            try server.start(9080)
        } catch {
            print("server could not start")
        }

        let myRequest = NSURLRequest(url: URL(string: "http://127.0.0.1:9080")!)
        
        //let myRequest = NSURLRequest(url: URL(string: "http://codepen.io/anon/pen/NjpqER")!)
        self.webView.load(myRequest as URLRequest)
    }

}

extension ViewController : WebSocketDelegate {
    
    func websocketDidConnect(socket: WebSocket) {
        print ("websocket is connected")
        //socket.write(string:"Hello")
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print ("websocket is disconnected: \(error?.localizedDescription)")
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        print ("got some message: \(text)")
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        print("got some data: \(data.count)")
    }
    
}

extension ViewController : UIImagePickerControllerDelegate {
    
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
                    self.saveJsonData(type:"image", name:"\(imageName).png", element:self.element!)
                }
                
                /* PRINT DIRECTORY
                do {
                    let directoryContents = try FileManager.default.contentsOfDirectory(at: currentDirectoryURL, includingPropertiesForKeys: nil, options: [])
                    //print(directoryContents)
                } catch let error as NSError {
                    //print(error.localizedDescription)
                }
                */
            }
        }

        self.dismiss(animated: true, completion: { () -> Void in })
    }
    
    func saveJsonData(type:String, name:String, element:String){
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true)[0] + "/data.json"
        
        var validDictionary : [String : Any]
        var jsonData = NSData(contentsOfFile: path)
        do{
            validDictionary = try JSONSerialization.jsonObject(with: jsonData! as Data, options: .mutableContainers) as! [String : Any]
            validDictionary[element] = ["type" : type, "name" : name]
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
    
    func saveJsonDataPosition(index:String, x:String, y:String){
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
    
    func retrieveJsonData() -> [String : Any]? {
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
    
    func copyBundleToDocs(name:String, ext:String) {
        let bundlePath = Bundle.main.path(forResource: name, ofType: ext)
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let fileManager = FileManager.default
        let fullDestPath = NSURL(fileURLWithPath: documentsPath).appendingPathComponent(name + ext)
        let fullDestPathString = fullDestPath?.path
        
        do{
            if ext == ".json" {
                print ("YES JSON")
                let fileExists = FileManager().fileExists(atPath: fullDestPathString!)
                if !fileExists {
                    try fileManager.copyItem(atPath: bundlePath!, toPath: fullDestPathString!)
                }
            } else if ext == ".html" {
                try fileManager.removeItem(atPath: fullDestPathString!)
                try fileManager.copyItem(atPath: bundlePath!, toPath: fullDestPathString!)
            } else {
                try fileManager.copyItem(atPath: bundlePath!, toPath: fullDestPathString!)
            }
        }catch{
            print("\n ////?ERRROR")
            print(error)
        }
    }
}

extension ViewController : UINavigationControllerDelegate {
    
}

extension ViewController : WKUIDelegate {
   
}

extension ViewController {
    
    func alternateView(toMain:Bool) {
        print ("here")
        if toMain {
            editorView.isHidden = true
            topView.isHidden = false
        } else {
            editorView.isHidden = false
            topView.isHidden = true
        }
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

