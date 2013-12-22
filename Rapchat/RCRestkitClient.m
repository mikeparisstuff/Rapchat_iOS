//
//  RCRestkitClient.m
//  Rapchat
//
//  Created by Michael Paris on 12/13/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCRestkitClient.h"
#import "RCProfile.h"
#import "RCUser.h"
#import "RCSession.h"
#import "RKValueTransformers.h"
#import "RCAccessToken.h"
#import "RCAccessToken.h"
#import "RCLike.h"
#import "RCComment.h"
#import "RCBaseModel.h"
#import "RCClip.h"

@implementation RCRestkitClient

static const NSString *BASE_URL = @"http://rapchat-django.herokuapp.com";
//static const NSString *BASE_URL = @"http://192.168.1.27:8000";


+(void)setupRestkit
{
    // Initialized RestKit
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    
    // Let AFNetworking manage the activity indicator
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    // Initialize HTTPClient
    NSURL *baseURL = [NSURL URLWithString:BASE_URL];
    AFHTTPClient* client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    // We want to work with json data
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    
    // Initialize RestKit
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    //    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [objectManager.HTTPClient setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Token %@", [userDefaults objectForKey:@"accessToken"]]];
    // Update date format so that we can parse Twitter dates properly
    // Wed Sep 29 15:31:08 +0000 2010
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    //    dateFormatter.dateFormat = @"E MMM d HH:mm:ss Z y";
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    [[RKValueTransformer defaultValueTransformer] insertValueTransformer:dateFormatter atIndex:0];
    //    [RKObjectMapping setDefaultDateFormatters:@[dateFormatter]];
    
    
    [RKObjectMapping addDefaultDateFormatter:dateFormatter];
    
    // Using the Convenience Methods
    NSTimeZone *EST = [NSTimeZone timeZoneWithAbbreviation:@"EST"];
    [RKObjectMapping addDefaultDateFormatterForString:@"yyyy-MM-dd'T'HH:mm:ss'Z'" inTimeZone:EST];
    [RKObjectMapping setPreferredDateFormatter:dateFormatter];
    
    /*
     *  Base Model Mappings
     */
    RKObjectMapping *baseModelMapping = [RKObjectMapping mappingForClass:[RCBaseModel class]];
    [baseModelMapping addAttributeMappingsFromDictionary:@{@"detail": @"detail"}];
    
    /*
     Setup Profile and User Mappings
     */
    RKObjectMapping *profileMapping = [RKObjectMapping mappingForClass:[RCProfile class]];
    [profileMapping addAttributeMappingsFromDictionary:@{
                                                         @"id": @"profileId",
                                                         @"phone_number": @"phoneNumber",
                                                         @"token":@"accessToken"
                                                         }];
    
    RKObjectMapping *userMapping = [RKObjectMapping mappingForClass:[RCUser class]];
    [userMapping addAttributeMappingsFromDictionary:@{
                                                      @"id": @"userId",
                                                      @"first_name": @"firstName",
                                                      @"last_name": @"lastName",
                                                      @"email":@"email",
                                                      @"username": @"username",
                                                      @"date_joined": @"dateJoined"
                                                      //                                                      @"last_login": @"lastLogin"
                                                      }];
    
    /*
     *  Setup profile_users relationship mapping
     */
    RKRelationshipMapping *profileUserRelationshipMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"user" toKeyPath:@"user" withMapping:userMapping];
    [profileMapping addPropertyMapping:profileUserRelationshipMapping];
    
    RKRelationshipMapping *friendsRelationshipMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"friends" toKeyPath:@"friends" withMapping:profileMapping];
    [profileMapping addPropertyMapping:friendsRelationshipMapping];
    
    /*
     Setup Sessions Crowds Mapping
     */
    
    RKObjectMapping *sessionMapping = [RKObjectMapping mappingForClass:[RCSession class]];
    [sessionMapping addAttributeMappingsFromDictionary:@{@"id": @"sessionId",
                                                         @"title": @"title",
                                                         @"likes":@"numberOfLikes",
                                                         @"is_complete": @"isComplete",
                                                         @"created":@"created",
                                                         @"modified":@"modified",
                                                         @"clip_url":@"mostRecentClipUrl",
                                                         @"thumbnail_url": @"thumbnailUrl"}];
    
    /*
     Setup Crowds Mappings
     */
    RKObjectMapping *crowdMapping = [RKObjectMapping mappingForClass:[RCCrowd class]];
    [crowdMapping addAttributeMappingsFromDictionary:@{@"title": @"title",
                                                       @"created": @"created",
                                                       @"modified": @"modified"}];
    
    /*
     *  Setup Comments Mappings
     */
    RKObjectMapping *commentMapping = [RKObjectMapping mappingForClass:[RCComment class]];
    [commentMapping addAttributeMappingsFromDictionary:@{@"id":@"commentId",
                                                         @"text":@"text",
                                                         @"commenter":@"commenter",
                                                         @"created":@"created",
                                                         @"modified":@"modified"}];
    
    /*
     Setup Sessions and Crowds relationships
     */
    // session.crowd mapping
    RKRelationshipMapping *sessionCrowdRelationshipMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"crowd" toKeyPath:@"crowd" withMapping:crowdMapping];
    [sessionMapping addPropertyMapping:sessionCrowdRelationshipMapping];
    
    // crowd.members mapping
    RKRelationshipMapping *crowdMembersRelationshipMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"members" toKeyPath:@"members" withMapping:profileMapping];
    [crowdMapping addPropertyMapping:crowdMembersRelationshipMapping];
    
    /*
     *  Session and Comments Mappings
     */
    RKRelationshipMapping *sessionCommentsRelationshipMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"comments" toKeyPath:@"comments" withMapping:commentMapping];
    [sessionMapping addPropertyMapping:sessionCommentsRelationshipMapping];
    
    /*
     Setup access token mapping
     */
    RKObjectMapping *accessTokenMapping = [RKObjectMapping mappingForClass:[RCAccessToken class]];
    [accessTokenMapping addAttributeMappingsFromDictionary:@{@"token":@"accessToken"}];
    
    /*
     *  Setup Likes mapping
     */
    RKObjectMapping *likeMapping = [RKObjectMapping mappingForClass:[RCLike class]];
    [likeMapping addAttributeMappingsFromDictionary:@{
                                                      @"id":@"likeId",
                                                      @"created":@"created",
                                                      @"modifed":@"modifed"
                                                      }];
                                                         
    RKRelationshipMapping *likeSessionRelationshipMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"session" toKeyPath:@"session" withMapping:sessionMapping];
    [likeMapping addPropertyMapping:likeSessionRelationshipMapping];
    
    
    /*
     *  Clip Mapping
     */
    NSDictionary *clipMappingDict = @{@"url": @"url",
                                             @"creator": @"creator",
                                             @"session": @"session",
                                             @"created": @"created",
                                             @"modified": @"modified",
                                             @"clip_number": @"clipNumber"};
    
    RKObjectMapping *clipMapping = [RKObjectMapping mappingForClass:[RCClip class]];
    [clipMapping addAttributeMappingsFromDictionary:clipMappingDict];
    
