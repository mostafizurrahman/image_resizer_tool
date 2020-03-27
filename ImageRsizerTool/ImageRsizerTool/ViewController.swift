//
//  ViewController.swift
//  ImageRsizerTool
//
//  Created by Mostafizur Rahman on 26/3/20.
//  Copyright © 2020 Mostafizur Rahman. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var prefixTextField: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func resizeImage(_ sender: Any) {
        
        let _text = self.prefixTextField.stringValue
        
         let url = NSURL(fileURLWithPath:  "/Users/mostafizurrahman/Downloads/image_resizer")
        let iconUrl =  NSURL(fileURLWithPath: "/Users/mostafizurrahman/Downloads/image_resizer/icons") as URL
        let fileManager = FileManager.default

        let properties = [URLResourceKey.localizedNameKey,
                          URLResourceKey.creationDateKey,
                          URLResourceKey.localizedTypeDescriptionKey]

        let isSecuredURL = url.startAccessingSecurityScopedResource() == true
        let coordinator = NSFileCoordinator()
        var error: NSError? = nil
        coordinator.coordinate(readingItemAt: url as URL, options: [], error: &error) { (url) -> Void in
            do {
                // do something
                
                let imageURLs = try fileManager.contentsOfDirectory(at: url as URL, includingPropertiesForKeys: properties, options:FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)

                // Create image from URL
                
                
                var index = 0

                var json = ""
                for imageUrl in imageURLs {
                    if !imageUrl.lastPathComponent.contains("icon") {

                        let firstImageData = try Data(contentsOf: imageUrl)
                        if let firstImage = NSImage(data: firstImageData) {
                            if let image = firstImage.representations.first as? NSBitmapImageRep {
                                let _iconSize:CGFloat = 275.0
                                let _width = firstImage.size.width
                                let _height = firstImage.size.height
                                let _ratio = _width / _height
                                var frame:NSRect = .zero
                                var _originX:CGFloat = 0
                                var _originY:CGFloat = 0
                                var _dimension:CGFloat = 0
                                if _ratio > 1.0 {
                                    _dimension =  _height
                                    _originX = _width / 2 - _height / 2
                                    frame = NSRect(x: _originX, y: 0, width: _dimension, height: _dimension)
                                } else {
                                    _dimension = _width
                                    _originY = _height / 2 - _width / 2
                                    frame = NSRect(x: 0, y: _originY, width: _dimension, height: _dimension)
                                }
                                
                                let outputImage = NSImage(size: frame.size,
                                                          flipped: false,
                                                          drawingHandler: { (_) -> Bool in
                                    return image.draw(in: NSRect(x: -_originX, y: -_originY,
                                                                 width: _width, height: _height))
                                })
                                let _outUrl = url.appendingPathComponent("\(_text)\(index).jpg")
                                self.save(Image: outputImage, url: _outUrl)
                                
                                let iconImage = NSImage(size: NSSize(width: _iconSize, height: _iconSize ),
                                                        flipped: false,
                                                        drawingHandler: { (_) -> Bool in
                                    return image.draw(in: NSRect(x: -_originX*_iconSize/_width,
                                                                 y: -_originY*_iconSize/_height,
                                                                 width: _iconSize * (_ratio > 1.0 ? _ratio : 1.0),
                                                                 height: _iconSize / (_ratio < 1.0 ? _ratio : 1.0)))
                                })
                                let _iconUrl = iconUrl.appendingPathComponent("\(_text)\(index)_icon.jpg")
                                self.save(Image: iconImage, url: _iconUrl)
                                
                                json.append("{\n")
                                json.append("\"image_id\" : \"\(_text)_\(index)\",\n")
                                json.append("\"image_title\" : \"Cartoon\",\n")
                                json.append("\"image_file\" : \"\(_outUrl.lastPathComponent)\",\n")
                                json.append("\"image_icon\" : \"\(_iconUrl.lastPathComponent)\",\n")
                                json.append("\"dimension\" : \"\(_dimension)\",\n")
                                json.append("\"premium\" : \(true),\n")
                                json.append("\"ondemand\" : \(true)\n},\n")
                                index += 1
                                
                                try fileManager.removeItem(at: imageUrl)
                            }
                        }
                    }
                }
                guard let _data = json.data(using: .utf8) else  {
                    return
                }
                try _data.write(to:  url.appendingPathComponent("data.json"))
                print("JSON \(json)")
            } catch {
                print(error.localizedDescription)
                // something went wrong
            }
        }
        if (isSecuredURL) {
            url.stopAccessingSecurityScopedResource()
        }
        
    }
    
    fileprivate func save(Image outputImage:NSImage, url _outUrl:URL){
        guard let _tiffData = outputImage.tiffRepresentation else {
            print("___WHY")
            return
            
        }
        
        if let bitmap = NSBitmapImageRep(data: _tiffData) {
            
            let data = bitmap.representation(using: .jpeg, properties: [:])
            do {
                
               try data?.write(to: _outUrl)
                print("write success")
            } catch {
                print("\(error.localizedDescription)")
            }
        }
    }
    
}

