//
//  PhotosView.swift
//  MedInteractions
//
//  Created by Joanna Staleńczyk on 22/01/2023.
//

import SwiftUI
import PhotosUI
import LocalAuthentication

struct PhotosView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.date, order: .reverse)
    ]) var photos: FetchedResults<Photo>
    @ObservedObject var viewModel: PhotosViewModel
    @State private var showFullScreenImage = false
    @State private var selectedImage: Data? = nil
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var isPresented = false
    @State private var title = ""
    @State private var searchText = ""
    
    @State private var isUnlocked = false
    
    let dateFormatter = DateFormatter()
    
    var searchResult: [Photo] {
        guard !photos.isEmpty else { return Array(photos) }
        if searchText.isEmpty {
            return Array(photos)
        } else {
            return photos.filter {
                $0.name?.lowercased()
                .contains(searchText.lowercased()) ?? false
            }
        }
    }
    
    init(viewModel: PhotosViewModel) {
        self.viewModel = viewModel
        dateFormatter.dateFormat = "MM/dd/yyyy"
    }
    
    var body: some View {
        VStack {
            if photos.isEmpty {
                EmptyPhotosView()
            } else if isUnlocked {
                NavigationView {
                    ZStack {
                        List {
                            ForEach(searchResult) { photo in
                                if let name = photo.name,
                                   let date = photo.date,
                                   let data = photo.data,
                                   let title = photo.name {
                                    NavigationLink {
                                        FullScreenImageView(title: title, data: data)
                                    } label: {
                                        HStack {
                                            if let uiImage = UIImage(data: data) {
                                                ZStack {
                                                    Rectangle()
                                                        .foregroundColor(Color.black)
                                                    Image(uiImage: uiImage)
                                                        .resizable()
                                                        .scaledToFit()
                                                }
                                                .frame(width: 80, height: 100)
                                                .cornerRadius(3)
                                                .padding(.trailing, 8)
                                            }
                                            VStack(alignment: .leading) {
                                                Text(name.capitalizingFirstLetter())
                                                    .font(.custom("OldStandardTT-Regular", size: 18))
                                                    .foregroundColor(.darkPurple)
                                                Text(dateFormatter.string(from: date))
                                                    .foregroundColor(.secondary)
                                                    .font(.custom("OldStandardTT-Regular", size: 14))
                                            }
                                            Spacer()
                                        }
                                        .padding([.top, .bottom], 4)
                                    }
                                }
                            }
                            .onDelete { offsets in
                                for index in offsets {
                                    let photo = photos[index]
                                    moc.delete(photo)
                                    try? moc.save()
                                }
                            }
                        }
                        
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
                            .padding(.trailing, 26)
                            .padding(.bottom, 36)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .bottomTrailing)
                        }
                    }
                    .sheet(isPresented: $isPresented) {
                        AddPhotoView()
                    }
                    .navigationTitle("Photos")
                    .navigationBarTitleDisplayMode(.inline)
                    .searchable(text: $searchText)
                }
            }  else {
                EmptyPhotosView()
                    .onAppear {
                        if !photos.isEmpty {
                            authenticate()
                        }
                    }
            }
        }
        .onAppear {
            isUnlocked = false
        }
    }
        
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics, error: &error
        ) {
            let reason = "We need to unlock your data."
            
            context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            ) { success, authenticationError in
                if success {
                    isUnlocked = true
                }
            }
        }
    }
}

struct EmptyPhotosView: View {
    @Environment(\.managedObjectContext) var moc
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var isPresented = false
    var body: some View {
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
                .padding(.trailing, 26)
            }
            HStack {
                Spacer()
                Image.Photos.photosArrow
                    .padding(.trailing, 56)
            }
            
            Text("Keep a list of all your perscriptions in one place")
                .frame(width: 200, height: 100)
                .multilineTextAlignment(.center)
                .padding(.bottom, 36)
                .font(.custom("OldStandardTT-Regular", size: 24))
            
            Image.Photos.photosEmptyView
            
            Spacer()
        }
        .sheet(isPresented: $isPresented) {
            AddPhotoView()
        }
    }
}

struct FullScreenImageView: View {
    @Environment(\.presentationMode) var presentationMode
    var title: String
    var data: Data
    var body: some View {
        VStack {
            if let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 0,
                        maxHeight: .infinity,
                        alignment: .center
                    )
            }
        }
    }
}

struct AddPhotoView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    @State private var selectedImage: Data? = nil
    @State private var selectedItem: PhotosPickerItem? = nil
    
    @State private var title = ""
    @State private var date = Date()
    @State private var data: Data? = nil
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Title", text: $title)
                    .padding(4)
                    .padding(.leading, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.darkPurple!, lineWidth: 1)
                    )
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .onTapGesture {
                        hideKeyboard()
                    }
                    .withClearButton($title)
                    .padding([.leading, .trailing], 16)
                    .padding([.top, .bottom], 36)
                
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()) {
                        Text("Add photo")
                            .foregroundColor(.white)
                            .padding([.leading, .trailing], 16)
                            .padding([.top, .bottom], 6)
                            .buttonBorderShape(.roundedRectangle)
                            .background(Color.buttonPurple)
                            .cornerRadius(16)
                    }
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                self.data = data
                                date = Date()
                                title = title
                                
                                selectedImage = data
                            }
                        }
                    }
                
                if let data = selectedImage {
                    if let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                    }
                }
                Spacer()
            }
            .navigationTitle(Text("Add Photo"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("OK") {
                        let photo = Photo(context: moc)
                        photo.data = data
                        photo.date = Date()
                        photo.name = title
                        try? moc.save()
                        dismiss()
                    }
                    .disabled(title.isEmpty || data == nil)
                }
            }
        }
    }
}

