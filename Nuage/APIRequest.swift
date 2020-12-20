//
//  APIRequest.swift
//  Nuage
//
//  Created by Laurin Brandner on 18.11.20.
//  Copyright © 2020 Laurin Brandner. All rights reserved.
//

import Foundation

struct APIRequest<T: Decodable> {
    
    enum API {
        case me
        case albumsAndPlaylists
        case stream
        case whoToFollow
        case history
        
        case tracks([Int])
        case trackLikes(Int)
        case likeTrack(Int)
        case unlikeTrack(Int)
        
        case playlist(Int)
    //    case playlistLikes(Int)
    //    case likePlaylist(Int, Int)
    //    case unlikePlaylist(Int, Int)
        case addToPlaylist(Int, [Int])
    }
    
    var url: API
    
    static func me() -> APIRequest<User> {
        return APIRequest<User>(url: .me)
    }
    
    static func albumsAndPlaylists() -> APIRequest<Slice<Like<Playlist>>> {
        return APIRequest<Slice<Like<Playlist>>>(url: .albumsAndPlaylists)
    }
    
    static func stream() -> APIRequest<Slice<Post>> {
        return APIRequest<Slice<Post>>(url: .stream)
    }
    
    static func whoToFollow() -> APIRequest<Slice<Recommendation>> {
        return APIRequest<Slice<Recommendation>>(url: .whoToFollow)
    }
    
    static func history() -> APIRequest<Slice<HistoryItem>> {
        return APIRequest<Slice<HistoryItem>>(url: .history)
    }
    
    static func tracks(_ ids: [Int]) -> APIRequest<[Track]> {
        return APIRequest<[Track]>(url: .tracks(ids))
    }
    
    static func trackLikes(of user: User) -> APIRequest<Slice<Like<Track>>> {
        return APIRequest<Slice<Like<Track>>>(url: .trackLikes(user.id))
    }
    
    static func like(_ track: Track) -> APIRequest<String> {
        return APIRequest<String>(url: .likeTrack(track.id))
    }
    
    static func unlike(_ track: Track) -> APIRequest<String> {
        return APIRequest<String>(url: .unlikeTrack(track.id))
    }
    
    static func playlist(_ id: Int) -> APIRequest<Playlist> {
        return APIRequest<Playlist>(url: .playlist(id))
    }
    
    static func add(to playlist: Playlist, trackIDs: [Int]) -> APIRequest<Playlist> {
        return APIRequest<Playlist>(url: .addToPlaylist(playlist.id, trackIDs))
    }
    
    var path: String {
        switch url {
        case .me: return "me"
        case .albumsAndPlaylists: return "me/library/albums_playlists_and_system_playlists"
        case .stream: return "stream"
        case .whoToFollow: return "me/suggested/users/who_to_follow"
        case .history: return "me/play-history/tracks"
        
        case .tracks(_): return "tracks"
        case .trackLikes(let id): return "users/\(id)/track_likes"
        case .likeTrack(let trackID): fallthrough
        case .unlikeTrack(let trackID): return "users/\(SoundCloud.shared.user?.id ?? 0)/track_likes/\(trackID)"
            
        case .playlist(let id): return "playlists/\(id)"
        case .addToPlaylist(let id, _): return "playlists/\(id)"
        }
    }
    
    var queryParameters: [String: String]? {
        switch url {
        case .tracks(let ids): return ["ids": ids.map { String($0) }.joined(separator: ",")]
        default: return nil
        }
    }
    
    var httpMethod: String {
        switch url {
        case .likeTrack(_): return "PUT"
        case .unlikeTrack(_): return "DELETE"
        case .addToPlaylist(_, _): return "PUT"
        default: return "GET"
        }
    }
    
    var body: Data? {
        switch url {
        case .addToPlaylist(_, let trackIDs):
            let tracks = ["tracks": trackIDs]
            let payload = ["playlist": tracks]
            do {
                return try JSONSerialization.data(withJSONObject: payload, options: .fragmentsAllowed)
            }
            catch {
                return nil
            }
        default: return nil
        }
    }
    
    var needsUserID: Bool {
        switch url {
        case .likeTrack(_): fallthrough
        case .unlikeTrack(_): return true
        default: return false
        }
    }
    
}

