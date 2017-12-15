//
//  Downloader.swift
//  Armonia Social CERO
//
//  Created by Alfonso Tapia on 7/1/17.
//  Copyright © 2017 Paranoid Interactive. All rights reserved.
//

import Foundation
import Alamofire

class Networking{
    
    static func downloadData(from url:String, completionHandler: @escaping (Error?,Data?)->()){
        guard let url = URL(string: url) else {return}
        Alamofire.request(url).responseData {
            (response) in
            completionHandler(response.error,response.data)
        }
    }
}
