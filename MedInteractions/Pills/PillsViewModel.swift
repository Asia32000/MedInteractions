//
//  PillsViewModel.swift
//  MedInteractions
//
//  Created by Joanna Staleńczyk on 22/01/2023.
//

import Foundation
import SwiftUI

class PillsViewModel: ObservableObject {
    @Published var center = UNUserNotificationCenter.current()
    @ObservedObject var findRxcuiService = FindRxcuiService()
    
    func validateInput(name: String, dose: String, refillReminder: Bool,
                       pillsInStock: String, pillsLeft: String) -> Bool {
        guard !name.isEmpty, !dose.isEmpty else { return false }
        if refillReminder && (pillsInStock.isEmpty || pillsLeft.isEmpty) {
            return false
        }
        return true
    }
    
    func setCheckmark(day: String) {
        if selectedDays.contains(day) {
            if let index = selectedDays.firstIndex(of: day) {
                selectedDays.remove(at: index)
            }
        } else {
            selectedDays.append(day)
        }
    }
    
    func setCheckmarkEditView(day: String, days: inout [String]) {
        if days.contains(day) {
            if let index = days.firstIndex(of: day) {
                days.remove(at: index)
            }
        } else {
            days.append(day)
        }
    }
    
    func whichDaysTitle() -> String {
        if selectedDays.isEmpty || selectedDays.count == 7 {
            return "Everyday"
        } else if selectedDays.count <= 3 {
            return selectedDays.joined(separator: ",")
        } else {
            return selectedDays.joined(separator: ", \n")
        }
    }
    
    func whichDaysEditViewTitle(days: [String]) -> String {
        if days.isEmpty {
            return ""
        } else if days.count == 7 {
            return "Everyday"
        } else if days.count <= 3 {
            return days.joined(separator: ",")
        } else {
            return days.joined(separator: ", \n")
        }
    }
    
    @Published var medicationName = ""
    @Published var icons = ["pillsMedication", "pillsPills", "pillsBandAid", "pillsSerumBag", "pillsVaccine"]
    @Published var frequency = Array(1...7)
    @Published var days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    @Published var selectedDays = [String]()
    @Published var date = Date()
    @Published var startDate = Date()
    @Published var endDate = Date()
    @Published var dates = [Date()]
    @Published var refillReminder = false
    @Published var notifications = false
    @Published var pillsInStock = ""
    @Published var pillsLeft = ""
    @Published var isEndAdded = false
    @Published var rxcui = ""
    @Published var editRxcui = ""
    
    func validateEditingInput(name: String, dose: String, refillReminder: Bool, pillsInStock: String, pillsLeft: String) -> Bool {
        guard !name.isEmpty, !dose.isEmpty else { return false }
        if refillReminder && (pillsInStock.isEmpty || pillsLeft.isEmpty) {
            return false
        }
        return true
    }
    
    func getRxcui() {
        Task {
            await findRxcuiService.findRxcui(medication: medicationName) { rxcui in
                if let stringRxcui = rxcui {
                    self.rxcui = stringRxcui
                }
            }
        }
    }
    
    func getRxcui(name: String) {
        Task {
            await findRxcuiService.findRxcui(medication: name) { rxcui in
                if let stringRxcui = rxcui {
                    self.editRxcui = stringRxcui
                }
            }
        }
    }
}
