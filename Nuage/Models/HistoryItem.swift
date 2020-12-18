//
//  HistoryItem.swift
//  Nuage
//
//  Created by Laurin Brandner on 10.11.20.
//  Copyright © 2020 Laurin Brandner. All rights reserved.
//

import Foundation

struct HistoryItem: SoundCloudIdentifiable {
    
    var id: Int {
        return track.id
    }
    
    var date: Date
    var track: Track
    
}

extension HistoryItem: Decodable {

    enum CodingKeys: String, CodingKey {
        case date = "played_at"
        case track
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let timestamp = try container.decode(Double.self, forKey: .date)
        date = Date(timeIntervalSince1970: timestamp)
        track = try container.decode(Track.self, forKey: .track)
    }
    
}
