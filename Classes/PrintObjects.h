//
//  PrintObjects.h
//  Note Safe
//
//  Created by Harrison White on 11/11/11.
//  Copyright (c) 2012 Harrison Apps, LLC 2011 Harrison Apps, LLC. All rights reserved.
//

#define kPrintedFontNameKey					@"Printed Font Name"
#define kPrintedFontSizeKey					@"Printed Font Size"
#define kPrintedTextColorRedRGBValueKey		@"Printed Text Color Red RGB Value"
#define kPrintedTextColorGreenRGBValueKey	@"Printed Text Color Green RGB Value"
#define kPrintedTextColorBlueRGBValueKey	@"Printed Text Color Blue RGB Value"
#define kTopPrintMarginSizeKey				@"Top Print Margin Size"
#define kLeftPrintMarginSizeKey				@"Left Print Margin Size"
#define kRightPrintMarginSizeKey			@"Right Print Margin Size"

#define kPrintOrientationKey				@"Print Orientation Selected Row"
#define kPrintOrientationArray				[NSArray arrayWithObjects:@"Portrait", @"Landscape", nil]
#define PRINT_ORIENTATION_PORTRAIT_INDEX	0
#define PRINT_ORIENTATION_LANDSCAPE_INDEX	1

#define kPrintTextAlignmentKey				@"Printed Text Alignment Selected Row"
#define kMainPrintTextAlignmentArray		[NSArray arrayWithObjects:@"Left", @"Centered", @"Right", nil]
#define kDetailPrintTextAlignmentArray		[NSArray arrayWithObjects:@"Left Justified", @"Centered", @"Right Justified", nil]
#define PRINT_TEXT_ALIGNMENT_LEFT_INDEX		0
#define PRINT_TEXT_ALIGNMENT_CENTER_INDEX	1
#define PRINT_TEXT_ALIGNMENT_RIGHT_INDEX	2

#define kPrintDuplexKey						@"Print Duplex Selected Row"
#define kPrintDuplexArray					[NSArray arrayWithObjects:@"None", @"Short Edge", @"Long Edge", nil]
#define PRINT_DUPLEX_LONG_EDGE_INDEX		0
#define PRINT_DUPLEX_SHORT_EDGE_INDEX		1
#define PRINT_DUPLEX_NONE_INDEX				2
