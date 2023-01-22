//
//  PillsView.swift
//  MedInteractions
//
//  Created by Joanna Staleńczyk on 22/01/2023.
//

import SwiftUI
import UserNotifications

struct PillsView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name)
    ]) var medication: FetchedResults<Medication>
    @State private var chosenPage = 0
    var body: some View {
        VStack {
            Picker("Medications or Interactions", selection: $chosenPage) {
                Text("Medication").tag(0)
                Text("Interactions").tag(1)
            }
            .colorMultiply(.segmentColor ?? .white)
            .pickerStyle(.segmented)
            
            if chosenPage == 0 {
                if medication.isEmpty {
                    PillsEmptyView()
                } else {
                    NotEmptyPillsView()
                }
            } else {
                PillsInteractionsView(viewModel: PillsInteractionsViewModel())
            }
        }
        .onAppear {
            chosenPage = 0
        }
    }
}

struct PillsEmptyView: View {
    @State private var isPresented = false
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    
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
                .padding(.trailing, 36)
                .padding(.top, 16)
                
                HStack {
                    Image.Pills.pillsEmptyViewAccessory
                        .padding(.leading, 56)
                    Spacer()
                    Image.Pills.pillsArrow
                        .padding(.trailing, 36)
                }
                
                Text("Add your medications and check for interactions")
                    .frame(width: 250, height: 100)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 36)
                    .font(.custom("OldStandardTT-Regular", size: 24))
                
                Image.Pills.pillsEmptyView
                
                Spacer()
            }
            .sheet(isPresented: $isPresented) {
                AddPillsView(viewModel: PillsViewModel())
            }
        }
    }
}

struct NotEmptyPillsView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name)
    ]) var medication: FetchedResults<Medication>
    @State private var isPresented = false
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(medication) { med in
                        if let id = med.id, let icon = med.icon, let name = med.name, let dose = med.dose, let frequency = med.frequency, let doseTime = med.doseTime as? [Date], let days = med.days as? [String] ?? [], let end = med.end, let start = med.start, let pillsInStock = med.pillsInStock, let refillReminder = med.refillReminder, let reminder = med.reminder, let notifications = med.notifications, let isEndAdded = med.isEndAdded, let identifiers = med.notificationIdentifiers as? [String] {
                            NavigationLink {
                                EditPillsView(viewModel: PillsViewModel(), id: id, name: name, dose: dose, frequency: Int(frequency), doseTime: doseTime, days: days, end: end, start: start, pillsInStock: pillsInStock, refillReminder: refillReminder, reminder: String(reminder), notifications: notifications, icon: icon, isEndAdded: isEndAdded, identifiers: identifiers, medication: med)
                            } label: {
                                SinglePillView(name: name, dose: dose, frequency: Int(frequency), doseTime: doseTime, days: days, end: end, start: start, pillsInStock: pillsInStock, refillReminder: refillReminder, reminder: Int(reminder), notifications: notifications, icon: icon, isEndAdded: isEndAdded)
                            }
                        }
                    }
                    .onDelete { offsets in
                        deleteMedication(offsets: offsets)
                    }
                }
                HStack(alignment: .top) {
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
                    .padding(.bottom, 36)
                }
                .padding(.trailing, 26)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .bottom)
            }
            .sheet(isPresented: $isPresented) {
                AddPillsView(viewModel: PillsViewModel())
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func deleteMedication(offsets: IndexSet) {
        for index in offsets {
            let medToDelete = medication[index]
            moc.delete(medToDelete)
            if let identifier = medToDelete.notificationIdentifiers as? [String] {
                UNUserNotificationCenter.current()
                    .removePendingNotificationRequests(withIdentifiers: identifier)
            }
            try? moc.save()
        }
    }
}


