//
//  YelpAccount.swift
//  RestaurantReviews
//
//  Created by James Rochabrun on 7/30/17.
//  Copyright © 2017 Treehouse. All rights reserved.
//

import Foundation
import Locksmith

//MARK: SAVING DATA IN KEYCHAIN

struct YelpAccount {
    let accessToken: String
    let expiration: TimeInterval
    let grantDate: Date
    static let service = "Yelp"
}

extension YelpAccount {
    
    static var isAuthorized: Bool {
        return loadFromKeychain() != nil ? true : false
    }
    
   private struct Keys {
        static let token = "token"
        static let expirationPeriod = "expirationPeriod"
        static let grantDate = "grantDate"
        
    }
    
    func save() throws {
        try Locksmith.saveData(data: [Keys.token: accessToken,
                                      Keys.expirationPeriod: expiration,
                                      Keys.grantDate: grantDate.timeIntervalSince1970],
                               forUserAccount:  YelpAccount.service)
        
    }
    
    static func loadFromKeychain() -> YelpAccount? {
        
        guard let dictionary = Locksmith.loadDataForUserAccount(userAccount: YelpAccount.service),
        let token = dictionary[Keys.token] as? String,
        let expiration = dictionary[Keys.expirationPeriod] as? TimeInterval,
            let grantDateValue = dictionary[Keys.grantDate] as? TimeInterval
            else { return nil }
        let grantDate = Date(timeIntervalSince1970: grantDateValue)
        return YelpAccount(accessToken: token, expiration: expiration, grantDate: grantDate)
    }
}








