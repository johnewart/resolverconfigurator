//
//  DNSSpoofer.h
//  ResolverConfig
//
//  Created by John Ewart on 8/3/12.
//  Copyright (c) 2012 John Ewart. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <stdio.h>
#include <string.h>

@interface DNSSpoofer : NSObject

-(void) respondWithAddr:(NSString *)ipaddr;

@end