struct SinglePillView: View {
    let name: String
    let dose: String
    let frequency: Int
    let doseTime: [Date]
    let days: [String]
    let end: Date
    let start: Date
    let pillsInStock: String
    let refillReminder: Bool
    let reminder: Int
    let notifications: Bool
    let icon: String
    let isEndAdded: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(icon)
                    .resizable()
                    .frame(width: 36, height: 36)
                VStack(alignment: .leading) {
                    Text(name.capitalizingFirstLetter())
                        .font(.custom("OldStandardTT-Regular", size: 18))
                }
            }
            VStack(alignment: .leading) {
                Text("Single dose: \(dose)")
                Text("How many times a day: \(frequency)")
                Text("Which days: \(daysToString())")
                Text("Begnning of treatment: \(start.formattedDate)")
                if isEndAdded {
                    Text("End of treatment: \(end.formattedDate)")
                }
                if refillReminder {
                    Text("Pills in stock: \(pillsInStock)")
                    Text("Reminder at: \(reminder) left")
                }
                Text("Notifications: \(notifications ? "ON" : "OFF")")
            }
            .font(.custom("OldStandardTT-Regular", size: 16))
        }
    }
    
    func daysToString() -> String {
        if days.count == 7 { return "Everyday" }
        return days.joined(separator: ", ")
    }
}

