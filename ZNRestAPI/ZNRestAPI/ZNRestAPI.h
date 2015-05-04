//
//  ZNRestAPI.h
// Copyright (c) 2015 Jonathan Head
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
@class AFHTTPRequestOperation;

/** This block definition represents the block that will be called when the request is finished.
 *
 * @param successful This field will be set to YES in the event of a successful call (server returns a 2xx response, and the response body could be processed to JSON), otherwise it will be set to NO.
 * @param responseObject This contains the NSDictionary or NSArray object that the JSON response was processed to. If the response could not be processed, this parameter is nil.
 * @param error In the event of a problem, this contains the error that AFNetworking returned. It also contains the request and response bodies for examination.
**/
typedef void(^ZNRestAPICompletionBlock)(BOOL successful, NSDictionary* responseObject, NSError* error);

/// An enum that contains the most common types of HTTP requests.
typedef enum : NSUInteger {
    /// A HTTP GET request. This is usually used to request information from the server. By default, this type encodes the parameters into the URL.
    ZNHTTPRequestTypeGET,
    /// A HTTP POST request. This is usually used to create or update resources.
    ZNHTTPRequestTypePOST,
    /// A HTTP PUT request. This is usually used to update an existing resource (POST can also be used for this purpose, however).
    ZNHTTPRequestTypePUT,
    /// A HTTP DELETE request. As the name suggests, this is usually used to remove an existing resource from the server.
    ZNHTTPRequestTypeDELETE,
    /// A HTTP PATCH request. This is occasionally used to update part of an existing resource (such as just a single field, instead of the whole object).
    ZNHTTPRequestTypePATCH
} ZNHTTPRequestType;

/// This class represents an object for communicating with a single API system. It is capable of storing the base URL for the API endpoints, headers that should be applied to all API calls (such as an API key), and API versioning information. A shared instance is available to use (see the method 'instance'), or this class can be instantiated manually.
@interface ZNRestAPI : NSObject

/// This field contains the base URL for all API calls, as a string. It should be represented as a full URL, including http or https:// as appropriate, and with no trailing slash.
@property (strong, nonatomic) NSString* baseURL;
/// This field contains a dictionary of all parameters that should be sent as HTTP headers in every API request - for example, an API key.
@property (strong, nonatomic) NSDictionary* universalHeaders;
/// This field contains a number to use for API versioning. If the usesAPIVersion property is set to YES, all API calls will consist of baseURL/v<apiVersion>/<api call>. If the usesAPIVersion field is set to NO, this property is ignored.
@property (nonatomic) NSInteger apiVersion;
/// This field identifies whether to use API versioning. If set to YES, all API calls will be made with a version number (see the apiVersion property).
@property (nonatomic) BOOL usesAPIVersion;

/// Returns a shared instance of this class that can be used when making calls to only a single API.
+ (ZNRestAPI*)instance;

/** Places a call to the requested API endpoint. If type is a GET request, parameters will be encoded into the URL, otherwise they will be sent as a JSON object in the body.
 *
 * @param api The API endpoint to hit. This will be appended to this instance's base URL. A leading slash should not be included.
 * @param type The HTTP verb of the request.
 * @param params The parameters to send in the request. If type is a GET request, these will be encoded into the URL. If not, they will sent as a JSON object in the request body.
 * @param completion The completion block. This is called after the request is completed, along with the results of the call. It should be used to update the interface or perform any required data manipulation
**/
- (void)sendRequestToAPI:(NSString*)api requestType:(ZNHTTPRequestType)type params:(NSDictionary*)params completion:(ZNRestAPICompletionBlock)completion;

/** Places a call to the requested API endpoint. If type is a GET request, parameters will be encoded into the URL, otherwise they will be sent as a JSON object in the body.
 *
 * @param api The API endpoint to hit. This will be appended to this instance's base URL. A leading slash should not be included.
 * @param type The HTTP verb of the request.
 * @param params The parameters to send in the request. If type is a GET request, these will be encoded into the URL. If not, they will sent as a JSON object in the request body.
 * @param headers The headers to include in the request.
 * @param completion The completion block. This is called after the request is completed, along with the results of the call. It should be used to update the interface or perform any required data manipulation
 **/
- (void)sendRequestToAPI:(NSString*)api requestType:(ZNHTTPRequestType)type params:(NSDictionary*)params headers:(NSDictionary*)headers completion:(ZNRestAPICompletionBlock)completion;

/** Places a call to the requested API endpoint. If type is "GET", parameters will be encoded into the URL, otherwise they will be sent as a JSON object in the body.
 *
 * @param api The API endpoint to hit. This will be appended to this instance's base URL. A leading slash should not be included.
 * @param type The HTTP verb of the request, as a string.
 * @param params The parameters to send in the request. If type is a GET request, these will be encoded into the URL. If not, they will sent as a JSON object in the request body.
 * @param completion The completion block. This is called after the request is completed, along with the results of the call. It should be used to update the interface or perform any required data manipulation
 **/
- (void)sendRequestToAPI:(NSString*)api requestTypeString:(NSString*)type   params:(NSDictionary*)params completion:(ZNRestAPICompletionBlock)completion;

/** Places a call to the requested API endpoint. If type is "GET", parameters will be encoded into the URL, otherwise they will be sent as a JSON object in the body.
 *
 * @param api The API endpoint to hit. This will be appended to this instance's base URL. A leading slash should not be included.
 * @param type The HTTP verb of the request, as a string.
 * @param params The parameters to send in the request. If type is a GET request, these will be encoded into the URL. If not, they will sent as a JSON object in the request body.
 * @param headers The headers to include in the request.
 * @param completion The completion block. This is called after the request is completed, along with the results of the call. It should be used to update the interface or perform any required data manipulation
 **/
- (void)sendRequestToAPI:(NSString*)api requestTypeString:(NSString*)type   params:(NSDictionary*)params headers:(NSDictionary*)headers completion:(ZNRestAPICompletionBlock)completion;

/** Places a call to the requested API endpoint. If doesURLEncode is set to YES, parameters will be encoded into the URL, otherwise they will be sent as a JSON object in the body.
 *
 * @param api The API endpoint to hit. This will be appended to this instance's base URL. A leading slash should not be included.
 * @param type The HTTP verb of the request.
 * @param params The parameters to send in the request. If type is a GET request, these will be encoded into the URL. If not, they will sent as a JSON object in the request body.
 * @param headers The headers to include in the request.
 * @param completion The completion block. This is called after the request is completed, along with the results of the call. It should be used to update the interface or perform any required data manipulation
 **/
- (void)sendRequestToAPI:(NSString*)api requestTypeString:(NSString*)type   params:(NSDictionary*)params headers:(NSDictionary*)headers urlEncodedParams:(BOOL)doesUrlEncode completion:(ZNRestAPICompletionBlock)completion;
@end
