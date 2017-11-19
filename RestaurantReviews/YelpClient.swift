//
//  YelpClient.swift
//  RestaurantReviews
//
//  Created by James Rochabrun on 9/9/17.
//  Copyright © 2017 Treehouse. All rights reserved.
//

import Foundation

class YelpClient: APIClient {
    
    let session: URLSession
    private let token : String
    
    init(configuration: URLSessionConfiguration, oauthToken: String) {
        self.session = URLSession(configuration: configuration)
        self.token = oauthToken
    }
    
    convenience init(oauthToken: String) {
        self.init(configuration: .default, oauthToken: oauthToken)
    }
    
    func search(withTerm term: String, at coordinate: Coordinate, categories: [YelpCategory] = [], radius: Int? = nil, limit: Int = 50, sortBy sortType: Yelp.YelpSortType = .rating, completion: @escaping (Result<[YelpBusiness], APIError>) -> Void) {
        
        let endpoint = Yelp.search(term: term, coordinate: coordinate, radius: radius, categories: categories, limit: limit, sortBy: sortType)
        let request = endpoint.requestWithAuthorizationHeader(oauthToken: token)
        
        //MARK: EXAMPLE OF PRINTING REQUEST TO DEBUG IT
        print("REQUEST \(request)")
        //REQUEst https://api.yelp.com/v3/businesses/search?term=Coffee&latitude=37.7873589&longitude=-122.408227&radius&categories=&limit=50&sort_by=rating
        print("HEADERS \(request.allHTTPHeaderFields)")


        fetch(with: request, parse: { json -> [YelpBusiness] in
            guard let businesses = json["businesses"] as? [[String: Any]] else { return [] }
            return businesses.flatMap { YelpBusiness(json: $0) }
        }, completion: completion)//this is the completion of the fetch fuction and beacuse completion is generic now is of type
        //(Result<[YelpBusiness], APIError>) -> Void)
    }
}








