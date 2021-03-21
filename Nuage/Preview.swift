//
//  Preview.swift
//  Nuage
//
//  Created by Laurin Brandner on 23.12.19.
//  Copyright © 2019 Laurin Brandner. All rights reserved.
//

import Foundation
import Combine
import SoundCloud

let previewUser = User(id: "139004098", username: "lerboe", firstName: "la", lastName: "la", avatarURL: URL(string: "https://i1.sndcdn.com/avatars-000322614854-ttkl8d-large.jpg")!)

#if DEBUG
let previewLikes: [Like<Track>] = load("Likes.json")
let previewLikePublisher = publisher(of: previewLikes)

let previewTracks: [Track] = previewLikes.map { $0.item }
let previewTrackPublisher = publisher(of: previewTracks)

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    
    do {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}

struct PreviewError: Error {}

func publisher<T>(of data: [T]) -> AnyPublisher<T, Error> {
    return data.publisher
        .mapError { _ in PreviewError() }
        .eraseToAnyPublisher()
}

#endif
