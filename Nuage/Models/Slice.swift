//
//  Slice.swift
//  Nuage
//
//  Created by Laurin Brandner on 26.12.19.
//  Copyright © 2019 Laurin Brandner. All rights reserved.
//

import Foundation
import Combine

struct NoNextSliceError: Error { }

struct Slice<T: Decodable>: Decodable {
    
    var collection: [T]
    var next: URL?
    
    enum CodingKeys: String, CodingKey {
        case collection
        case next = "next_href"
    }
    
}
