//
//  HexDump.h
//  WhatCopied
//
//  Created by cyan on 2024/12/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Dump NSData as hex representation, implement in Objective-C as it is much faster than Swift.
 */
NSString *hexDump(NSData *data, NSUInteger bytesPerRow);

NS_ASSUME_NONNULL_END
