//
//  SliderCell.h
//  Note Safe
//
//  Created by Harrison White on 6/13/11.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SliderCellDelegate;

@interface SliderCell : UITableViewCell {
	id <SliderCellDelegate> delegate;
    UISlider *slider;
}

@property (nonatomic, assign) id <SliderCellDelegate> delegate;
@property (nonatomic, assign) UISlider *slider;

@end

@protocol SliderCellDelegate <NSObject>

@optional

- (void)sliderCell:(SliderCell *)cell valueChanged:(CGFloat)value;

@end
