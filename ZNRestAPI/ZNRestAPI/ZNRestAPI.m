//
//  ZNRestAPI.m
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

#import "ZNRestAPI.h"
#import "AFNetworking.h"

static ZNRestAPI* instance;

@interface ZNRestAPI ()
@property (readonly, nonatomic) NSString* versionedURL;
- (AFHTTPRequestOperation *)createUrlEncodedRequestForAPI:(NSString *)api type:(NSString*)requestType params:(NSDictionary *)params headers:(NSDictionary*)headers;
- (AFHTTPRequestOperation *)createBodyEncodedRequestForAPI:(NSString *)api type:(NSString*)requestType params:(NSDictionary *)params headers:(NSDictionary*)headers;
- (NSString*)requestTypeStringFromEnum:(ZNHTTPRequestType)type;
@end

@implementation ZNRestAPI

#pragma mark - Initialisation and setup methods

+ (ZNRestAPI *)instance
{
    static dispatch_once_t creationToken;
    dispatch_once(&creationToken, ^{
        instance = [ZNRestAPI new];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        _baseURL = nil;
        _apiVersion = 0;
        _usesAPIVersion = NO;
    }
    return self;
}
#pragma mark - Helper methods

- (NSString *)versionedURL
{
    if(self.usesAPIVersion)
    { return [NSString stringWithFormat:@"%@v%lu", self.baseURL, (long)self.apiVersion]; }
    else
    { return self.baseURL; }
}

- (NSString *)requestTypeStringFromEnum:(ZNHTTPRequestType)type
{
    switch(type)
    {
        case ZNHTTPRequestTypeGET:    return @"GET";
        case ZNHTTPRequestTypePOST:   return @"POST";
        case ZNHTTPRequestTypePUT:    return @"PUT";
        case ZNHTTPRequestTypeDELETE: return @"DELETE";
        case ZNHTTPRequestTypePATCH:  return @"PATCH";
    }
}

- (void)addHeaders:(NSDictionary*)headers toRequest:(NSMutableURLRequest*)request
{
    for(NSString* key in self.universalHeaders.allKeys)
    { [request setValue:self.universalHeaders[key] forKey:key]; }
    
    if(headers != nil)
    {
        for(NSString* key in headers.allKeys)
        { [request setValue:headers[key] forKey:key]; }
    }
}

#pragma mark - API Communication methods

- (AFHTTPRequestOperation *)createUrlEncodedRequestForAPI:(NSString *)api type:(NSString*)requestType params:(NSDictionary *)params headers:(NSDictionary*)headers
{
    NSString* urlString = [NSString stringWithFormat:@"%@/%@", self.versionedURL, api];
    BOOL firstParam = YES;
    for(NSString* key in params.allKeys)
    {
        NSString* value;
        if([params[key] isKindOfClass:[NSString class]])
        { value = params[key]; }
        else
        { value = [params[key] description]; }
        urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"%@%@=%@", firstParam ? @"?" : @"&", key, value]];
        firstParam = NO;
    }
    NSURL* apiUrl = [NSURL URLWithString:urlString];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:apiUrl];
    [self addHeaders:headers toRequest:request];
    [request setHTTPMethod:requestType];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    return operation;
}

- (AFHTTPRequestOperation *)createBodyEncodedRequestForAPI:(NSString *)api type:(NSString*)requestType params:(NSDictionary *)params headers:(NSDictionary*)headers
{
    NSString* urlString = [NSString stringWithFormat:@"%@/%@", self.versionedURL, api];
    NSURL* apiUrl = [NSURL URLWithString:urlString];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:apiUrl];
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    [request setHTTPMethod:requestType];
    [self addHeaders:headers toRequest:request];
    if(params)
    { [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:params options:0 error:nil]]; }
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    return operation;
}

- (void)sendRequestToAPI:(NSString *)api requestType:(ZNHTTPRequestType)type params:(NSDictionary *)params completion:(ZNRestAPICompletionBlock)completion
{ [self sendRequestToAPI:api requestTypeString:[self requestTypeStringFromEnum:type] params:params headers:nil urlEncodedParams:(type == ZNHTTPRequestTypeGET) completion:completion]; }

- (void)sendRequestToAPI:(NSString *)api requestType:(ZNHTTPRequestType)type params:(NSDictionary *)params headers:(NSDictionary *)headers completion:(ZNRestAPICompletionBlock)completion
{ [self sendRequestToAPI:api requestTypeString:[self requestTypeStringFromEnum:type] params:params headers:headers urlEncodedParams:(type == ZNHTTPRequestTypeGET) completion:completion]; }

- (void)sendRequestToAPI:(NSString *)api requestTypeString:(NSString *)type params:(NSDictionary *)params completion:(ZNRestAPICompletionBlock)completion
{ [self sendRequestToAPI:api requestTypeString:type params:params headers:nil urlEncodedParams:[type isEqualToString:@"GET"] completion:completion]; }

- (void)sendRequestToAPI:(NSString *)api requestTypeString:(NSString *)type params:(NSDictionary *)params headers:(NSDictionary *)headers completion:(ZNRestAPICompletionBlock)completion
{ [self sendRequestToAPI:api requestTypeString:type params:params headers:headers urlEncodedParams:[type isEqualToString:@"GET"] completion:completion]; }

- (void)sendRequestToAPI:(NSString *)api requestTypeString:(NSString *)type params:(NSDictionary *)params headers:(NSDictionary *)headers urlEncodedParams:(BOOL)doesUrlEncode completion:(ZNRestAPICompletionBlock)completion
{
    AFHTTPRequestOperation* operation;
    
    if(doesUrlEncode)
    { operation = [self createUrlEncodedRequestForAPI:api type:type params:params headers:headers]; }
    else
    { operation = [self createBodyEncodedRequestForAPI:api type:type params:params headers:headers]; }
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(YES, responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSMutableDictionary* mutableUserInfo = [error.userInfo mutableCopy];
        if(operation)
        { mutableUserInfo[@"operation"] = operation; }
        if(operation.responseString)
        { mutableUserInfo[@"response"] = operation.responseString; }
        if(operation.request.HTTPBody)
        {
            NSString* requestString = [[NSString alloc] initWithData:operation.request.HTTPBody encoding:NSUTF8StringEncoding];
            if(requestString)
            { mutableUserInfo[@"request"] = requestString; }
        }
        mutableUserInfo[NSUnderlyingErrorKey] = error;
        
        completion(NO, nil, [NSError errorWithDomain:@"ZNRestAPI" code:0 userInfo:mutableUserInfo]);
    }];
    [operation start];
}

@end
