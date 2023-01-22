//
//  ContentView.swift
//  MedInteractions
//
//  Created by Joanna Staleńczyk on 22/01/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var selection = 0
    
    var body: some View {
        VStack {
            TabView(selection: $selection) {
                FirstPageView(viewModel: FirstPageViewModel())
                    .tabItem {
                        selection == 0 ? Image.TabBar.calendarSelected : Image.TabBar.calendar
                    }
                    .tag(0)
                PillsView()
                    .tabItem {
                        selection == 1 ? Image.TabBar.pillSelected : Image.TabBar.pill
                    }
                    .tag(1)
                PhotosView(viewModel: PhotosViewModel())
                    .tabItem {
                        selection == 2 ? Image.TabBar.imageSelected : Image.TabBar.image
                    }
                    .tag(2)
                InteractionsView(viewModel: InteractionsViewModel())
                    .tabItem {
                        selection == 3 ? Image.TabBar.interactionsSelected : Image.TabBar.interactions
                    }
                    .tag(3)
            }
        }
    }
}