//    RKObjectMapping *clipRequestMapping = [RKObjectMapping mappingForClass:[RKObjectMapping requestMapping]];
//    [clipRequestMapping addAttributeMappingsFromDictionary:clipMappingDict];
    
    
    /*
     *  Error Message Mapping
     */
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:@"error_description" toKeyPath:@"errorMessage"]];
    RKResponseDescriptor *errorDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping
                                                                                         method:RKRequestMethodAny
                                                                                    pathPattern:nil
                                                                                        keyPath:nil
                                                                                    statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
    
    
    // Register out mapping with the provider using a response descriptor
    
    // Mapping Descriptor for /users/ endpoint
    RKResponseDescriptor *usersResponseDescriptor = [RKResponseDescriptor
                                                     responseDescriptorWithMapping:profileMapping
                                                     method:RKRequestMethodGET
                                                     pathPattern:@"/users/"                                                     keyPath:nil
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *sessionsResponseDescriptor = [RKResponseDescriptor
                                                        responseDescriptorWithMapping:sessionMapping
                                                        method:RKRequestMethodGET
                                                        pathPattern:@"/sessions/"
                                                        keyPath:@"sessions"
                                                        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *obtainTokenDescriptor = [RKResponseDescriptor
                                                   responseDescriptorWithMapping:
                                                   accessTokenMapping
                                                   method:RKRequestMethodPOST
                                                   pathPattern:@"/users/obtain-token/"
                                                   keyPath:nil
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *registerUserDescriptor = [RKResponseDescriptor
                                                    responseDescriptorWithMapping:profileMapping
                                                    method:RKRequestMethodPOST
                                                    pathPattern:@"/users/"
                                                    keyPath:nil
                                                    statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

    RKResponseDescriptor *getMyProfileDescriptor = [RKResponseDescriptor
                                                    responseDescriptorWithMapping:profileMapping
                                                    method:RKRequestMethodGET
                                                    pathPattern:@"/users/me/"
                                                    keyPath:nil
                                                    statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *getFriendsDescriptor = [RKResponseDescriptor
                                                  responseDescriptorWithMapping:profileMapping
                                                  method:RKRequestMethodGET
                                                  pathPattern:@"/users/friends/"
                                                  keyPath:@"friends"
                                                  statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

    RKResponseDescriptor *getCrowdsDescriptor = [RKResponseDescriptor
                                                 responseDescriptorWithMapping:crowdMapping
                                                 method:RKRequestMethodGET
                                                 pathPattern:@"/crowds/"
                                                 keyPath:@"crowds"
                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *getLikesDescriptor = [RKResponseDescriptor
                                                responseDescriptorWithMapping:likeMapping
                                                method:RKRequestMethodGET
                                                pathPattern:@"/users/me/likes/"
                                                keyPath:@"likes"
                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *postLikesDescriptor = [RKResponseDescriptor
                                                responseDescriptorWithMapping:likeMapping
                                                method:RKRequestMethodPOST
                                                pathPattern:@"/users/me/likes/"
                                                keyPath:@"like"
                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

    RKResponseDescriptor *getCommentsDescriptor = [RKResponseDescriptor
                                                   responseDescriptorWithMapping:commentMapping
                                                   method:RKRequestMethodGET
                                                   pathPattern:@"/sessions/:sessionId/comments/"
                                                   keyPath:@"comments"
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

    RKResponseDescriptor *postNewCommentDescriptor = [RKResponseDescriptor
                                                     responseDescriptorWithMapping:commentMapping
                                                     method:RKRequestMethodPOST
                                                     pathPattern:@"/sessions/:sessionId/comments/"
                                                     keyPath:@"comment"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *addClipDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:clipMapping
                                                                                           method:RKRequestMethodPOST
                                                                                      pathPattern:@"/sessions/:sessionId/clips/"
                                                                                          keyPath:nil
                                                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
#pragma mark Request Descriptors
    
    
    RKRequestDescriptor *addClipRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[clipMapping inverseMapping]
                                                                                          objectClass:[RCClip class]
                                                                                          rootKeyPath:nil
                                                                                               method:RKRequestMethodPOST];

//    RKResponseDescriptor *postLikesDescriptorNoKeypath = [RKResponseDescriptor
//                                                 responseDescriptorWithMapping:likeMapping
//                                                 method:RKRequestMethodPOST
//                                                 pathPattern:@"/users/me/likes/"
//                                                 keyPath:nil
//                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
#pragma mark Register Descriptors
    NSArray *responseDescriptorArray = @[usersResponseDescriptor, sessionsResponseDescriptor, obtainTokenDescriptor, registerUserDescriptor, getMyProfileDescriptor, getFriendsDescriptor, getCrowdsDescriptor, getLikesDescriptor, postLikesDescriptor, getCommentsDescriptor, postNewCommentDescriptor, errorDescriptor, addClipDescriptor];
    [objectManager addResponseDescriptorsFromArray:responseDescriptorArray];
    
    NSArray *requestDescriptorArray = @[addClipRequestDescriptor];
    [objectManager addRequestDescriptorsFromArray:requestDescriptorArray];
    
}



@end
