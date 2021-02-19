//
//  UserDetail.swift
//  Nuage
//
//  Created by Laurin Brandner on 03.01.21.
//

import SwiftUI
import Combine
import SoundCloud

struct UserDetail: View {
    
    @State private var user: User
    @State private var selection = 0
    @State private var subscriptions = Set<AnyCancellable>()
    
    var body: some View {
        VStack {
            HStack {
                RemoteImage(url: user.avatarURL, cornerRadius: 25)
                    .frame(width: 50, height: 50)
                VStack(alignment: .leading) {
                    Text(user.username)
                        .bold()
                        .lineLimit(1)
                    Text(String(user.followerCount ?? 0))
                    if let description = user.description {
                        Text(description)
                    }
                }
            }
            Picker(selection: $selection, label: EmptyView()) {
                Text("Stream").tag(0)
                Text("Likes").tag(1)
                Text("Following").tag(2)
                Text("Followers").tag(3)
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 400)

            stream(for: selection)
        }
        .onAppear {
            SoundCloud.shared.get(.user(with: user.id))
                .replaceError(with: user)
                .assign(to: \.user, on: self)
                .store(in: &subscriptions)
        }
    }
    
    @ViewBuilder private func stream(for selection: Int) -> some View {
        switch selection {
        case 1: TrackList(for: SoundCloud.shared.get(.trackLikes(of: user)))
        case 2: UserGrid(for: SoundCloud.shared.get(.followings(of: user)))
        case 3: UserGrid(for: SoundCloud.shared.get(.followers(of: user)))
        default: PostList(for: SoundCloud.shared.get(.stream(of: user)))
        }
    }
    
    init(user: User) {
        self._user = State(initialValue: user)
    }
    
}
