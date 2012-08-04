//
//  DNSSpoofer.m
//  ResolverConfig
//
//  Created by John Ewart on 8/3/12.
//  Copyright (c) 2012 John Ewart. All rights reserved.
//

#import "DNSSpoofer.h"

@implementation DNSSpoofer

void respond(char *msg, char *response, uint32_t *spoofaddr, int numbytes)
{
	// Pointer to domain name
	char *ptr = "\xc0\x0c";
	// Response type, TTL, resource data length (4)
	char *rspdata = "\x00\x01\x00\x01\x00\x00\x00\x3c\x00\x04";
	
	int datalen = numbytes - 12;
	
	memcpy(response, msg, 2); 			// QID
	memcpy(response+2, "\x81\x80", 2); 	// QR, Opcode, address type, rcode...
	memcpy(response+4, msg+4, 2);		// QDCOUNT
	memcpy(response+6, msg+4, 2);		// ANCOUNT
	memset(response+8, 0, 4);			// NSCOUNT, ARCOUNT (all 0s)
	memcpy(response+12, msg+12, datalen);  // Original query data
	
	int off = numbytes;
	
	// Copy in pointer to domain
	memcpy(response+off, ptr, 2);
	off += 2;
    
	// Copy in TTL, type, etc.
	memcpy(response+off, rspdata, 10);
	off += 10;
    
	// Copy in uint32 IP address to return
	memcpy(response+off, spoofaddr, 4);
	off += 4;
	
}

-(void) respondWithAddr:(NSString *)ipaddr
{
	int sockfd, n;
 	socklen_t len;
	char mesg[1024];
	struct sockaddr_in servaddr, cliaddr;
	uint32_t myaddr = inet_addr([ipaddr UTF8String]);
    
	sockfd=socket(AF_INET,SOCK_DGRAM,0);
    
	bzero(&servaddr, sizeof(servaddr));
	servaddr.sin_family = AF_INET;
	servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
	servaddr.sin_port = htons(31337);
	bind(sockfd, (struct sockaddr *)&servaddr, sizeof(servaddr));
	
   	for (;;)
   	{
        
      	len = sizeof(cliaddr);
      	n = recvfrom(sockfd, mesg, 1024, 0, (struct sockaddr *)&cliaddr, &len);
        
  		mesg[n] = 0;
		
		char resp[n+16];
		int m = n + 16;
		
		// Compute response packet and return it to the client
		respond(&mesg[0], &resp[0], &myaddr, n);
        
		sendto(sockfd, resp, m, 0, (struct sockaddr *)&cliaddr, sizeof(cliaddr));
        
    }
}

@end
