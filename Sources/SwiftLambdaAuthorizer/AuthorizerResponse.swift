//
//  AuthorizerResponse.swift
//  
//
//  Created by Kevin Hinkson on 2023-01-05.
//

import Foundation
import AWSLambdaEvents

public struct AuthorizerResponse: Codable {
    let isAuthorized    : Bool
    
    public init(isAuthorized: Bool) {
        self.isAuthorized = isAuthorized
    }
}
