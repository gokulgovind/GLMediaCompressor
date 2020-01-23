//
//  GLImageCompressor.swift
//  Compression
//
//  Created by Gokul on 20/01/20.
//  Copyright © 2020 GLabs. All rights reserved.
//

import UIKit

public class GLImageCompressor: NSObject {
    public static var shared = GLImageCompressor()
    
    /// Can override the predefined preference by using this.
    public var preference = GLImageCompressionPreference.shared
    
    /// To compress image based on *GLImageCompressor.shared.preference* value.
    ///
    /// - Parameter image: Input image
    /// - Returns: Out put Image and Data
    public func compressImage(image: UIImage) -> (UIImage?, Data?) {
        if preference.ENABLE_SIZE_LOG {
            print("#Image compression before: \(UIImageJPEGRepresentation(image, 1)!.verboseFileSizeInMB())")
        }
        let compressionSize = GLUtility.shared.getCompressionRatio(actualSize: CGSize(width: image.size.width, height: image.size.height), isVideo: false)
        let rect = CGRect(x: 0.0, y: 0.0, width: compressionSize.width, height: compressionSize.height)
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        guard let img = UIGraphicsGetImageFromCurrentImageContext() else {
            return (nil,nil)
        }
        UIGraphicsEndImageContext()
        guard let imageData = UIImageJPEGRepresentation(img, preference.compressionQuality)else {
            return (nil,nil)
        }
        if preference.ENABLE_SIZE_LOG {
            print("#Image compression after: \(imageData.verboseFileSizeInMB())")
        }
        return (UIImage(data: imageData),imageData)
    }
}
