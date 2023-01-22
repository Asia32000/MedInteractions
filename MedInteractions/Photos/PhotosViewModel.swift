//
//  PhotosViewModel.swift
//  MedInteractions
//
//  Created by Joanna Staleńczyk on 22/01/2023.
//

import Foundation
import SwiftUI
import UIKit

class PhotosViewModel: ObservableObject {
    @Published var images: [UIImage]
    
    init() {
        images = [UIImage]()
    }
}
