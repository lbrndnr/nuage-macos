//
//  TrackView.swift
//  Nuage
//
//  Created by Laurin Brandner on 18.11.20.
//  Copyright © 2020 Laurin Brandner. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct TrackView: View {
    
    var track: Track
    
    var body: some View {
        HStack {
            WebImage(url: track.artworkURL)
                .frame(width: 100, height: 100)
                .cornerRadius(50)
            Text(track.title)
        }
        .frame(minWidth: 200)
    }
    
}
