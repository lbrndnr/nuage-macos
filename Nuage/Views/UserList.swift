//
//  UserList.swift
//  Nuage
//
//  Created by Laurin Brandner on 27.12.19.
//  Copyright © 2019 Laurin Brandner. All rights reserved.
//

import SwiftUI
import Combine
import SoundCloud

struct UserList: View {
    
    @State private var users = [User]()
    @State private var subscriptions = Set<AnyCancellable>()
    
    var body: some View {
        List(users) { user in
            NavigationLink(destination: ProfileView(user: user)) {
                UserRow(user: user)
            }
        }
        .onAppear {
            SoundCloud.shared.get(.whoToFollow())
                .map { $0.collection }
                .replaceError(with: [])
                .receive(on: RunLoop.main)
                .map { $0.map { $0.user } }
                .assign(to: \.users, on: self)
                .store(in: &subscriptions)
        }
    }
    
}

struct UserRow: View {
    
    var user: User
    
    var body: some View {
        HStack {
            RemoteImage(url: user.avatarURL, width: 50, height: 50, cornerRadius: 25)
            VStack(alignment: .leading) {
                Text(user.username)
                    .bold()
                    .lineLimit(1)
                Text(String(user.followerCount ?? 0))
            }
        }
    }

}

struct UserList_Previews: PreviewProvider {
    static var previews: some View {
        UserList()
    }
}
