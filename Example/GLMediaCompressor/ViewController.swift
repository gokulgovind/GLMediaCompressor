//
//  ViewController.swift
//  GLMediaCompressor
//
//  Created by vijay-gonuclei on 01/22/2020.
//  Copyright (c) 2020 vijay-gonuclei. All rights reserved.
//

import UIKit
import AVFoundation
import GLMediaCompressor

class ViewController: UIViewController {

    var messageId:String {
        get {
            return UUID().uuidString.replacingOccurrences(of: "-", with: "")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func imagePicker(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.mediaTypes = ["public.image","public.movie"]
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title:"Camera", style: .default, handler: {
            action in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "Photo & Video Library", style: .default, handler: {
            action in
            imagePicker.sourceType = .savedPhotosAlbum
            self.present(imagePicker, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        switch info[UIImagePickerControllerMediaType] as! String {
        case "public.image" :
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                let compressor = GLImageCompressor.shared
                #if DEBUG
                compressor.preference.ENABLE_SIZE_LOG = true
                #endif
                let compressedOutput = compressor.compressImage(image: image)
                showCompletionAlert(original: compressedOutput.originSize,
                                    compressed: compressedOutput.compressedSize,
                                    image: compressedOutput.image)
            }

        case "public.movie" :
            if let videoURL = info[UIImagePickerControllerMediaURL] as? URL {
                let outputURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(messageId).mp4")
               
                let compressor = GLVideoCompressor.shared
                #if DEBUG
                compressor.preference.ENABLE_SIZE_LOG = true
                #endif
//                compressor.compressFile(urlToCompress: videoURL, outputURL: outputURL) { (outputURL, originalSize, compressedSize) in
//                    self.showCompletionAlert(original: originalSize, compressed: compressedSize, videoURl: outputURL.path)
//                }
                compressor.compressVideoUsingExportSession(inputURL: videoURL, outputURL: outputURL) { (outputURL, originalSize, compressedSize) in
                    self.showCompletionAlert(original: originalSize, compressed: compressedSize, videoURl: outputURL.path)
                }
            }

        default:
            break
        }
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func showCompletionAlert(original: String, compressed: String, videoURl:String? = nil, image:UIImage? = nil) {
        let alert = UIAlertController(title: nil, message: "Media of \(original) has been compressed to \(compressed)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Save to album", style: .default, handler: { (action) in
            if let url = videoURl {
                CustomPhotoAlbum.sharedInstance.save(videoFilePath: url)
            }else{
                CustomPhotoAlbum.sharedInstance.save(image: image!)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        
    }
}

extension Data {
    func verboseFileSizeInMB() -> String{
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB]
        bcf.countStyle = .file
        let fileSize = bcf.string(fromByteCount: Int64(self.count))
        return fileSize
    }
}
