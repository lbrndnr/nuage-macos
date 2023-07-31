//
//  Navigation.swift
//  Nuage
//
//  Created by Laurin Brandner on 28.07.23.
//

import SoundCloud

let separator = "@@NUAGE@@"

enum SidebarItem: RawRepresentable {
    case stream
    case likes
    case history
    case following
    case playlist(String, String)
    
    init?(rawValue: String) {
        switch rawValue {
        case "stream": self = .stream
        case "likes": self = .likes
        case "history": self = .history
        case "following": self = .following
        default:
            let components = rawValue.split(separator: separator)
            guard components.count == 2 else { return nil }
            
            self = .playlist(String(components[0]), String(components[1]))
        }
    }
    
    var rawValue: String {
        switch self {
        case .stream: return "stream"
        case .likes: return "likes"
        case .history: return "history"
        case .following: return "following"
        case .playlist(let name, let id): return name+separator+id
        }
    }
    
    var title: String {
        switch self {
        case .playlist(let name, _): return name
        default: return rawValue.capitalized
        }
    }
    
    var imageName: String? {
        switch self {
        case .stream: return "bolt.horizontal.fill"
        case .likes: return "heart.fill"
        case .history: return "clock.fill"
        case .following: return "person.2.fill"
        case .playlist(_, _): return nil
        }
    }
    
}

extension SidebarItem: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title.hashValue)
        if case .playlist(_, let id) = self {
            hasher.combine(id.hashValue)
        }
    }
    
}

extension SidebarItem: Identifiable {
    
    var id: String {
        if case .playlist(_, let id) = self {
            return id
        }
        return title
    }
    
}
