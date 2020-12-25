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
    
    private var onLogin: (String) -> ()
    
    @State private var subscriptions = Set<AnyCancellable>()
    
    var body: some View {
        VStack {
            ZStack {
                Image(systemName: "app")
                    .resizable()
                    .frame(width: 200, height: 200)
                Text("N")
                    .font(.system(size: 40))
                    .bold()
            }
            
            Spacer().frame(height: 20)
            
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Spacer().frame(height: 20)
            
            Button("Login") {
                SoundCloud.login(username: username, password: password)
                    .receive(on: RunLoop.main)
                    .sink(receiveCompletion: { completion in
                }, receiveValue: onLogin)
                .store(in: &subscriptions)
            }
            .keyboardShortcut(.defaultAction)
        }
        .frame(width: 300)
        .fixedSize()
        .padding()
    }
    
    init(onLogin: @escaping (String) -> ()) {
        self.onLogin = onLogin
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView { _ in }
    }
}
