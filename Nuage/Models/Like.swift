//
//  Like.swift
//  Nuage
//
//  Created by Laurin Brandner on 25.12.19.
//  Copyright © 2019 Laurin Brandner. All rights reserved.
//

import Foundation

struct Like<T: SoundCloudIdentifiable & Decodable>: SoundCloudIdentifiable {
    
    var id: Int {
        return item.id
    }
    
    var date: Date
    var item: T
    
}

extension Like: Decodable {

    enum CodingKeys: String, CodingKey {
        case date = "created_at"
        case track
        case playlist
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        date = try container.decode(Date.self, forKey: .date)
        let track = try container.decodeIfPresent(T.self, forKey: .track)
        let playlist = try container.decodeIfPresent(T.self, forKey: .playlist)
        item = (track ?? playlist)!
    }
    
}
