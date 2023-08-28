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
    @State private var dataState: DataState = .initial
    @State private var selection: Tab = .stream
    @State private var subscriptions = Set<AnyCancellable>()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 20) {
                RemoteImage(url: user.avatarURL, cornerRadius: 50)
                    .frame(width: 100, height: 100)
                
                VStack(alignment: .leading) {
                    Text(user.username)
                        .font(.title)
                        .lineLimit(1)
                    
                    HStack {
                        Text(String(user.followerCount ?? 0))
                        Text(String(user.followingCount ?? 0))
                    }
                    
                    if let description = user.description {
                        Text(description.withAttributedLinks())
                    }
                }
                .id(dataState)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            
            HStack(spacing: 40) {
                button(for: .stream)
                button(for: .likes)
                button(for: .following)
                button(for: .followers)
            }
            .buttonStyle(.plain)
            
            Divider()
                .padding(.top, 8)

            stream(for: selection)
        }
        .navigationTitle(user.username)
        .onAppear {
            SoundCloud.shared.get(.user(with: user.id))
                .replaceError(with: user)
                .sink { user in
                    self.user = user
                    self.dataState = .loaded
                }
                .store(in: &subscriptions)
        }
    }
    
    @ViewBuilder private func button(for tab: Tab) -> some View {
        Button(action: { selection = tab }, label: {
            let color: Color = selection == tab ? .primary : .secondary
            
            Text(tab.rawValue.capitalized)
                .font(.title2)
                .foregroundColor(color)
        })
    }
    
    @ViewBuilder private func stream(for selection: Tab) -> some View {
        switch selection {
        case .stream: PostList(for: SoundCloud.shared.get(.stream(of: user)))
        case .likes: TrackList(for: SoundCloud.shared.get(.trackLikes(of: user)))
        case .following: UserGrid(for: SoundCloud.shared.get(.followings(of: user)))
        case .followers: UserGrid(for: SoundCloud.shared.get(.followers(of: user)))
        }
    }
    
    init(user: User) {
        self._user = State(initialValue: user)
    }
    
}

extension UserDetail {
    
    enum Tab: String {
        case stream
        case likes
        case following
        case followers
    }
    
    enum DataState: Int {
        case initial
        case loaded
    }
    
}

struct UserDetail_Previews: PreviewProvider {
    
    static var previews: some View {
        UserDetail(user: Preview.tracks.first!.user)
            .environmentObject(StreamPlayer())
            .environmentObject(CommandSubject())
    }
    
}

