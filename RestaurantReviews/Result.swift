//
//  Result.swift
//  RestaurantReviews
//
//  Created by James Rochabrun on 7/30/17.
//  Copyright © 2017 Treehouse. All rights reserved.
//

import Foundation

enum Result<T, U> where U: Error  {
    case success(T)
    case failure(U)
}
