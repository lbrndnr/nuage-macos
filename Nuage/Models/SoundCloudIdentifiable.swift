//
//  SoundCloudIdentifiable.swift
//  Nuage
//
//  Created by Laurin Brandner on 02.11.20.
//  Copyright © 2020 Laurin Brandner. All rights reserved.
//

import Foundation

protocol SoundCloudIdentifiable: Identifiable, Hashable {
    
    var id: Int { get }
    
}

extension SoundCloudIdentifiable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
}

protocol Filterable {
    
    func contains(_ text: String) -> Bool
    
}
