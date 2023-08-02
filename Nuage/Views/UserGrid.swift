//
//  UserGrid.swift
//  Nuage
//
//  Created by Laurin Brandner on 27.12.19.
//  Copyright © 2019 Laurin Brandner. All rights reserved.
//

import SwiftUI
import Combine
import SoundCloud

struct UserGrid<Element: Decodable&Identifiable&Filterable&Hashable>: View {
    
    var publisher: InfinitePublisher<Element>
    private var transform: (Element) -> User
    
    var body: some View {
        InfiniteGrid(publisher: publisher) { users, idx in
            let user = transform(users[idx])
            NavigationLink(value: user) {
                UserItem(user: user)
            }
            .buttonStyle(.plain)
        }
    }
    
}

extension UserGrid where Element == User {
    
    init(for publisher: AnyPublisher<Slice<User>, Error>) {
        self.init(publisher: .slice(publisher)) { $0 }
    }
    
}

extension UserGrid where Element == Recommendation {
    
    init(for publisher: AnyPublisher<Slice<Recommendation>, Error>) {
        self.init(publisher: .slice(publisher)) { $0.user }
    }
    
}

struct UserItem: View {
    
    var user: User
    
    var body: some View {
        VStack {
            RemoteImage(url: user.avatarURL, cornerRadius: 50)
                .frame(width: 100, height: 100)
            VStack(alignment: .leading) {
                Text(user.username)
                    .bold()
                    .lineLimit(1)
                Text(String(user.followerCount ?? 0))
            }
        }
    }

}

//struct UserList_Previews: PreviewProvider {
//    static var previews: some View {
//        UserList()
//    }
//}
