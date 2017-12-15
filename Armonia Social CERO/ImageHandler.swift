//
//  ImageHandler.swift
//  Armonia Social CERO
//
//  Created by Alfonso Tapia on 8/31/17.
//  Copyright © 2017 Paranoid Interactive. All rights reserved.
//

import Foundation
import UIKit

class ImageHandler {
    
    static func resizeImage(image: UIImage, targetSize: CGSize)throws -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
            throw ImageConversion.ResizeFailure
        }
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    static func makePng(image:UIImage)throws -> Data {
        guard let data = UIImagePNGRepresentation(image) else {
            throw ImageConversion.DataConversionFailed
        }
        return data
    }
    
}
