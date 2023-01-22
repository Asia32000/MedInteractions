//
//  FirstPageView.swift
//  MedInteractions
//
//  Created by Joanna Staleńczyk on 22/01/2023.
//

import SwiftUI
import UserNotifications

struct FirstPageView: View {
    @AppStorage("date", store: .standard) var currentDate = "Date"
    @ObservedObject var viewModel: FirstPageViewModel
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name)
    ]) var medication: FetchedResults<Medication>
    let center = UNUserNotificationCenter.current()
    
    var body: some View {
        ZStack {
            Color.lightPurple
                .ignoresSafeArea()
            VStack {
                RectangleView(viewModel: viewModel)
                    .cornerRadius(36, corners: [.topLeft, .topRight])
                    .ignoresSafeArea(.all, edges: .bottom)
            }
        }
        .onAppear {
            if currentDate == Date().formattedDay {
                
            } else {
                currentDate = Date().formattedDay
                for med in medication {
                    if med.isEndAdded, let endDate = med.end, let identifiers = med.notificationIdentifiers as? [String] {
                        if endDate < Date() {
                            center.removePendingNotificationRequests(withIdentifiers: identifiers)
                        }
                    }
                }
            }
        }
    }
}

struct EmptyFirstPageView: View {
    @ObservedObject var viewModel: FirstPageViewModel
    @State private var isPresented = false
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(viewModel.todayDateToString())
                        .font(.custom("OldStandardTT-Regular", size: 18))
                        .padding(.leading, 16)
                }
                Spacer()
                Button {
                    isPresented = true
                } label: {
                    ZStack {
                        Circle()
                            .foregroundColor(.buttonPurple)
                            .frame(width: 46, height: 46)
                        
                        Image(systemName: "plus")
                            .foregroundColor(.lightPurple)
                            .font(.system(size: 36))
                            .fontWeight(.medium)
                    }
                }
            }
            .padding(.top, 16)
            .padding(.trailing, 36)
            VStack {
                HStack {
                    Spacer()
                    Image.FirstPage.firstPageArrow
                        .padding(.trailing, 48)
                }
                Text("Add reminders about your medication")
                    .frame(width: 250, height: 100)
                    .multilineTextAlignment(.center)
                    .font(.custom("OldStandardTT-Regular", size: 24))
                Image.FirstPage.firstPageEmptyView
                Spacer()
            }
        }
        .sheet(isPresented: $isPresented) {
            AddPillsView(viewModel: PillsViewModel())
        }
    }
}

struct CircularDaysView: View {
    @ObservedObject var viewModel: FirstPageViewModel
    let column = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var body: some View {
        LazyVGrid(columns: column) {
            ForEach(daysToString(), id: \.self) { day in
                
                Button {
                    viewModel.chosenDay = daysToString()
                        .firstIndex(of: day) ?? 0
                } label: {
                    Text(day)
                        .font(.custom("OldStandardTT-Regular", size: 32))
                        .foregroundColor(.black)
                        .background(
                            Circle()
                                .frame(width: daysToString()
                                    .firstIndex(of: day) == viewModel.chosenDay ?
                                       56 : 0, height: daysToString()
                                    .firstIndex(of: day) == viewModel.chosenDay ? 56 : 0)
                                .foregroundColor(.white)
                        )
                }
                .transaction { transaction in
                    transaction.animation = nil
                }
                
            }
        }
        .padding([.leading, .trailing], 16)
        .frame(maxWidth: .infinity)
        .background(Color.lightPurple)
    }
}
    
    func daysToString() -> [String] {
        var daysArray = [String]()
        for i in 0...4 {
            daysArray.append(dayToString(offset:i))
        }
        return daysArray
    }
    
    func dayToString(offset: Int) -> String {
        var dayComponent = DateComponents()
        dayComponent.day = offset
        let calendar = Calendar.current
        let nextDay =  calendar.date(byAdding: dayComponent, to: Date())!
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "d"
        return formatter.string(from: nextDay)
    }


