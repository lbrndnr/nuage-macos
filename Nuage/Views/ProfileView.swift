//
//  ProfileView.swift
//  Nuage
//
//  Created by Laurin Brandner on 28.12.19.
//  Copyright © 2019 Laurin Brandner. All rights reserved.
//

import SwiftUI
import SoundCloud

struct ProfileView: View {
    
    var user: User
    
    var body: some View {
        HStack {
            RemoteImage(url: user.avatarURL, cornerRadius: 50)
                .frame(width: 100, height: 100)
            Text(user.username)
        }
        .frame(minWidth: 200)
    }
    
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(user: previewUser)
    }
}
