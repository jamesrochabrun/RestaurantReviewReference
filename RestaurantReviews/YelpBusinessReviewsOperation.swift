//
//  YelpBusinessReviewsOperation.swift
//  RestaurantReviews
//
//  Created by James Rochabrun on 11/27/17.
//  Copyright © 2017 Treehouse. All rights reserved.
//

import Foundation

class YelpBusinessReviewsOperation: Operation {
    
    let business: YelpBusiness
    let client: YelpClient
    
    init(business: YelpBusiness, client: YelpClient) {
        self.business = business
        self.client = client
        super.init()
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    private var _finished = false //backing property
    
    //read publicly but just set it privately
    override private(set) var isFinished: Bool {
        get {
            return _finished
        }
        set {
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished") //KVO
        }
    }
    
    private var _executing = false
    
    override var isExecuting: Bool {
        get {
            return _executing
        }
        set {
            willChangeValue(forKey: "isExecuting")
            _executing = newValue
            didChangeValue(forKey: "isExecuting") //KVO
        }
    }
    
    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
        
        isExecuting = true
        client.reviews(for: business) { [unowned self] (result) in
            switch result {
            case .success(let reviews):
                self.business.reviews = reviews
                self.isExecuting = false
                self.isFinished = true
            case .failure(let error):
                print(error)
                self.isExecuting = false
                self.isFinished = true
            }
        }
    }
}










