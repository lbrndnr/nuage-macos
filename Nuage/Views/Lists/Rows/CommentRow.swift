//
//  CommentRow.swift
//  Nuage
//
//  Created by Laurin Brandner on 19.02.21.
//

import SwiftUI
import Combine
import SoundCloud

struct CommentRow: View {
    
    private var comment: Comment
    
    @State private var subscriptions = Set<AnyCancellable>()
    
    init(comment: Comment) {
        self.comment = comment
    }
    
    var body: some View {
        HStack {
            NavigationLink(value: comment.user) {
                RemoteImage(url: comment.user.avatarURL, cornerRadius: 25)
                    .frame(width: 50, height: 50, alignment: .center)
            }
            VStack(alignment: .leading) {
                let time = format(time: comment.timestamp)
                Text("\(comment.user.displayName) at \(time)")
                    .bold()
                Text(comment.body)
            }
        }
        .padding(6)
    }

}
