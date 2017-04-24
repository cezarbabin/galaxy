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

class ViewController: UIViewController {

    var webView: WKWebView!
    
    var socket = WebSocket(url: URL(string: "ws://127.0.0.1:8080/websocket-echo")!, protocols: ["chat", "superchat"])
    var imagePicker = UIImagePickerController()
    
    @IBOutlet weak var btn: UIButton!
    
    
    @IBAction func imagePickerPressed(sender: UIButton) {
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    var session : WebSocketSession?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                // Do any additional setup after loading the view, typically from a nib.
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        //webView.bringSubview(toFront: btn)
        //view = webView
        
        view = webView
        //view.bringSubview(toFront: webView)
        view.addSubview(btn)
        
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = .savedPhotosAlbum;
        self.imagePicker.allowsEditing = false
        
        let server = HttpServer()
        server["/websocket-echo"] = websocket({ (session, text) in
            //session.writeText(text)
            print (text)
            if text != "Ping" {
                self.present(self.imagePicker, animated: true, completion: nil)
                //print("session is a kind of \(session.class)")
                self.session = session
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
    
    func startWebSocket () {
        self.socket.delegate = self
        self.socket.connect()
    }

    func startServer () {
        let server = demoServer(Bundle.main.resourcePath!)
        
        let currentDirectoryURL = URL(fileURLWithPath: Bundle.main.resourcePath!)
        
        let editorURL = URL(string: "Editor", relativeTo:currentDirectoryURL)
        
        let editorPath = editorURL?.path
        
        //print (editorPath!)
        print ("AS STRING")
        
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
        
        /*
         server.middleware.append { request in
         print(request.address!)
         
         guard let address = request.address else {
         print ("//////THERE IS A REQUEST")
         return .forbidden
         }
         guard ["127.0.0.1", "::1"].contains(address) else {
         print ("//////ADDRESS FORBIDDEN \(address)")
         return .forbidden
         }
         
         
         return nil // pass the request to upper layer.
         }
         */
        
        let myRequest = NSURLRequest(url: URL(string: "http://127.0.0.1:9080")!)
        
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
        print ("HERE::::")
        self.dismiss(animated: true, completion: { () -> Void in print ("INSIDE::::") })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let currentDirectoryURL = URL(fileURLWithPath: Bundle.main.resourcePath!)
        
        print (info)
        
        let currentUrl = info["UIImagePickerControllerReferenceURL"] as! URL
        print(currentUrl)
        let imageName = (currentUrl.absoluteString as NSString)
            .replacingOccurrences(of: "assets-library://asset/asset.PNG?id=", with: "")
            .replacingOccurrences(of:"&ext=PNG", with:"")
            .replacingOccurrences(of: "assets-library://asset/asset.JPG?id=", with: "")
            .replacingOccurrences(of:"&ext=JPG", with:"")
        print(imageName)
        //let fileManager = FileManager.default
        
        var item: PHAsset = PHAsset.fetchAssets(withALAssetURLs: [currentUrl], options: nil)[0]
        let phManager = PHImageManager.default
        let options = PHImageRequestOptions()
        options.isSynchronous = true; // do it if you want things running in background thread
        phManager().requestImageData(for: item, options: options) { imageData,dataUTI,orientation,info in
            if let newData:NSData = imageData! as NSData
            {
                newData.write(toFile: currentDirectoryURL.path + "/\(imageName).png", atomically: true)
                //print ("Success \(currentDirectoryURL.path)")
                
                if self.session != nil {
                    self.session?.writeText("/\(imageName).png")
                    print ("Inside session")
                }
                
                
                do {
                    let directoryContents = try FileManager.default.contentsOfDirectory(at: currentDirectoryURL, includingPropertiesForKeys: nil, options: [])
                    //print(directoryContents)
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }
        
        /*
        do {
            //var pic = PHAsset.fetchAssets(withALAssetURLs: currentUrl, options: nil)
            
            try fileManager.copyItem(at: currentUrl as URL, to: currentDirectoryURL)
            print("File copying succeeded")
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
         */
        
        self.dismiss(animated: true, completion: { () -> Void in })
    }
}

extension ViewController : UINavigationControllerDelegate {
    
}

extension ViewController : WKUIDelegate {
   
}

