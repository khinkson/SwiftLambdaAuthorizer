# Swift Lambda Authorizer
[<img src="http://img.shields.io/badge/swift-5.7-brightgreen.svg" alt="Swift 5.7" />](https://swift.org)

This project is part of the [Swift in the Cloud Series](https://www.flue.cloud/swift-server-cloud/) to demonstrate the basics of building a Swift based Lambda API that can requests from multiple regions. To successfully complete the steps below, you should start at the beginning of this series with the [AWS Swift Multi-Region API](https://github.com/khinkson/aws-swift-multi-region-api) project.

## Requirements
To complete this setup you will need:
1. Xcode 14+
2. Docker 4+
3. AWS CLI (setup to access the AWS account used in the [AWS Swift Multi-Region API](https://github.com/khinkson/aws-swift-multi-region-api) project)

## Getting Started
This code will build a Swift ARM package for Graviton Lambda instances by default.

### Installation
1. Create a bucket for the project in AWS S3 in the same region you began installing your Cloudformation stacks. `bucketname` will be translated by the Cloudformation template as `swiftlambda-regionname`. Eg: if `swiftlambda` is set at the template bucketname, then `swiftlambda-us-east-2` will be the bucket name the Cloudformation template looks for in us-east-2 (Ohio).
2. Clone `SwiftLambdaAuthorizer` locally
3. Make sure docker is running
4. From the command line change directories into the project. 
5. Run `./build.sh`. To change the available options run `./build.sh -h`
6. Run `./package.sh`. To change the available options run `./package.sh -h`

```sh
cd SwiftLambdaAuthorizer/

# Build SwiftLambdaAuthorizer
# Available Swift AmazonLinux2 versions: https://hub.docker.com/_/swift/?tab=tags
./build.sh -v 5.7.2 -a linux/arm64

# Package SwiftLambdaAuthorizer for upload to S3
./package.sh -n SwiftLambdaAuthorizer

# Upload to S3 via AWS CLI. Change bucketName and the keyPath as needed
# NB: You can also just upload the file lambda.zip via the AWS S3 Console
aws s3 cp .build/lambda/SwiftLambdaAuthorizer/lambda.zip s3://swiftlambda-us-east-2/SwiftLambdaAuthorizer/
```

Make a note of the final keyPath of the upload. You will need this for the [AWS Swift Multi-Region API](https://github.com/khinkson/aws-swift-multi-region-api) CloudFormation template.

## Package Dependencies
This project makes use of:
- [Swift AWS Runtime](https://github.com/swift-server/swift-aws-lambda-runtime) — AWS Lambda Runtime API implementation in Swift

## Testing Locally
You can also build and run this code locally in Xcode. To do this you will need to set an environment variable to enable the lambda server to run locally. Use Xcode's scheme editor to add environment variables to your app. In the Xcode menu, go to Product > Scheme > Edit Scheme. Select Run on the left, select Arguments in the main window. Under Environment Variables add __Name__: `LOCAL_LAMBDA_SERVER_ENABLED`, __Value__: `true`.

Build and run the project and you should see Output similar to the following:
```
2023-01-10T16:01:11-0500 info LocalLambdaServer : [AWSLambdaRuntimeCore] LocalLambdaServer started and listening on 127.0.0.1:7000, receiving events on /invoke
2023-01-10T16:01:11-0500 info Lambda : [AWSLambdaRuntimeCore] lambda lifecycle startingwith Configuration
	General(logLevel: info))
	Lifecycle(id: 24655414529708, maxTimes: 0, stopSignal: TERM)
RuntimeEngine(ip: 127.0.0.1, port: 7000, requestTimeout: nil
```

This allows you to POST requests to 127.0.0.1 (localhost) on port 7000 and have the authorizer response. The format of these requests, is expected to be in the same format (version 2.0) that APIGateway uses to talk to Lambda Authorizers.  

For testing you can copy the example below and use it locally. The only change made to the [AWS v2.0 default](https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-lambda-authorizer.html) is to add the `authorization` header. In this example, the header must be set to the value hardcoded in the `SwiftLambdaAuthorizer` code as the variable `hardCodedExpectedAuthorizationHeaderValue` to get a response allowing access. This simplified authentication is setup for testing purposes only. In production code you would be expected to use more robust authentication methods eg: JWT.  From the command line you can run this via curl.

```sh
## SwiftLambdaAuthorizer (POST) local 
curl -X "POST" "http://localhost:7000/invoke" \
     -H 'Content-Type: application/json' \
     -d $'{
  "identitySource": [
    "user1",
    "123"
  ],
  "version": "2.0",
  "headers": {
    "Header2": "value2",
    "authorization": "SKOcSFZd8pKoZ24WXYK2dSEc5Nf2eao9QOOvpPYM"
  },
  "rawPath": "/my/path",
  "type": "REQUEST",
  "stageVariables": {
    "stageVariable2": "value2",
    "stageVariable1": "value1"
  },
  "routeKey": "$default",
  "cookies": [
    "cookie1",
    "cookie2"
  ],
  "requestContext": {
    "accountId": "123456789012",
    "time": "12/Mar/2020:19:03:58 +0000",
    "http": {
      "path": "/my/path",
      "userAgent": "agent",
      "method": "POST",
      "protocol": "HTTP/1.1",
      "sourceIp": "IP"
    },
    "domainName": "id.execute-api.us-east-1.amazonaws.com",
    "timeEpoch": 1583348638390,
    "authentication": {
      "clientCert": {
        "serialNumber": "a1:a1:a1:a1:a1:a1:a1:a1:a1:a1:a1:a1:a1:a1:a1:a1",
        "clientCertPem": "CERT_CONTENT",
        "validity": {
          "notBefore": "May 28 12:30:02 2019 GMT",
          "notAfter": "Aug  5 09:36:04 2021 GMT"
        },
        "subjectDN": "www.example.com",
        "issuerDN": "Example issuer"
      }
    },
    "domainPrefix": "id",
    "apiId": "api-id",
    "routeKey": "$default",
    "requestId": "id",
    "stage": "$default"
  },
  "pathParameters": {
    "parameter1": "value1"
  },
  "queryStringParameters": {
    "parameter2": "value",
    "parameter1": "value1,value2"
  },
  "rawQueryString": "parameter1=value1&parameter1=value2&parameter2=value",
  "routeArn": "arn:aws:execute-api:us-east-1:123456789012:abcdef123/test/GET/request"
}'
```

## Next Steps
As mentioned above this project is part of the [Swift in the Cloud Series](https://www.flue.cloud/swift-server-cloud/). The next step is to go back the [AWS Swift Multi-Region API](https://github.com/khinkson/aws-swift-multi-region-api) and complete the SwiftLambdaAuthorizer lambda template stack with the parameter data generated here.

## Further Improvements
Time will bring changes to this project. To really make this setup robust, it can be improved by adding:
1. Testing is ignored in this project. As it develops testing may become more relevant.
2. Simpler build and packaging scripting
3. Better automation via the AWS CLI

## License
__SwiftLambdaAuthorizer__ is released under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0). See LICENSE for details.
