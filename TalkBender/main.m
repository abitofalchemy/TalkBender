//
//  main.m
//  TalkBender
//
//  Created by Salvador Aguinaga on 12/10/14.
//  Copyright (c) 2014 abitofalchemy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#define DBG 0
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
