//
//  FirstPageViewModel.swift
//  MedInteractions
//
//  Created by Joanna Staleńczyk on 22/01/2023.
//

import Foundation
import SwiftUI

class FirstPageViewModel: ObservableObject {
    @Published var chosenDay = 0
    
    func todayDateToString() -> String {
        var dayString = ""
        var offset = 0
        
        switch chosenDay {
        case 0:
            offset = 0
            dayString.append("Today, ")
        case 1:
            offset = 1
            dayString.append("Tomorrow, ")
        case 2:
            offset = 2
        case 3:
            offset = 3
        case 4:
            offset = 4
        default:
            offset = 0
        }
        
        var dayComponent = DateComponents()
        dayComponent.day = offset
        let calendar = Calendar.current
        let nextDay =  calendar.date(byAdding: dayComponent, to: Date())!
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "d MMMM yyyy"
        dayString.append(formatter.string(from: nextDay))
        return dayString
    }
    
    func displayedDay() -> Date {
        var offset = 0
        var dayComponent = DateComponents()
        switch chosenDay {
        case 0:
            offset = 0
        case 1:
            offset = 1
        case 2:
            offset = 2
        case 3:
            offset = 3
        case 4:
            offset = 4
        default:
            offset = 0
        }
        dayComponent.day = offset
        let calendar = Calendar.current
        return calendar.date(byAdding: dayComponent, to: Date())!
    }
    
    func medicationRemindersToShow(medication: FetchedResults<Medication>) -> [Medication] {
        
        let todaysMedication = medication.filter {
            guard let start = $0.start else { return false }
            guard let days = $0.days as? [String] else { return false }
            guard !days.isEmpty else { return false }
            guard !days.dayOfWeekNumberArray.isEmpty else { return false }
            var offset = 0
            var dayComponent = DateComponents()
            switch chosenDay {
            case 0:
                offset = 0
            case 1:
                offset = 1
            case 2:
                offset = 2
            case 3:
                offset = 3
            case 4:
                offset = 4
            default:
                offset = 0
            }
            dayComponent.day = offset
            let calendar = Calendar.current
            let displayedDay =  calendar.date(byAdding: dayComponent, to: Date())!
            
            guard let displayedDayInt = displayedDay.dayNumberOfWeek() else { return false }
            guard start <= displayedDay else { return false }
            if days.dayOfWeekNumberArray.contains(displayedDayInt) {
                if $0.isEndAdded {
                    if let end = $0.end {
                        if displayedDay <= end {
                            return true
                        } else {
                            return false
                        }
                    }
                } else {
                    return true
                }
            }
            return false
        }
        return todaysMedication
    }
}
