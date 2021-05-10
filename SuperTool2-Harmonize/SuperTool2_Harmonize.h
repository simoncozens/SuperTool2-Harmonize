//
//  SuperTool2_Harmonize.h
//  SuperTool2-Harmonize
//
//  Created by Simon Cozens on 10/05/2021.
//
//

#import <Cocoa/Cocoa.h>
#import <GlyphsCore/GSFilterPlugin.h>

@interface SuperTool2_Harmonize : GSFilterPlugin {
	CGFloat _firstValue;
	NSTextField * __unsafe_unretained _firstValueField;
}
@property (nonatomic, assign) IBOutlet NSTextField* firstValueField;
@end
