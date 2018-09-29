//
//  DrawManager.h
//  xoxsrc
//
//  Created by C.W. Betts on 9/28/18.
//  Copyright © 2018 C.W. Betts. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DrawManager <NSObject>
- (void)oneStep;
- (void)erase:(NSRect)r;
- (void)displayRect:(NSRect)r;

@end

NS_ASSUME_NONNULL_END
