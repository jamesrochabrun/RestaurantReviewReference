//
//  PermissionsController.swift
//  RestaurantReviews
//
//  Created by Pasan Premaratne on 5/9/17.
//  Copyright © 2017 Treehouse. All rights reserved.
//

import UIKit
import p2_OAuth2
import CoreLocation

class PermissionsController: UIViewController {
    
    //MARK: Oauth Object
    let oauth = OAuth2ClientCredentials(settings: [
        "client_id" : "nYvOMlD62pRFFqpK6i8qIw",
        "client_secret" : "BZeBMuCvmOTrf8rqIowO3LgyDoJ8N6jkIOUJSAocyxC9uGKcOQeF6pl2EBoJZDWa",
        "authorize_uri" : "https://api.yelp.com/oauth2/token",
        "secret_in_body" : true,
        "keychain" : false
        ])
    //MARK: Location Manager object
    lazy var locationManager: LocationManager = {
        return LocationManager(delegate: nil, permissionDelegate: self)
    }()
    
    var isAuthorizedForLocation: Bool
    var isAuthenticatedWithToken: Bool
    
    lazy var locationPermissionButton:  UIButton = {
        let title = self.isAuthorizedForLocation ? "Location Permissions Granted" : "Request Location Permissions"
        let button = UIButton(type: .system)
        let controlState = self.isAuthorizedForLocation ? UIControlState.disabled : UIControlState.normal
        button.isEnabled = !self.isAuthorizedForLocation
        button.setTitle(title, for: controlState)
        button.addTarget(self, action: #selector(PermissionsController.requestLocationPermissions), for: .touchUpInside)
        
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(colorLiteralRed: 62/255.0, green: 71/255.0, blue: 79/255.0, alpha: 1.0)
        button.setTitleColor(UIColor(colorLiteralRed: 178/255.0, green: 187/255.0, blue: 185/255.0, alpha: 1.0), for: .disabled)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        
        return button
    }()
    
    lazy var oauthTokenButton:  UIButton = {
        let title = self.isAuthenticatedWithToken ? "OAuth Token Granted" : "Request OAuth Token"
        let button = UIButton(type: .system)
        let controlState = self.isAuthenticatedWithToken ? UIControlState.disabled : UIControlState.normal
        button.isEnabled = !self.isAuthenticatedWithToken
        button.setTitle(title, for: controlState)
        button.addTarget(self, action: #selector(PermissionsController.requestOAuthToken), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(colorLiteralRed: 62/255.0, green: 71/255.0, blue: 79/255.0, alpha: 1.0)
        button.setTitleColor(UIColor(colorLiteralRed: 178/255.0, green: 187/255.0, blue: 185/255.0, alpha: 1.0), for: .disabled)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        
        return button
    }()
    
    lazy var dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Dismiss", for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(PermissionsController.dismissPermissions), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder not implemented")
    }
    
    init(isAuthorizedForLocation locationAuthorization: Bool, isAuthorizedWithToken authorized: Bool) {
        self.isAuthorizedForLocation = locationAuthorization
        self.isAuthenticatedWithToken = authorized
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(colorLiteralRed: 95/255.0, green: 207/255.0, blue: 128/255.0, alpha: 1.0)
    }
    

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let stackView = UIStackView(arrangedSubviews: [locationPermissionButton, oauthTokenButton])
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 16.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        view.addSubview(dismissButton)
        
        NSLayoutConstraint.activate([
            locationPermissionButton.heightAnchor.constraint(equalToConstant: 64.0),
            locationPermissionButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            locationPermissionButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            oauthTokenButton.heightAnchor.constraint(equalToConstant: 64.0),
            oauthTokenButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            oauthTokenButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32.0),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32.0),
            dismissButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            dismissButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
    }
    
    func requestLocationPermissions() {
        
        do {
            try locationManager.requestLocationAuthorization()
        } catch let error {
            print("location auth error: \(error.localizedDescription)")
        }
    }
    
    func dismissPermissions() {
        dismiss(animated: true, completion: nil)
    }
}

extension PermissionsController: LocationPermissionsDelegate {
    
    func authSucceded() {
        locationPermissionButton.setTitle("Location permission granted", for: .disabled)
        locationPermissionButton.isEnabled = false
    }
    
    func authFailedWithStaus(_ status: CLAuthorizationStatus) {
        
    }
}

//MARK: Oauth logic
extension PermissionsController {
    
    //MARK: REQUESTING TOKEN AND SAVING IT IN KEYCHAIN
    func requestOAuthToken() {
        
        oauth.authorize { (authJSON, error) in
            
            dump(authJSON)
            if let params = authJSON {
                guard let token = params["access_token"] as? String,
                    let expiration = params["expires_in"] as? TimeInterval
                    else {
                        return
                }
                let account = YelpAccount(accessToken: token, expiration: expiration, grantDate: Date())
                do {
                    try account.save()
                    self.oauthTokenButton.setTitle("Token granted", for: .disabled)
                    self.oauthTokenButton.isEnabled = false
                } catch let error {
                    print("error  is \(error.localizedDescription)")
                }
            } else {
                print("auth went wrong \(String(describing: error))")
            }
        }
    }
}









