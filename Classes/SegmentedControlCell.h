//
//  SegmentedControlCell.h
//  Note Safe
//
//  Created by Harrison White on 8/11/11.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SegmentedControlCellDelegate;

@interface SegmentedControlCell : UITableViewCell {
	id <SegmentedControlCellDelegate> delegate;
	UISegmentedControl *segmentedControl;
}

@property (nonatomic, assign) id <SegmentedControlCellDelegate> delegate;
@property (nonatomic, assign) UISegmentedControl *segmentedControl;

@end

@protocol SegmentedControlCellDelegate <NSObject>

@optional

- (void)segmentedControlCellValueChanged:(NSInteger)selectedIndex;

@end
