//
//  RCUtility.m
//  Rapchat
//
//  Created by Michael Paris on 2/23/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCUtility.h"

@implementation RCUtility

+(BOOL)hasIphone5Screen
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            CGFloat scale = [UIScreen mainScreen].scale;
            result = CGSizeMake(result.width * scale, result.height * scale);
            
            if(result.height == 960){
                NSLog(@"iphone 4, 4s retina resolution");
                return NO;
                
                //CODE IF IPHONE 4
                
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                    //Code if iPhone 4 or 4s and iOS 7
                    NSLog(@"iPhone 4 iOS 7");
                }
            }
            if(result.height == 1136){
                NSLog(@"iphone 5 resolution");
                
                //CODE IF iPHONE 5
                return YES;
                
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                    //Code if iPhone 5 or 5s and iOS 7
                    NSLog(@"iPhone 5 iOS 7");
                }
            }
        }
    }
    return NO;
}

@end
