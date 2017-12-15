//
//  Extensions.swift
//  Armonia Social CERO
//
//  Created by Alfonso Tapia on 7/3/17.
//  Copyright © 2017 Paranoid Interactive. All rights reserved.
//

import Foundation
import UIKit
import SWRevealViewController

extension String {
    subscript (i: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: CountableClosedRange<Int>) -> String {
        get {
            let startIndex =  self.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.index(startIndex, offsetBy: r.upperBound - r.lowerBound)
            return String(String(self[startIndex...endIndex]))
        }
    }
    
    func charAt(_ index:Int?) -> String? {
        var result : String?
        if let i = index {
            result =  self[i]
        }
        return result
    }
    
    func distanceOfFirst(character: Character) -> Int? {
        guard let index = index(of: character) else { return nil }
        return distance(from: startIndex, to: index)
    }
    
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func containsOnlyCharactersIn(_ matchCharacters: String) -> Bool {
        let disallowedCharacterSet = CharacterSet(charactersIn: matchCharacters).inverted
        return self.rangeOfCharacter(from: disallowedCharacterSet) == nil
    }
    
    func isValidEmail() -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    func checkMatching(_ with:[String]) -> Bool {
        for s in with{
            if self.lowercased().contains(s.lowercased()){
                return true
            }
        }
        return false
    }
    
    mutating func makeUrl(){
        let s = self
        let newString = s.replacingOccurrences(of: " ", with: "%20", options: NSString.CompareOptions.literal, range: nil)
        self = newString
    }
}

extension UIViewController {
    func revealViewControllerSetup(with button:UIBarButtonItem){
        if self.revealViewController() != nil {
            button.target = self.revealViewController()
            button.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
}
