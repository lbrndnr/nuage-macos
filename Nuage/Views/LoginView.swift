//
//  LoginView.swift
//  Nuage
//
//  Created by Laurin Brandner on 04.12.20.
//  Copyright © 2020 Laurin Brandner. All rights reserved.
//

import SwiftUI
import Combine
import SoundCloud

struct LoginView: View {
    
    @State private var username = ""
    @State private var password = ""
    
    private var onLogin: () -> ()
    
    @State private var subscriptions = Set<AnyCancellable>()
    
    var body: some View {
        VStack {
            TextField("Username", text: $username)
            SecureField("Password", text: $password)
                
            Button("Login") {
                SoundCloud.login(username: username, password: password)
                    .receive(on: RunLoop.main)
                    .sink(receiveCompletion: { completion in
                }, receiveValue: { accessToken in
                    SoundCloud.shared.accessToken = accessToken
                    onLogin()
                }).store(in: &subscriptions)
            }
        }
    }
    
    init(onLogin: @escaping () -> ()) {
        self.onLogin = onLogin
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView { }
    }
}
