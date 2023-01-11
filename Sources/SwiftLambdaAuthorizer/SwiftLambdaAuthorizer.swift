import Foundation
import AWSLambdaEvents
import AWSLambdaRuntime

@main
struct SwiftLambdaAuthorizer: AsyncLambdaHandler {
    
    typealias In = AuthorizerRequest
    typealias Out = AuthorizerResponse
    
    /// For more on how to make this more useful with a database
    /// See part 2 of the Swift In The Cloud Series where we
    /// introduce AWS DynamoDB integration
    /// https://www.flue.cloud/swift-server-cloud/
    
    /// Typically used to initialize any larger objects that have longish startup times
    /// but are typically reused with each request. Init once, and reused until the Lambda
    /// goes away. Eg: an AWSClient or DynamoDB client. This method is only invoked once per instance lifetime.
    /// - Parameter context: contains the event loop and logger etc. if needed
    public init(context: Lambda.InitializationContext) async throws {}
    
    /// Each incoming request invokes handle and expects a response in return.
    /// - Parameters:
    ///   - event: the type of event. Use String get the raw incoming data. If given a Decodable type,
    ///   it will be decoded for you. Use the typealias for 'In' above to set the type
    ///   - context: additional data passed to the lambda eg: logger, eventLoop, requestId etc.
    /// - Returns: a response as a Codable type, typealiased as 'Out' above
    func handle(event: In, context: Lambda.Context) async throws -> Out {
        
        let hardCodedExpectedAuthorizationHeaderValue: String = "SKOcSFZd8pKoZ24WXYK2dSEc5Nf2eao9QOOvpPYM"
        let unauthorizedResponse: Out = .init(isAuthorized: false)
        
        guard let authorizationHeaderValue = event.headers["authorization"] else {
            context.logger.error("Authorization header not set: \(event.headers)")
            return unauthorizedResponse
        }
        
        guard authorizationHeaderValue == hardCodedExpectedAuthorizationHeaderValue else {
            context.logger.error("Authorization header value is incorrect: \(authorizationHeaderValue)")
            return unauthorizedResponse
        }
        
        return .init(isAuthorized: true)
    }
    
    /// Used on objects that need to be cleanly shutdown on the main thread or bad things might happen.
    /// Eg: awsClient
    /// - Parameter context: contains the event loop and logger if needed
    public func syncShutdown(context: Lambda.ShutdownContext) throws {}
}
