//
//  CustomPickerView.h
//  联侠
//
//  Created by 杭州阿尔法特 on 2017/2/28.
//  Copyright © 2017年 张海昌. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CustomPickerView;
@protocol SendPickerViewSelectDataToParentView <NSObject>

- (void)sendPickerViewSelectedData:(NSArray *)dataArray;

@end

@interface CustomPickerView : UIView

+ (CustomPickerView *)shareCustomPickerView;

@property (nonatomic , strong) UIColor *backGroundColor;
@property (nonatomic , strong) NSArray *dataArray;

@property (nonatomic , assign) id<SendPickerViewSelectDataToParentView> delegate;

- (instancetype)initWithBackGroundColor:(UIColor *)backColor withFrame:(CGRect)frame;

- (void)initPickerDataWithDataArray:(NSArray *)dataArray;

@end
