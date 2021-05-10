//
//  SuperTool2_Harmonize.m
//  SuperTool2-Harmonize
//
//  Created by Simon Cozens on 10/05/2021.
//
//

#import "SuperTool2_Harmonize.h"
#import <GlyphsCore/GSFont.h>
#import <GlyphsCore/GSFontMaster.h>
#import <GlyphsCore/GSGlyph.h>
#import <GlyphsCore/GSLayer.h>
#import <GlyphsCore/GSPath.h>
#import "GSNode+SCNodeUtils.h"

@implementation SuperTool2_Harmonize

- (NSUInteger) interfaceVersion {
	// Distinguishes the API verison the plugin was built for. Return 1.
	return 1;
}

- (NSString*) title {
	// Return the name of the tool as it will appear in the menu.
	return @"SuperTool - Harmonize";
}

- (NSString*) actionName {
	// The title of the button in the filter dialog.
	return @"SuperTool - Harmonize";
}

- (NSString*) keyEquivalent {
    return @"H";
}

- (void) setController:(NSViewController <GSGlyphEditViewControllerProtocol>*)Controller {
    // Use [self controller]; as object for the current view controller.
    controller = Controller;
}


- (BOOL)runFilterWithLayer:(GSLayer *)Layer options:(NSDictionary *)options error:(out NSError *__autoreleasing *)error {
    return [self runFilterWithLayer:Layer error:error];
}


- (BOOL)runFilterWithLayers:(NSArray *)Layers error:(out NSError *__autoreleasing *)error {
    return NO;

}


- (void) harmonize:(GSNode*)a3 {
    if (![a3 isKindOfClass:[GSNode class]]) return;
    if ([a3 connection] != SMOOTH) return;
    GSNode* a2 = [a3 prevNode]; if ([a2 type] != OFFCURVE) return;
    GSNode* a1 = [a2 prevNode]; if ([a1 type] != OFFCURVE) return;
    GSNode* b1 = [a3 nextNode]; if ([b1 type] != OFFCURVE) return;
    GSNode* b2 = [b1 nextNode]; if ([b2 type] != OFFCURVE) return;
    NSPoint d = GSIntersectLineLineUnlimited([a1 position],[a2 position],[b1 position],[b2 position]);
    CGFloat p0 = GSDistance([a1 position], [a2 position]) / GSDistance([a2 position], d);
    CGFloat p1 = GSDistance(d, [b1 position]) / GSDistance([b1 position], [b2 position]);
    CGFloat r = sqrtf(p0 * p1);
    if (r == INFINITY) return;
    CGFloat t = r / (r+1);
    NSPoint newA3 =GSLerp([a2 position],[b1 position],t);
    // One way to do this:
    //    [a3 setPosition:newA3];
    // But we want to keep the oncurve point, so
    NSPoint fixup = GSSubtractPoints([a3 position], newA3);
    [a2 setPosition:GSAddPoints([a2 position], fixup)];
    [b1 setPosition:GSAddPoints([b1 position], fixup)];
};


-(void) addNode:(GSNode*)n toSegmentSet:(NSMutableOrderedSet*) segments {
    // Find the segment for this node and add it to the set
    if ([n type] == OFFCURVE && [[n nextNode] type] == OFFCURVE) {
        // Add prev, this, next, and next next to the set
        NSArray* a = [NSArray arrayWithObjects:[n prevNode],n,[n nextNode],[[n nextNode] nextNode],nil];
        [segments addObject:a];
    } else if ([n type] == OFFCURVE && [[n prevNode] type] == OFFCURVE) {
        // Add prev prev, prev, this and next to the set
        NSArray* a = [NSArray arrayWithObjects:[[n prevNode] prevNode],[n prevNode],n,[n nextNode],nil];
        [segments addObject:a];
    }
}

-(void)balance:(GSLayer*)layer {
    NSMutableOrderedSet* segments = [[NSMutableOrderedSet alloc] init];
    for (GSPath* p in [layer paths]) {
        for (GSNode* n in [p nodes]) {
            [self addNode:n toSegmentSet:segments];
        }
    }
    NSArray* seg;
    for (seg in segments) {
        NSPoint p1 = [(GSNode*)seg[0] position];
        NSPoint p2 = [(GSNode*)seg[1] position];
        NSPoint p3 = [(GSNode*)seg[2] position];
        NSPoint p4 = [(GSNode*)seg[3] position];
        NSPoint t = GSIntersectLineLineUnlimited(p1,p2,p3,p4);
        CGFloat sDistance = GSDistance(p1,t);
        CGFloat eDistance = GSDistance(p4, t);
        if (sDistance <= 0 || eDistance <= 0) continue;
        CGFloat xPercent = GSDistance(p1,p2) / sDistance;
        CGFloat yPercent = GSDistance(p3,p4) / eDistance;
        if (xPercent > 1 && yPercent >1) continue; // Inflection point
        if (xPercent < 0.01 && yPercent <0.01) continue; // Inflection point
        CGFloat avg = (xPercent+yPercent)/2.0;
        NSPoint newP2 = GSLerp(p1, t, avg);
        NSPoint newP3 = GSLerp(p4, t, avg);
        [(GSNode*)seg[1] setPosition:newP2];
        [(GSNode*)seg[2] setPosition:newP3];
    }
}

- (BOOL)runFilterWithLayer:(GSLayer *)layer error:(out NSError **)error {
    [self balance:layer];
    GSNode* n;
    if ([[layer selection] count] >0) {
        for (n in [layer selection]) {
            [self harmonize:n];
        }
    } else {
        GSPath* p;
        for (p in layer.paths) {
            if (![p isKindOfClass:[GSPath class]]) continue;
            for (n in [p nodes]) {
                [self harmonize:n];
            }
        }
    }
    [self balance:layer];
    return YES;
}

- (NSError *)setup {
    return nil;
}


@synthesize controller;

@end
