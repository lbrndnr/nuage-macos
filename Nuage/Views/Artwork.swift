//
//  Artwork.swift
//  Nuage
//
//  Created by Laurin Brandner on 03.02.21.
//

import SwiftUI

struct Artwork: View {
    
    private var url: URL?
    @State private var playButtonHidden = true
    private var onPlay: () -> ()
    
    var body: some View {
        ZStack {
            RemoteImage(url: url, cornerRadius: 6)
            
            if !playButtonHidden {
                Button(action: onPlay) {
                    Image(systemName: "play.fill")
                        .resizable()
                        .offset(x: 2)
                        .padding(2)
                        .frame(width: 27, height: 27)

                }
                .frame(width: 50, height: 50)
                .buttonStyle(BorderlessButtonStyle())
                .background(.regularMaterial, in: Circle())
                .transition(.opacity)
            }
        }
        .onHover { inside in
            withAnimation { playButtonHidden = !inside }
        }
    }
    
    init(url: URL?, onPlay: @escaping () -> ()) {
        self.url = url
        self.onPlay = onPlay
    }
    
}

//struct Artwork_Previews: PreviewProvider {
//    static var previews: some View {
//        Artwork()
//    }
//}
