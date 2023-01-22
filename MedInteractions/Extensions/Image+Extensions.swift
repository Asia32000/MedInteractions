//
//  Image+Extensions.swift
//  MedInteractions
//
//  Created by Joanna Staleńczyk on 22/01/2023.
//

import Foundation
import SwiftUI

extension Image {
    enum TabBar {
        static let calendar = Image("Calendar")
        static let image = Image("Image")
        static let pill = Image("Pill")
        static let interactions = Image("Interactions")
        static let calendarSelected = Image("CalendarSelected")
        static let imageSelected = Image("ImageSelected")
        static let pillSelected = Image("PillSelected")
        static let interactionsSelected = Image("InteractionsSelected")
    }
    
    enum Interactions {
        static let interactionsChecker = Image("interactionsChecker")
        static let pill = Image("onePill")
        static let pills = Image("twoPills")
        static let drink = Image("interactionsDrink")
    }
    
    enum FirstPage {
        static let firstPageEmptyView = Image("biggerFirstPageGroup")
        static let firstPageArrow = Image("firstPageSmallerArrow")
        static let circle = Image("circle")
        static let checkCircle = Image("checkCircle")
        static let pills = Image("firstPagePills")
        static let appointments = Image("firstPageAppointment")
    }
    
    enum Pills {
        static let pillsEmptyView = Image("PillsEmptyView")
        static let pillsArrow = Image("PillsArrow")
        static let pillsEmptyViewAccessory = Image("PillsEmptyViewAccessory")
        static let medication = Image("pillsMedication")
        static let pills = Image("pillsPills")
        static let bandAid = Image("pillsBandAid")
        static let serumBag = Image("pillsSerumBag")
        static let vaccine = Image("pillsVaccine")
    }
    
    enum Photos {
        static let photosEmptyView = Image("PhotosEmptyView")
        static let photosArrow = Image("PhotosArrow")
    }
}

