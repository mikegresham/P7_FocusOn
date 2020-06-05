//
//  TimeManager.swift
//  FocusOn
//
//  Created by Michael Gresham on 05/06/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//

import Foundation

class TimeManager {
    var today: Date {
        return startOfDay(for: Date())
    }
    var yesterday: Date {
        return today - 86400
    }
    
    func firstDayOfYear(for date: Date) -> Date {
        let year = Calendar.current.component(.year, from: date)
        let firstDayOfYear = Calendar.current.date(from: DateComponents(year: year, month: 1, day: 1))!
        return startOfDay(for: firstDayOfYear)
    }

    func firstDayOfWeek(for date: Date) -> Date{
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let difference = TimeInterval((2 - weekday) * 24 * 3600)
        return startOfDay(for: date.addingTimeInterval(difference))
    }

    func startOfDay(for date: Date) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return calendar.startOfDay(for: date)
    }
    func yearCaption(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: date)
    }
    func dateCaption(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.timeStyle = .none
        
        return dateFormatter.string(from: date)
    }
    func weekCaption(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.timeStyle = .none
        
        return "Week beginning \(dateFormatter.string(from: date))"
    }
    func monthCaption(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        return dateFormatter.string(from: date)
    }
    func monthValue(for date: Date) -> Int {
        let calendar = Calendar.current
        return calendar.component(.month, from: date)
    }
}
