# ZNRestAPI
ZNRestAPI is a lightweight Objective-C library that sits as a layer on top of the AFNetworking framework. It is designed
to simplify communication with a JSON-based REST API.

### Setup
- [AFNetworking 2.x](https://github.com/AFNetworking/AFNetworking) is a required dependency.
- The code available here is a full sample project demonstrating how to use the library. To make use of it in your own projects, all you need is the ZNRestAPI subfolder.
- This project does not support CocoaPods at this time.

### Architecture
This project only consists of a single class, called ZNRestAPI. This class will be responsible for tracking any persistent
information between API calls, as well as directly making the calls themselves. You can access and use a shared instance using
the `[ZNRestAPI instance]` - recommended if you're only contacting a single API. If you need to reach multiple APIs, or dislike
shared instances, you can safely instantiate and use your own ZNRestAPI instances.

##### Configuration
Before using ZNRestAPI, it must be configured with a base URL. This is the domain all your endpoints are on. You can set this property like so:
```objective-c
// requests will go to http://www.testdomain.com/api/<endpoint>
[ZNRestAPI instance].baseURL = @"http://www.testdomain.com/api";
```
Please note that the base URL must include the http/https component, and must not have a trailing slash.
If you wish, you can also use include API versioning.
```objective-c
// requests will go to http://www.testdomain.com/api/v2/<endpoint>
[ZNRestAPI instance].baseURL = @"http://www.testdomain.com/api";
[ZNRestAPI instance].usesAPIVersion = YES;
[ZNRestAPI instance].apiVersion = 2;
```
Finally, if there's any HTTP headers you want to include in every API call (an API key is a good example of this), you can
specify them in the configuration;
```objective-c
[ZNRestAPI instance].universalHeaders = @{ @"X-API-KEY":@"iubenfuvibseius" };
```

##### Usage
Placing requests using ZNRestAPI, once configured, can be done with a single call. Below is a simple example:
```objective-c
NSString* accessToken;
NSDictionary* parameters = @{ @"email":@"znrestapi@test.com", @"password":@"zxcv" };
[[ZNRestAPI instance] sendRequestToAPI:@"login" requestType:ZNHTTPRequestTypePOST params:parameters completion:^(BOOL successful, NSDictionary *responseObject, NSError *error) {
   if(successful)
   { 
      NSLog(@"Login complete!");
      accessToken = responseObject[@"access_token"];
      [self performSegueWithIdentifier:@"LoginFinished"];
   }
   else
   {
      UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Problem logging in." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
      [alert show];
   }
}
```

There are five methods of varying complexity you can use.
```objective-c
- (void)sendRequestToAPI:(NSString*)api requestType:(ZNHTTPRequestType)type params:(NSDictionary*)params completion:(ZNRestAPICompletionBlock)completion;
- (void)sendRequestToAPI:(NSString*)api requestType:(ZNHTTPRequestType)type params:(NSDictionary*)params headers:(NSDictionary*)headers completion:(ZNRestAPICompletionBlock)completion;
- (void)sendRequestToAPI:(NSString*)api requestTypeString:(NSString*)type   params:(NSDictionary*)params completion:(ZNRestAPICompletionBlock)completion;
- (void)sendRequestToAPI:(NSString*)api requestTypeString:(NSString*)type   params:(NSDictionary*)params headers:(NSDictionary*)headers completion:(ZNRestAPICompletionBlock)completion;
- (void)sendRequestToAPI:(NSString*)api requestTypeString:(NSString*)type   params:(NSDictionary*)params headers:(NSDictionary*)headers urlEncodedParams:(BOOL)doesUrlEncode completion:(ZNRestAPICompletionBlock)completion;
```
These methods allow you to send a request to an endpoint and process the response, with the request optionally including headers. 
- The `api` parameter only needs to consist of the endpoint name, without a leading slash.
- The `type` parameter here is either a string name of a VERB (ie 'GET'), or one of a number of enum values representing the most common HTTP verbs (GET, POST, PUT, PATCH, and DELETE)
- The `params` set of key-value pairs will be sent with the HTTP request. For GET requests, the parameters will be automatically encoded into the URL (http://www.testdomain.com/api/users?id=2), while for other types they will be sent as JSON data in the request's body ( { "id":2 } ). For the last method type, the does UrlEncode parameter overrides this (allowing you send POST requests with URL encoding, or GET requests with a JSON body).
- The `headers` set of key-value pairs, if included, will be sent as the HTTP headers. This is in addition to any universal headers the ZNRestAPI instance has been configured with.
- The `completion` block is called after the operation is complete, along with feedback about it's success/failure, the returned object in the response (if success), and an NSError instance (if failure).

##### Caveats/Things to be aware of
- The base URL must have the http or https component.
- The base URL must not have a trailing slash
- The endpoint supplied must not have a leading slash.
- There is currently no way to send multipart form data using this library.
- In addition to the error information returned by AFNetworking, the error parameter of the completion block also contains the keys 'operation', 'response', and 'request'.
- This library is only designed to process JSON requests and responses. 
- True or false values included in the JSON request will be sent to the server as 1 or 0 respectively. This is an iOS limitation, due to the fact that booleans can only be included in dictionaries as an NSNumber, which is converted back as an integer instead of the original boolean.