struct RectangleView: View {
    @ObservedObject var viewModel: FirstPageViewModel
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name)
    ]) var medication: FetchedResults<Medication>
    @State private var isPresented = false
    @State private var showAnimation = true
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
            if viewModel.medicationRemindersToShow(medication: medication).isEmpty {
                EmptyFirstPageView(viewModel: viewModel)
            } else {
                ScrollView {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(viewModel.todayDateToString())
                                .font(.custom("OldStandardTT-Regular", size: 18))
                                .padding(.leading, 16)
                        }
                        Spacer()
                        Button {
                            isPresented = true
                        } label: {
                            ZStack {
                                Circle()
                                    .foregroundColor(.buttonPurple)
                                    .frame(width: 46, height: 46)
                                
                                Image(systemName: "plus")
                                    .foregroundColor(.lightPurple)
                                    .font(.system(size: 36))
                                    .fontWeight(.medium)
                            }
                        }
                    }
                    .padding(.top, 16)
                    .padding(.trailing, 36)
                    Spacer()
                    
                    TodaysMedicationView(viewModel: viewModel, medication: medication)
                }
            }
        }
        .sheet(isPresented: $isPresented) {
            AddPillsView(viewModel: PillsViewModel())
        }
    }
    
    func isDisplayedDayTodaysDay() -> Bool {
        if Calendar.current.dateComponents([.day, .month, .year], from: viewModel.displayedDay()) == Calendar.current.dateComponents([.day, .month, .year], from: Date()) {
            return true
        } else {
            return false
        }
    }
}

struct TodaysMedicationView: View {
    @AppStorage("date", store: .standard) var currentDate = "Date"
    let viewModel: FirstPageViewModel
    let medication: FetchedResults<Medication>
    @Environment(\.managedObjectContext) var moc
    @State private var showAnimation = true
    
    var body: some View {
            ForEach(viewModel.medicationRemindersToShow(medication: medication), id: \.self) { med in
                ForEach(0..<(med.doseTime?.count ?? 0), id: \.self) { number in
                    Button {
                        showAnimation = true
                    } label: {
                        HStack {
                            Image.FirstPage.pills
                            VStack(alignment: .leading) {
                                if let name = med.name {
                                    Text(name.capitalizingFirstLetter())
                                        .font(.custom("OldStandardTT-Regular", size: 18))
                                    Text("Single dose: \(med.dose ?? "")")
                                        .font(.custom("OldStandardTT-Regular", size: 16))
                                }
                            }
                            Spacer()
                            
                            HStack {
                                if let doseTimeArray = med.doseTime as? [Date], doseTimeArray.count >= number + 1 {
                                    Text(doseTimeArray[number].formattedTime)
                                        .font(.custom("OldStandardTT-Regular", size: 16))
                                }
                            }
                        }
                        
                        .foregroundColor(Color.black)
                        .padding(.trailing, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: .gray.opacity(0.35), radius: 2, x: 2, y: 2)
                        )
                        .padding(.bottom, 8)
                        .padding([.leading, .trailing], 16)
                    }
                    .disabled(!isDisplayedDayTodaysDay())
                }
            }
    }
    
    
    func isDisplayedDayTodaysDay() -> Bool {
        if Calendar.current.dateComponents([.day, .month, .year], from: viewModel.displayedDay()) == Calendar.current.dateComponents([.day, .month, .year], from: Date()) {
            return true
        } else {
            return false
        }
    }
}

struct TimeCheckmarkView: View {
    let med: Medication
    let number: Int
    let isDisplayedDayTodaysDay: Bool
    
    var body: some View {
        HStack {
            if let doseTimeArray = med.doseTime as? [Date] {
                if doseTimeArray.count >= number + 1 {
                    Text(doseTimeArray[number].formattedTime)
                        .font(.custom("OldStandardTT-Regular", size: 16))
                }
            }
        }
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}

extension [String] {
    var dayOfWeekNumberArray: [Int] {
        var daysIntArray = [Int]()
        for day in self {
            switch day {
            case "Monday":
                daysIntArray.append(2)
            case "Tuesday":
                daysIntArray.append(3)
            case "Wednesday":
                daysIntArray.append(4)
            case "Thursday":
                daysIntArray.append(5)
            case "Friday":
                daysIntArray.append(6)
            case "Saturday":
                daysIntArray.append(7)
            case "Sunday":
                daysIntArray.append(1)
            default:
                fatalError()
            }
        }
        return daysIntArray
    }
}

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

