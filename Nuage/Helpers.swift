//
//  Helpers.swift
//  Nuage
//
//  Created by Laurin Brandner on 22.12.19.
//  Copyright © 2019 Laurin Brandner. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import URLImage
import SoundCloud

private var durationFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .positional
    formatter.allowedUnits = [.hour, .minute, .second]
    formatter.zeroFormattingBehavior = .pad
    
    return formatter
}()

func format<Time: BinaryFloatingPoint>(time: Time) -> String {
    return durationFormatter.string(from: TimeInterval(time)) ?? "00:00:00"
//    guard var text = durationFormatter.string(from: TimeInterval(time)) else {
//        return "00:00"
//    }
//    
//    let idx = text.index(text.startIndex, offsetBy: 3)
//    if text.prefix(upTo: idx) == "00:" {
//        text = String(text.suffix(from: idx))
//    }
//    
//    return text
}

extension AnyCancellable {
    
    func store<T: Hashable>(in dictionary: inout Dictionary<T, AnyCancellable>, key: T) {
        dictionary[key] = self
    }
    
}

protocol Filterable {
    
    func contains(_ text: String) -> Bool
    
}

extension User: Filterable {
    
    func contains(_ text: String) -> Bool {
        return username.containsCaseInsensitive(text) || name.containsCaseInsensitive(text)
    }
    
}

extension Track: Filterable {
    
    func contains(_ text: String) -> Bool {
        return title.containsCaseInsensitive(text) || (description?.containsCaseInsensitive(text) ?? false)
    }
    
}

extension Post: Filterable {
    
    func contains(_ text: String) -> Bool {
        return user.contains(text) || tracks.contains { $0.contains(text) }
    }
    
}

extension Playlist: Filterable {
    
    func contains(_ text: String) -> Bool {
        let contained = title.containsCaseInsensitive(text) || (description?.containsCaseInsensitive(text) ?? false)
        if let tracks = tracks {
            return contained || tracks.contains { $0.contains(text) }
        }
        return contained
        
    }
}

extension Like: Filterable where T: Filterable {
    
    func contains(_ text: String) -> Bool {
        return item.contains(text)
    }
    
}

extension Some: Filterable {
    
    func contains(_ text: String) -> Bool {
        switch self {
        case .track(let track): return track.contains(text)
        case .userPlaylist(let playlist): return playlist.contains(text)
        case .systemPlaylist(let playlist): return playlist.contains(text)
        case .user(let user): return user.contains(text)
        }
    }
    
}

extension Comment: Filterable {
    
    func contains(_ text: String) -> Bool {
        return body.contains(text) || user.contains(text)
    }
    
}

extension HistoryItem: Filterable {
    
    func contains(_ text: String) -> Bool {
        return track.contains(text)
    }
    
}

extension Recommendation: Filterable {
    
    func contains(_ text: String) -> Bool {
        return user.contains(text)
    }
    
}

extension String {
    
    fileprivate func containsCaseInsensitive(_ text: String) -> Bool {
        return range(of: text, options: .caseInsensitive) != nil
    }
    
}

protocol DateComparable: Comparable {
    
    var date: Date { get }
    
}

extension DateComparable {
    
    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.date < rhs.date
    }
    
}

extension HistoryItem: DateComparable {}
extension Post: DateComparable {}
extension Track: DateComparable {}
extension UserPlaylist: DateComparable {}

extension User {
    
    var displayName: String {
        if name.count > 0 { return name }
        return username
    }
    
}

@ViewBuilder func RemoteImage(url: URL?, cornerRadius: CGFloat) -> some View {
    let placeholder = Rectangle()
        .foregroundColor(Color(NSColor.underPageBackgroundColor))
        .cornerRadius(cornerRadius)
    
    if let url = url {
        URLImage(url: url,
                 empty: { placeholder },
                 inProgress: { _ in placeholder },
                 failure: { _, _ in placeholder },
                 content: { image in
            image.resizable()
                .cornerRadius(cornerRadius)
        })
    }
    else {
        placeholder
    }
}

extension Color {
    
    init(hex: UInt, alpha: Double = 1) {
        let red = Double((hex >> 16) & 0xff) / 255
        let green = Double((hex >> 08) & 0xff) / 255
        let blue = Double((hex >> 00) & 0xff) / 255
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
    
}

extension View {
    
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
}
