//
//  ResultsList.swift
//  Music Reborn
//
//  Created by llsc12 on 28/03/2022.
//

import Foundation

struct Result: Identifiable {
    var id = UUID()
    var title: String
    var vidId: String
    var thumb: URL
}
