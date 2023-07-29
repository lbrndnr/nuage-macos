//
//  Navigation.swift
//  Nuage
//
//  Created by Laurin Brandner on 28.07.23.
//

import SoundCloud

enum SidebarItem {
    case stream
    case likes
    case history
    case following
    case playlist(String, String)
    
    var title: String {
        switch self {
        case .stream: return "Stream"
        case .likes: return "Likes"
        case .history: return "History"
        case .following: return "Following"
        case let .playlist(name, _): return name
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
