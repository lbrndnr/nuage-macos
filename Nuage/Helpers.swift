//
//  Helpers.swift
//  Nuage
//
//  Created by Laurin Brandner on 22.12.19.
//  Copyright © 2019 Laurin Brandner. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct FillableSysteImageStyle: ButtonStyle {
    
    var systemImageName: String
    
    var resizeable: Bool
    
    init(systemImageName: String, resizeable: Bool = true) {
        self.systemImageName = systemImageName
        self.resizeable = resizeable
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        let imageName = configuration.isPressed ? systemImageName + ".fill" : systemImageName
        let image = Image(systemName: imageName)
        
        if resizeable {
             return AnyView(image
                .resizable()
                .scaledToFit()
                .padding(3))
        }
        
        return AnyView(image)
    }

}

private var durationFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .positional
    formatter.allowedUnits = [.hour, .minute, .second]
    
    return formatter
}()

func format(duration: TimeInterval) -> String {
    return durationFormatter.string(from: duration) ?? "0"
}

extension AnyCancellable {
    
    func store<T: Hashable>(in dictionary: inout Dictionary<T, AnyCancellable>, key: T) {
        dictionary[key] = self
    }
    
}

