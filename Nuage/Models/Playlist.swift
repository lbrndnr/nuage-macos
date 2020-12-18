//
//  Playlist.swift
//  Nuage
//
//  Created by Laurin Brandner on 02.11.20.
//  Copyright © 2020 Laurin Brandner. All rights reserved.
//

import Foundation

struct Playlist: SoundCloudIdentifiable {
    
    var id: Int
    var title: String
    var artworkURL: URL?
    var permalinkURL: URL
    var trackIDs: [Int]?
    var isPublic: Bool
    var isAlbum: Bool
    
}

extension Playlist: Decodable {

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case artworkURL = "artwork_url"
        case permalinkURL = "permalink_url"
        case isPublic = "public"
        case tracks
        case isAlbum = "is_album"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        artworkURL = try container.decodeIfPresent(URL.self, forKey: .artworkURL)
        permalinkURL = try container.decode(URL.self, forKey: .permalinkURL)
        isPublic = try container.decode(Bool.self, forKey: .isPublic)
        isAlbum = try container.decode(Bool.self, forKey: .isAlbum)
        
        let tracks = try container.decodeIfPresent([Any].self, forKey: .tracks)
        if let tracks = tracks as? [[String : Any]] {
            trackIDs = tracks.map { $0["id"] as! Int }
        }
    }
    
}

extension Playlist: Filterable {
    
    func contains(_ text: String) -> Bool {
        return title.contains(text)
    }
    
}
