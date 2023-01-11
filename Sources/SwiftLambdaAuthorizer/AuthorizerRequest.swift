//
//  AuthorizerRequest.swift
//
//
//  Created by Kevin Hinkson on 2023-01-05.
//  This is originally from AWS Lambda Runtime and modified to suit a custom Authorizer lambda request
//  https://github.com/swift-server/swift-aws-lambda-runtime
//

import Foundation
import AWSLambdaEvents

public struct AuthorizerRequest: Codable {
    /// Context contains the information to identify the AWS account and resources invoking the Lambda function.
    public struct Context: Codable {
        public struct HTTP: Codable {
            public let method: AWSLambdaEvents.HTTPMethod
            public let path: String
            public let `protocol`: String
            public let sourceIp: String
            public let userAgent: String
        }

        /// Authorizer contains authorizer information for the request context.
        public struct Authorizer: Codable {
            /// JWT contains JWT authorizer information for the request context.
            public struct JWT: Codable {
                public let claims: [String: String]
                public let scopes: [String]?
            }

            public let jwt: JWT
        }

        public let accountId: String
        public let apiId: String
        public let domainName: String
        public let domainPrefix: String
        public let stage: String
        public let requestId: String
        public let routeKey: String

        public let http: HTTP
        public let authorizer: Authorizer?    // This does not exist for lambda authorizer request payload

        /// The request time in format: 23/Apr/2020:11:08:18 +0000
        public let time: String
        public let timeEpoch: UInt64
    }

    public let version: String
    public let type: String = "REQUEST"
    public let routeArn: String
    public let identitySource: [String]?
    public let routeKey: String
    public let rawPath: String
    public let rawQueryString: String

    public let cookies: [String]?
    public let headers: AWSLambdaEvents.HTTPHeaders
    public let queryStringParameters: [String: String]?
    public let pathParameters: [String: String]?
    public let stageVariables: [String: String]?
    
    public let context: Context

    public let body: String?            // This does not exist for lambda authorizer request payload

    enum CodingKeys: String, CodingKey {
        case version
        case type
        case routeArn
        case identitySource
        case routeKey
        case rawPath
        case rawQueryString

        case cookies
        case headers
        case queryStringParameters
        case pathParameters

        case context = "requestContext"
        case stageVariables

        case body
    }
}
