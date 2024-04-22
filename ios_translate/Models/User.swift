//
//  User.swift
//  ios_translate
//
//  Created by ThuyetLN on 19/4/24.
//

import Foundation
import EasyCodable


struct UserWithAuthenticationInfo: Codable {
    var jwt: String = ""
    var user: User = .init()
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.jwt <- container[.jwt]
        self.user <- container[.user]
    }
}

struct User: Codable, Hashable {
    var id: Int = .zero
    var username: String = ""
    var email: String = ""
    var applications: [UserApplication] = []
    
    init() {}
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id <- container[.id]
        self.username <- container[.username]
        self.email <- container[.email]
        self.applications <- container[.applications]
    }
}
