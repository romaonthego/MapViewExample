//
//  Storage.m
//  MapView
//
//  Created by Roman Efimov on 10/5/12.
//  Copyright (c) 2012 Roman Efimov. All rights reserved.
//

#import "Storage.h"

@implementation Storage

+ (void)saveArray:(NSArray *)array
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *arrayFileName = [documentsDirectory stringByAppendingPathComponent:@"searches.dat"];
    
    [NSKeyedArchiver archiveRootObject:array toFile:arrayFileName];
}

+ (NSArray *)restoreArray
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *arrayFileName = [documentsDirectory stringByAppendingPathComponent:@"searches.dat"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:arrayFileName]) return @[];
    
	NSArray *data = [NSKeyedUnarchiver unarchiveObjectWithFile:arrayFileName];
    return data;
}


@end
