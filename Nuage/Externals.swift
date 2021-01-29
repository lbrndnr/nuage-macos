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

struct FillableSysteImageStyle: ButtonStyle {
    
    var systemImageName: String
    
    var resizeable: Bool
    
    init(systemImageName: String, resizeable: Bool = true) {
        self.systemImageName = systemImageName
        self.resizeable = resizeable
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        let imageName = configuration.isPressed ? systemImageName + ".fill" : systemImageName
        let image = Image(systemName: imageName)
        
        if resizeable {
             return AnyView(image
                .resizable()
                .scaledToFit()
                .padding(3))
        }
        
        return AnyView(image)
    }

}

private var durationFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .positional
    formatter.allowedUnits = [.hour, .minute, .second]
    
    return formatter
}()

func format(duration: TimeInterval) -> String {
    return durationFormatter.string(from: duration) ?? "0"
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
        case .playlist(let playlist): return playlist.contains(text)
        case .user(let user): return user.contains(text)
        }
    }
    
}

extension HistoryItem: Filterable {
    
    func contains(_ text: String) -> Bool {
        return track.contains(text)
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
extension Playlist: DateComparable {}

extension Waveform {
    
    init(width: Int, height: Int, repeatedSample: Int) {
        self.width = width
        self.height = height
        self.samples = Array(repeating: repeatedSample, count: width)
    }
    
}

extension User {
    
    var displayName: String {
        if name.count > 0 { return name }
        return username
    }
    
}

func RemoteImage(url: URL?, width: CGFloat, height: CGFloat, cornerRadius: CGFloat) -> AnyView {
    let placeholder = Rectangle()
        .foregroundColor(.gray)
        .frame(width: width, height: height)
        .cornerRadius(cornerRadius)
    
    guard let url = url else {
        return AnyView(placeholder)
    }
    
    let image = URLImage(url: url,
             empty: { placeholder },
             inProgress: { _ in placeholder },
             failure: { _, _ in placeholder },
             content: { image in
                image.resizable()
                    .cornerRadius(cornerRadius)
             })
        .frame(width: width, height: height)
    
    return AnyView(image)
}


