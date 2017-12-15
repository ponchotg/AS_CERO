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
    
    /*func compareTime(_ logDate: String) -> Bool{
        //2015,10,26,17:41:03
        guard let cTime = try? getDateTime() else {return false}
        let year = logDate[0...3]
        let cYear = cTime[0...3]
        let month = logDate[5...6]
        let cMonth = cTime[5...6]
        let day = logDate[8...9]
        let cDay = cTime[8...9]
        let hour = logDate[11...12]
        let cHour = cTime[11...12]
        
        let shouldCheckYear = year != cYear
        var shouldCheckMonth = month != cMonth
        var shouldCheckDay = day != cDay
        var shouldCheckHour = false
        guard shouldCheckDay || shouldCheckYear || shouldCheckMonth else {return true}
        if shouldCheckYear{
            let iYear = Int(year)
            let iCYear = Int(cYear)
            let resultYear = iCYear! - iYear!
            guard resultYear <= 1 else {return false}
            shouldCheckMonth = true
        }
        if shouldCheckMonth{
            let iMonth = Int(month)
            let iCMonth = Int(cMonth)
            let resultMonth = iCMonth! - iMonth!
            if iCMonth == 1 && iMonth == 12{
                shouldCheckDay = true
            } else {
                guard resultMonth <= 1 else {return false}
            }
        }
        if shouldCheckDay{
            guard let iDay = Int(day) else {return false}
            guard let iCDay = Int(cDay) else {return false}
            let resultday = iCDay - iDay
            if iDay >= 30 && iCDay == 1{
                shouldCheckHour = true
            } else {
                guard resultday <= 1 else {return false}
            }
        }
        if shouldCheckHour{
            guard let iHour = Int(hour) else {return false}
            guard let iCHour = Int(cHour) else {return false}
            guard iHour > iCHour else {return false}
        }
        return true
        
    }*/
    
    private func formater(_ value: Int) ->String{
        return (value >= 10) ? "\(value)":"0\(value)"
    }
    
}
