//
//  Storage.h
//  MapView
//
//  Created by Roman Efimov on 10/5/12.
//  Copyright (c) 2012 Roman Efimov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Storage : NSObject

+ (void)saveArray:(NSArray *)array;
+ (NSArray *)restoreArray;

@end
