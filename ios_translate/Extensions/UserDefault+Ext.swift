//
//  UserDefault+Ext.swift
//  ios_translate
//
//  Created by ThuyetLN on 19/4/24.
//

import Foundation


extension UserDefaults {
    var currentUserJWT: String? {
        UserDefaults.standard.string(forKey: "currentUserJWT")
    }
    var currentUser: UserWithAuthenticationInfo? {
        get {
            if let data = UserDefaults.standard.data(forKey: "currentUser"),
               let user = try? JSONDecoder().decode(UserWithAuthenticationInfo.self, from: data) {
                return user
            } else {
                return nil
            }
        }
        set {
            if let newValue = newValue,
                let json = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.setValue(newValue.jwt, forKey: "currentUserJWT")
                UserDefaults.standard.setValue(json, forKey: "currentUser")
            } else {
                UserDefaults.standard.setValue(nil, forKey: "currentUserJWT")
                UserDefaults.standard.setValue(newValue, forKey: "currentUser")
            }
        }
    }
}