struct EditPillsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var viewModel: PillsViewModel
    @State var id: UUID
    @State var name: String {
        didSet {
            viewModel.getRxcui(name: name)
        }
    }
    @State var dose: String
    @State var frequency: Int
    @State var doseTime: [Date]
    @State var days: [String]
    @State var end: Date
    @State var start: Date
    @State var pillsInStock: String
    @State var refillReminder: Bool
    @State var reminder: String
    @State var notifications: Bool
    @State var icon: String
    @State var isEndAdded: Bool
    @State var identifiers: [String]
    
    @State private var progressArray = [Bool]()
    
    let medication: Medication?
    
    var body: some View {
        ScrollView {
            VStack {
                Picker("Choose icon", selection: $icon) {
                    ForEach(viewModel.icons, id: \.self) { icon in
                        Image(icon)
                            .resizable()
                            .frame(width: 100, height: 100)
                    }
                }
                Group {
                    TextField("Medication name", text: $name)
                        .withClearButton($name)
                    TextField("Single dose", text: $dose)
                        .withClearButton($dose)
                        .keyboardType(.numberPad)
                }
                .padding(.leading, 6)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.darkPurple!, lineWidth: 1)
                )
                Group {
                    HStack {
                        Text("How many times a day?")
                        Spacer()
                        Picker("How many times a day?", selection: $frequency) {
                            ForEach(viewModel.frequency, id: \.self) { frequency in
                                Text("\(frequency)")
                            }
                        }
                        .onChange(of: frequency) { newFrequency in
                            newDateTimes(frequency: newFrequency)
                        }
                    }
                    .padding(.leading, 6)
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.darkPurple!, lineWidth: 1)
                    )
                    ForEach(0..<frequency, id: \.self) { number in
                        HStack {
                            if number < doseTime.count {
                                DatePicker("Dose \(number + 1)", selection: $doseTime[number], displayedComponents: .hourAndMinute)
                            }
                        }
                        .padding(.leading, 6)
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.darkPurple!, lineWidth: 1)
                        )
                    }
                    HStack {
                        Text("Which days?")
                        Spacer()
                        NavigationLink(destination: WhichDaysEditView(viewModel: viewModel, days: $days)) {
                            VStack(alignment: .trailing) {
                                Text(viewModel.whichDaysEditViewTitle(days: days))
                            }
                            .foregroundColor(.gray)
                            .padding(.trailing, 6)
                        }
                    }
                    .padding(.leading, 6)
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.darkPurple!, lineWidth: 1)
                    )
                }
                HStack {
                    Text(isEndAdded ? "Delete end of treatment" : "Add end of treatment")
                    Spacer()
                    Button {
                        isEndAdded.toggle()
                    } label: {
                        Image(systemName: isEndAdded ? "minus.circle" : "plus.circle")
                    }
                }
                .foregroundColor(.darkPurple)
                Group {
                    DatePicker("Start", selection: $start, displayedComponents: .date)
                    if isEndAdded {
                        DatePicker("End", selection: $end, displayedComponents: .date)
                    }
                }
                .padding(.leading, 6)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.darkPurple!, lineWidth: 1)
                )
                Toggle("Refill reminder", isOn: $refillReminder)
                if refillReminder {
                    Group {
                        TextField("Pills in stock", text: $pillsInStock)
                            .withClearButton($pillsInStock)
                            .keyboardType(.numberPad)
                        TextField("Reminder on how many pills left", text: $reminder)
                            .withClearButton($reminder)
                            .keyboardType(.numberPad)
                    }
                    .padding(.leading, 6)
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.darkPurple!, lineWidth: 1)
                    )
                }
                Toggle("Turn on notifications", isOn: $notifications)
                
                Button {
                    savePillChanges()
                } label: {
                    Text("Save")
                        .foregroundColor(.white)
                        .padding([.leading, .trailing], 16)
                        .padding([.top, .bottom], 6)
                        .buttonBorderShape(.roundedRectangle)
                        .background(Color.buttonPurple)
                        .cornerRadius(16)
                }
                .disabled(!viewModel.validateEditingInput(name: name, dose: dose, refillReminder: refillReminder, pillsInStock: pillsInStock, pillsLeft: reminder))
                .padding(.top, 16)
                .onAppear {
                    viewModel.getRxcui(name: name)
                    newDateTimes(frequency: frequency)
                }
            }
            .padding()
            .disableAutocorrection(true)
            .autocapitalization(.none)
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
    
    func newDateTimes(frequency: Int) {
        progressArray = []
        for _ in 0..<frequency {
            progressArray.append(false)
        }
        
        if frequency == doseTime.count {
            
        } else if frequency > doseTime.count {
            let difference = frequency - doseTime.count
            for _ in 0..<difference {
                doseTime.append(Date())
            }
        } else {
            let difference = doseTime.count - frequency
            for _ in 0..<difference {
                doseTime.removeLast()
            }
        }
    }
    
    func savePillChanges() {
        if let medication = medication {
            moc.delete(medication)
            viewModel.center.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
        
        if notifications {
            if isEndAdded && end >= Date() {
                viewModel.center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        print("success")
                        for i in 0..<frequency {
                            setNotification(i: i)
                        }
                        createUpdatedNotification()
                    }  else if let error = error {
                        print(error.localizedDescription)
                    }
                }
            } else if !isEndAdded {
                viewModel.center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        print("success")
                        for i in 0..<frequency {
                            setNotification(i: i)
                        }
                    }  else if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
        } else {
            createUpdatedNotification()
        }
    }
    
    func setNotification(i: Int) {
        for day in days {
            let content = UNMutableNotificationContent()
            content.title = "It's time to take your medication."
            content.body = "Take your \(doseTime[i].formattedTime) med."
            var dateComponents = DateComponents()
            dateComponents.calendar = Calendar.current
            dateComponents.weekday = day.dayOfWeekNumber
            dateComponents.hour = Calendar.current.dateComponents([.hour], from: doseTime[i]).hour
            dateComponents.minute = Calendar.current.dateComponents([.minute], from: doseTime[i]).minute
               
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let identifier = UUID().uuidString
            self.identifiers.append(identifier)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            viewModel.center.add(request)
        }
    }
    
    func createUpdatedNotification() {
        let updatedMedication = Medication(context: moc)
        updatedMedication.id = UUID()
        updatedMedication.name = name
        updatedMedication.dose = dose
        updatedMedication.frequency = Int16(frequency)
        updatedMedication.doseTime = doseTime as NSArray
        updatedMedication.days = days as NSArray
        updatedMedication.end = end
        updatedMedication.start = start
        updatedMedication.pillsInStock = pillsInStock
        updatedMedication.refillReminder = refillReminder
        updatedMedication.reminder = Int16(reminder) ?? 0
        updatedMedication.notifications = notifications
        updatedMedication.icon = icon
        updatedMedication.isEndAdded = isEndAdded
        updatedMedication.rxcui = viewModel.editRxcui
        updatedMedication.notificationIdentifiers = identifiers as NSArray

        try? moc.save()
        
        dismiss()
    }
}

