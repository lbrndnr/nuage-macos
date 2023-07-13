//
//  Artwork.swift
//  Nuage
//
//  Created by Laurin Brandner on 03.02.21.
//

import SwiftUI

struct Artwork: View {
    
    private var url: URL?
    @State private var showingPlayButton = false
    private var onPlay: () -> ()
    
    var body: some View {
        ZStack {
            RemoteImage(url: url, cornerRadius: 6)
            
            if showingPlayButton {
                Button(action: onPlay) {
                    Image(systemName: "play.fill")
                        .resizable()
                        .offset(x: 2)
                        .padding(12.5)
                        .frame(width: 50, height: 50)

                }
                .buttonStyle(.borderless)
                .background(.regularMaterial, in: Circle())
                .transition(.opacity)
            }
        }
        .onHover { inside in
            withAnimation { showingPlayButton = inside }
        }
    }
    
    init(url: URL?, onPlay: @escaping () -> ()) {
        self.url = url
        self.onPlay = onPlay
    }
    
}

struct Artwork_Previews: PreviewProvider {
    
    static var previews: some View {
        let url = URL(string: "https://i1.sndcdn.com/artworks-o1nyZOY2zZQNqnb3-JbBChA-t120x120.jpg")
        let onPlay = { }
        let artwork = Artwork(url: url, onPlay: onPlay)
        
        return artwork
            .frame(width: 200, height: 200)
    }
    
}
