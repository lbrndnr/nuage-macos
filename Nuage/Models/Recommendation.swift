//
//  Recommendation.swift
//  Nuage
//
//  Created by Laurin Brandner on 27.12.19.
//  Copyright © 2019 Laurin Brandner. All rights reserved.
//

import Foundation

struct Recommendation: SoundCloudIdentifiable {
    
    var id: Int {
        return user.id
    }
    
    var user: User
    
}

extension Recommendation: Decodable {

    enum CodingKeys: String, CodingKey {
        case user
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        user = try container.decode(User.self, forKey: .user)
    }
    
}
