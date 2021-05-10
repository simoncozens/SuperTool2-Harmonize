//
//  GSNode+SCNodeUtils.m
//  SuperTool
//
//  Created by Simon Cozens on 21/05/2016.
//  Copyright © 2016 Simon Cozens. All rights reserved.
//

#import "GSNode+SCNodeUtils.h"

@implementation GSNode (SCNodeUtils)

- (GSNode*) nextNode {
    GSPath *p = [self parent];
    NSUInteger index = [p indexOfNode:self];
    return index == [p countOfNodes] ? [p nodeAtIndex:0] : [p nodeAtIndex: index+1];
}

- (GSNode*) prevNode {
    GSPath *p = [self parent];
    NSUInteger index = [p indexOfNode:self];
    return index == 0 ? [p nodeAtIndex:([p countOfNodes]-1)] : [p nodeAtIndex: index-1];
}


- (GSNode*)nextOnCurve {
    GSNode* nn = [self nextNode];
    if ([nn type] != OFFCURVE) return nn;
    nn = [nn nextNode];
    if ([nn type] != OFFCURVE) return nn;
    nn = [nn nextNode];
    return nn;
}

- (GSNode*)prevOnCurve {
    GSNode* nn = [self prevNode];
    if ([nn type] != OFFCURVE) return nn;
    nn = [nn prevNode];
    if ([nn type] != OFFCURVE) return nn;
    nn = [nn prevNode];
    return nn;
}

- (void) correct {
    if (self.type != CURVE || self.connection != SMOOTH) return;
    NSInteger index = [[self parent] indexOfNode:self];
    GSNode* rhandle = [[self parent] nodeAtIndex:index+1];
    GSNode* lhandle = [[self parent] nodeAtIndex:index-1];
//        CGFloat lHandleLen = GSDistance([n position], [lhandle position]);
    CGFloat rHandleLen = GSDistance([self position], [rhandle position]);
    // Average the two angles first
    NSPoint ua = GSUnitVectorFromTo([lhandle position], [self position]);
    NSPoint ub = GSUnitVectorFromTo([self position], [rhandle position]);
    NSPoint average = GSScalePoint(GSAddPoints(ua, ub),0.5);
    [rhandle setPosition:GSAddPoints([self position], GSScalePoint(average, rHandleLen))];
    //    if (f) {
    //        // Set rhandle
    //        NSPoint newPos = GSLerp([lhandle position], [self position], (lHandleLen+rHandleLen)/lHandleLen);
    //        [rhandle setPositionFast:newPos];
    //    } else {
    //        NSPoint newPos = GSLerp([rhandle position], [self position], (lHandleLen+rHandleLen)/rHandleLen);
    //        [lhandle setPositionFast:newPos];
    //
    //    }
}

@end
