//
//  DateHandler.swift
//  Armonia Social CERO
//
//  Created by Alfonso Tapia on 9/29/17.
//  Copyright © 2017 Paranoid Interactive. All rights reserved.
//

import Foundation



class DateHandler{
    
    enum DateError:Error{
        case ValueNotPresent(String)
    }

    //Get current date
    let currentDateTime = Date()
    
    // get the user's calendar
    let userCalendar = Calendar.current
    
    // choose which date and time components are needed
    let requestedComponents: NSCalendar.Unit = [
        NSCalendar.Unit.year,
        NSCalendar.Unit.month,
        NSCalendar.Unit.day,
        NSCalendar.Unit.hour,
        NSCalendar.Unit.minute,
        NSCalendar.Unit.second]
    
    func getDateTime()throws -> String{
        // get the components
        let dateTimeComponents = (userCalendar as NSCalendar).components(requestedComponents, from: currentDateTime)
        guard let year = dateTimeComponents.year else {throw DateError.ValueNotPresent("Year")}
        guard let month = dateTimeComponents.month else {throw DateError.ValueNotPresent("Month")}
        guard let day = dateTimeComponents.day else {throw DateError.ValueNotPresent("Day")}
        guard let hour = dateTimeComponents.hour else {throw DateError.ValueNotPresent("Hour")}
        guard let min = dateTimeComponents.minute else {throw DateError.ValueNotPresent("Minute")}
        guard let sec = dateTimeComponents.second else {throw DateError.ValueNotPresent("Second")}
        return "\(year),\(formater(month)),\(formater(day)),\(formater(hour)):\(formater(min)):\(formater(sec))"
    }
    
    func getUTC() -> String{
        let date = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy,MM,dd,HH:mm:ss"
        formatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
        let utcTimeZoneStr = formatter.string(from: date as Date)
        return utcTimeZoneStr
    }
    
    func getHour()throws -> String{
        let dateTimeComponents = (userCalendar as NSCalendar).components(requestedComponents, from: currentDateTime)
        guard let hour = dateTimeComponents.hour else {throw DateError.ValueNotPresent("Hour")}
        guard let min = dateTimeComponents.minute else {throw DateError.ValueNotPresent("Minute")}
        return "\(formater(hour)):\(formater(min))"
    }
    
    private func formater(_ value: Int) ->String{
        return (value >= 10) ? "\(value)":"0\(value)"
    }
    
}
