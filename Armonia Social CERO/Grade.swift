//
//  Grade.swift
//  Armonia Social CERO
//
//  Created by Alfonso Tapia on 10/4/17.
//  Copyright © 2017 Paranoid Interactive. All rights reserved.
//

import Foundation

struct Grade:Encodable {
    var note:String?
    var score:Int?
    var sender:String?
    var senderLevel:Int?
    var options:[String]?
    
    var isReady:(Bool,String?) {
        guard let _ = score else {return(false,"Score")}
        guard let options = options else {return(false,"Options")}
        guard options.count > 0 else {return(false,"Options")}
        return(true,nil)
    }
}

extension Grade{
    
    enum CodingKeys: String, CodingKey {
        case note = "Note"
        case score = "Score"
        case sender = "Sender"
        case senderLevel = "SenderLevel"
        case options = "Options"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(score, forKey: .score)
        try container.encodeIfPresent(score, forKey: .note)
        try container.encode(sender, forKey: .sender)
        try container.encode(senderLevel, forKey: .senderLevel)
        let dict = options?.enumerated().flatMap{return ["Option\($0.offset)":$0.element]}.reduce([String:String]())
        {
            if var dict = $0 {
                dict[$1.key] = $1.value
                return dict
            }
            return $0
        }
        try container.encode(dict, forKey: .options)
    }
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}
