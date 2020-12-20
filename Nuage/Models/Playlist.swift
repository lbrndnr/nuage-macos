//
//  Playlist.swift
//  Nuage
//
//  Created by Laurin Brandner on 02.11.20.
//  Copyright © 2020 Laurin Brandner. All rights reserved.
//

import Foundation

enum Tracks {
    case id([Int])
    case full([Track])
}

struct Playlist: SoundCloudIdentifiable {
    
    var id: Int
    var title: String
    var description: String?
    var artworkURL: URL?
    var permalinkURL: URL
    var tracks: Tracks
    var isPublic: Bool
    var isAlbum: Bool
    
}

extension Playlist: Decodable {

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
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
        description = try container.decodeIfPresent(String.self, forKey: .description)
        artworkURL = try container.decodeIfPresent(URL.self, forKey: .artworkURL)
        permalinkURL = try container.decode(URL.self, forKey: .permalinkURL)
        isPublic = try container.decode(Bool.self, forKey: .isPublic)
        isAlbum = try container.decode(Bool.self, forKey: .isAlbum)
        
        if let tracks = try? container.decode([Track].self, forKey: .tracks) {
            self.tracks = .full(tracks)
        }
        else if let tracks = try container.decode([Any].self, forKey: .tracks) as? [[String : Any]] {
            let ids = tracks.map { $0["id"] as! Int }
            self.tracks = .id(ids)
        }
        else {
            self.tracks = .id([])
        }
    }
    
}

extension Playlist: Filterable {
    
    func contains(_ text: String) -> Bool {
        return title.contains(text)
    }
    
}
