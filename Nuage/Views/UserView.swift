//
//  UserView.swift
//  Nuage
//
//  Created by Laurin Brandner on 03.01.21.
//

import SwiftUI
import Combine
import SDWebImageSwiftUI

struct UserView: View {
    
    @State var user: User
    @State private var subscriptions = Set<AnyCancellable>()
    
    var body: some View {
        VStack {
            HStack {
                WebImage(url: user.avatarURL)
                    .frame(width: 50, height: 50)
                    .cornerRadius(25)
                VStack(alignment: .leading) {
                    Text(user.username)
                        .bold()
                        .lineLimit(1)
                    Text(String(user.followerCount ?? 0))
                }
            }
            PostList(for: SoundCloud.shared.get(.stream(of: user)))
        }
    }
    
}