struct AddPillsView: View {
    @ObservedObject var viewModel: PillsViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    @State private var selectedIcon = "pillsMedication"
    @State private var dose = ""
    @State private var selectedFrequency = 1
    @State private var identifires = [String]()
    @State private var progressArray: [Bool] = [false]
    @FocusState private var isNameFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Picker("Choose icon", selection: $selectedIcon) {
                        ForEach(viewModel.icons, id: \.self) { icon in
                            Image(icon)
                                .resizable()
                                .frame(width: 100, height: 100)
                        }
                    }
                    Group {
                        TextField("Medication name", text: $viewModel.medicationName)
                            .withClearButton($viewModel.medicationName)
                            .focused($isNameFieldFocused)
                        TextField("Single dose", text: $dose)
                            .withClearButton($dose)
                            .keyboardType(.numberPad)
                    }
                    .padding(.leading, 6)
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.darkPurple!, lineWidth: 1)
                    )
                    .onChange(of: isNameFieldFocused) { newValue in
                        if !newValue {
                            viewModel.getRxcui()
                        }
                    }
                    HStack {
                        Text("How many times a day?")
                        Spacer()
                        Picker("How many times a day?", selection: $selectedFrequency.onChange(addDates)) {
                            ForEach(viewModel.frequency, id: \.self) { frequency in
                                Text("\(frequency)")
                            }
                        }
                    }
                    .padding(.leading, 6)
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.darkPurple!, lineWidth: 1)
                    )
                    ForEach(0..<viewModel.dates.count, id: \.self) { number in
                        HStack {
                            DatePicker("Dose \(number + 1)", selection: $viewModel.dates[number], displayedComponents: .hourAndMinute)
                        }
                        .padding(.leading, 6)
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.darkPurple!, lineWidth: 1)
                        )
                    }
                    HStack {
                        Text("Which days?")
                        Spacer()
                        NavigationLink(destination: WhichDaysView(viewModel: viewModel)) {
                            VStack(alignment: .trailing) {
                                Text(viewModel.whichDaysTitle())
                            }
                            .foregroundColor(.gray)
                            .padding(.trailing, 6)
                        }
                    }
                    .padding(.leading, 6)
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.darkPurple!, lineWidth: 1)
                    )
                    HStack {
                        Text(viewModel.isEndAdded ? "Delete end of treatment" : "Add end of treatment")
                        Spacer()
                        Button {
                            viewModel.isEndAdded.toggle()
                        } label: {
                            Image(systemName: viewModel.isEndAdded ? "minus.circle" : "plus.circle")
                        }
                    }
                    .foregroundColor(.darkPurple)
                    Group {
                        DatePicker("Start of treatment", selection: $viewModel.startDate, displayedComponents: .date)
                        if viewModel.isEndAdded {
                            DatePicker("End of treatment", selection: $viewModel.endDate, displayedComponents: .date)
                        }
                    }
                    .padding(.leading, 6)
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.darkPurple!, lineWidth: 1)
                    )
                    Toggle("Turn on notifications", isOn: $viewModel.notifications)
                }
                .padding()
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .onTapGesture {
                    hideKeyboard()
                }
            }
            .navigationTitle(Text("Add Medication"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("OK") {
                        if viewModel.notifications {
                            if viewModel.isEndAdded && viewModel.endDate >= Date() {
                                viewModel.center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                                    if success {
                                        print("success")
                                        for i in 0..<selectedFrequency {
                                            setNotification(i: i)
                                        }
                                        createNewMedication()
                                    }  else if let error = error {
                                        print(error.localizedDescription)
                                    }
                                }
                            } else if !viewModel.isEndAdded {
                                viewModel.center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                                    if success {
                                        print("success")
                                        for i in 0..<selectedFrequency {
                                            setNotification(i: i)
                                        }
                                        createNewMedication()
                                    }  else if let error = error {
                                        print(error.localizedDescription)
                                    }
                                }
                            }
                        } else {
                            createNewMedication()
                        }
                    }
                    .disabled(!viewModel.validateInput(name: viewModel.medicationName, dose: dose, refillReminder: viewModel.refillReminder, pillsInStock: viewModel.pillsInStock, pillsLeft: viewModel.pillsLeft))
                }
            }
        }
    }
    
    func addDates(newValue: Int) {
        viewModel.dates = []
        var newBoolArray: [Bool] = []
        for _ in 0..<newValue {
            viewModel.dates.append(Date())
            let newBool: Bool = false
            newBoolArray.append(newBool)
        }
        progressArray = newBoolArray
    }
    
    func createNewMedication() {
        let medication = Medication(context: moc)
        medication.id = UUID()
        medication.name = viewModel.medicationName
        medication.dose = dose
        medication.frequency = Int16(selectedFrequency)
        medication.doseTime = viewModel.dates as NSArray
        medication.days = viewModel.selectedDays.isEmpty ? viewModel.days as NSArray : viewModel.selectedDays as NSArray
        medication.end = viewModel.endDate
        medication.start = viewModel.startDate
        medication.pillsInStock = viewModel.pillsInStock
        medication.refillReminder = viewModel.refillReminder
        medication.reminder = Int16(viewModel.pillsLeft) ?? 0
        medication.notifications = viewModel.notifications
        medication.icon = selectedIcon
        medication.isEndAdded = viewModel.isEndAdded
        medication.rxcui = viewModel.rxcui
        medication.notificationIdentifiers = identifires as NSArray
        
        try? moc.save()
        
        dismiss()
    }
    
    func setNotification(i: Int) {
        for day in returnNotEmptyDays() {
            let content = UNMutableNotificationContent()
            content.title = "It's time to take your medication."
            content.body = "Take your \(viewModel.dates[i].formattedTime) med."
            var dateComponents = DateComponents()
            dateComponents.calendar = Calendar.current
            dateComponents.weekday = day.dayOfWeekNumber
            dateComponents.hour = Calendar.current.dateComponents([.hour], from: viewModel.dates[i]).hour
            dateComponents.minute = Calendar.current.dateComponents([.minute], from: viewModel.dates[i]).minute
               
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let identifier = UUID().uuidString
            self.identifires.append(identifier)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            viewModel.center.add(request)
        }
    }
    
    func returnNotEmptyDays() -> [String] {
        guard !viewModel.selectedDays.isEmpty else { return viewModel.days }
        return viewModel.selectedDays
    }
}

struct WhichDaysView: View {
    @ObservedObject var viewModel: PillsViewModel
    var body: some View {
        Form {
            List {
                ForEach(viewModel.days, id: \.self) { day in
                    HStack {
                        Text(day)
                        Spacer()
                        if viewModel.selectedDays.contains(day) {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color.darkPurple)
                        }
                    }
                    .contentShape(Rectangle())
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        viewModel.setCheckmark(day: day)
                    }
                }
            }
        }
    }
}

struct WhichDaysEditView: View {
    @ObservedObject var viewModel: PillsViewModel
    @Binding var days: [String]
    var body: some View {
        Form {
            List {
                ForEach(viewModel.days, id: \.self) { day in
                    HStack {
                        Text(day)
                        Spacer()
                        if days.contains(day) {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color.darkPurple)
                        }
                    }
                    .contentShape(Rectangle())
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        viewModel.setCheckmarkEditView(day: day, days: &days)
                    }
                }
            }
        }
    }
}

private extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}

private extension String {
    var dayOfWeekNumber: Int {
        switch self {
        case "Monday":
            return 2
        case "Tuesday":
            return 3
        case "Wednesday":
            return 4
        case "Thursday":
            return 5
        case "Friday":
            return 6
        case "Saturday":
            return 7
        case "Sunday":
            return 1
        default:
            fatalError()
        }
    }
}

