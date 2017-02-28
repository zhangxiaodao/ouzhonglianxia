//
//  XinFengKongJingViewController.m
//  联侠
//
//  Created by 杭州阿尔法特 on 16/10/10.
//  Copyright © 2016年 张海昌. All rights reserved.
//

#import "XinFengViewController.h"
#import "XinFengFirstTableViewCell.h"
#include "XinFengSecondTableViewCell.h"
#import "XinFengThirtTableViewCell.h"
#import "XinFengForthTableViewCell.h"
#import "XinFengFifthTableViewCell.h"
#import "LoginViewController.h"
#import "AllTypeServiceViewController.h"
#import "ConnectWeViewController.h"
#import "MineSerivesViewController.h"
#import "XinFengTimeViewController.h"


#define kBtnW ((kScreenW + 4) / 4)
@interface XinFengViewController ()<UITableViewDelegate , UITableViewDataSource , HelpFunctionDelegate , XinFengTimeVCSendTimeToParentVCDelegate>
@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , strong) UIView *navView;
@property (nonatomic , strong) UIButton *bottomBtn;
@property (nonatomic , strong) UIView *markView;

@property (nonatomic , strong) ServicesModel *serviceModel;
@property (nonatomic , strong) StateModel *stateModel;
@property (nonatomic , strong) ServicesDataModel *serviceDataModel;
@property (nonatomic , strong) UserModel *userModel;
@property (nonatomic , strong) NSMutableDictionary *dic;
@end

@implementation XinFengViewController

- (NSMutableDictionary *)dic {
    if (!_dic) {
        _dic = [NSMutableDictionary dictionary];
    }
    return _dic;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];

//    NSLog(@"%@" , [NSString sendXinFengNowTime]);
    
    [kStanderDefault setObject:@"YES" forKey:@"Login"];
    NSDictionary *parames = @{@"loginName" : [kStanderDefault objectForKey:@"phone"] , @"password" : [kStanderDefault objectForKey:@"password"] , @"ua.clientId" : [kStanderDefault objectForKey:@"GeTuiClientId"], @"ua.phoneType" : @(2)};
    [HelpFunction requestDataWithUrlString:kLogin andParames:parames andDelegate:self];
    
    [self setUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.serviceModel.devSn.length > 0 && self.serviceModel.devTypeSn.length != 0) {
        
        [kSocketTCP sendDataToHost:[NSString stringWithFormat:@"HM%ld%@%@N#" , self.userModel.sn , self.serviceModel.devTypeSn , self.serviceModel.devSn] andType:kAddService andIsNewOrOld:nil];
    }
}


#pragma mark - 获取代理的数据
- (void)requestData:(HelpFunction *)request didFinishLoadingDtaArray:(NSMutableArray *)data {
    NSDictionary *dic = data[0];
//    NSLog(@"%@" , dic);
    if ([dic[@"state"] integerValue] == 0) {
        
        NSDictionary *user = dic[@"data"];
        
        [kStanderDefault setObject:user[@"sn"] forKey:@"userSn"];
        [kStanderDefault setObject:user[@"id"] forKey:@"userId"];
        
        _userModel = [[UserModel alloc]init];
        for (NSString *key in [user allKeys]) {
            [_userModel setValue:user[key] forKey:key];
        }
        
//        kSocketTCP.userSn = [NSString stringWithFormat:@"%ld" , _userModel.sn];
//        [kSocketTCP socketConnectHost];
        
        [kApplicate initLastViewController:self];
        [kApplicate initUserModel:_userModel];
        [HelpFunction requestDataWithUrlString:kQueryTheUserdevice andParames:@{@"userSn" : @(_userModel.sn)} andDelegate:self];
    }
}


- (void)requestData:(HelpFunction *)requset queryUserdevice:(NSDictionary *)dddd {
    
//    NSLog(@"%@" , dddd);
    
    NSInteger state = [dddd[@"state"] integerValue];
    if (state == 0) {
        NSMutableArray *dataArray = dddd[@"data"];
        
        if (dataArray.count > 0) {
            [self.serviceArray removeAllObjects];
            [dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDictionary *dic = obj;
                ServicesModel *serviceModel = [[ServicesModel alloc]init];
                [serviceModel setValuesForKeysWithDictionary:dic];
                
                serviceModel.userDeviceID = [dic[@"id"] integerValue];
                
                
                [self.serviceArray addObject:serviceModel];
            }];
            
            if (_indexPath) {
                self.serviceModel = [[ServicesModel alloc]init];
                self.serviceModel = self.serviceArray[_indexPath.row];
            }
            
            [kStanderDefault setObject:@"YES" forKey:@"isHaveService"];
            
//            kSocketTCP.serviceModel = self.serviceModel;
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [kSocketTCP sendDataToHost:[NSString stringWithFormat:@"HM%ld%@%@N#" , self.userModel.sn , _serviceModel.devTypeSn , _serviceModel.devSn] andType:kAddService andIsNewOrOld:nil];
//                [self sendXinFengNowTime];
//            });
            
            [self sendXinFengNowTime];
            
            
            [kStanderDefault setObject:@(self.userModel.sn) forKey:@"userSn"];
            [kStanderDefault setObject:@(self.userModel.idd) forKey:@"userId"];
            
            [kApplicate initServiceModel:self.serviceModel];
            
            if ([self.serviceModel.devTypeSn isEqualToString:@"4232"]) {
                [self requestServiceData];
                [self requestServiceState];
            
            }
        } else {
            AllTypeServiceViewController *allServicesVC = [[AllTypeServiceViewController alloc]init];
            [self.navigationController pushViewController:allServicesVC animated:YES];
        }
    } else {
        AllTypeServiceViewController *addServiceVC = [[AllTypeServiceViewController alloc]init];
        [self.navigationController pushViewController:addServiceVC animated:YES];
    }
}

- (void)requestServiceState {
    NSDictionary *parames = @{@"devSn" : self.serviceModel.devSn , @"devTypeSn" : self.serviceModel.devTypeSn};
    [HelpFunction requestDataWithUrlString:kChaXunKongJingDangQianZhuangTai andParames:parames andDelegate:self];
}

- (void)requestServiceData {
    NSDictionary *parames = @{@"devSn" : self.serviceModel.devSn , @"devTypeSn" : self.serviceModel.devTypeSn};
    [HelpFunction requestDataWithUrlString:kChaXunKongJingDangQianShuJu andParames:parames andDelegate:self];
}

- (void)sendXinFengNowTime {
    
    NSString *nowTime = [NSString getNowTimeString];
    nowTime = [nowTime substringWithRange:NSMakeRange(11, 5)];
    
    NSString *hourTime = [nowTime substringWithRange:NSMakeRange(0, 2)];
    NSString *minuteTime = [nowTime substringWithRange:NSMakeRange(3, 2)];
    
    NSString *hourHex = [[NSString ToHex:hourTime.integerValue] substringFromIndex:2];
    NSString *minuteHex = [[NSString ToHex:minuteTime.integerValue] substringFromIndex:2];
    
    [kSocketTCP sendDataToHost:XinFengKongJingSetTime(self.serviceModel.devTypeSn, self.serviceModel.devSn , hourHex , minuteHex) andType:kZhiLing andIsNewOrOld:kNew];
}

#pragma mark - 获取设备的数据
- (void)requestServicesData:(HelpFunction *)request didOK:(NSDictionary *)dic{
//    NSLog(@"%@" , dic);
    if ([dic[@"data"] isKindOfClass:[NSDictionary class]]) {
        self.serviceDataModel = [[ServicesDataModel alloc]init];
        [self.serviceDataModel setValuesForKeysWithDictionary:dic[@"data"]];
        [self.tableView reloadData];
    }
}

#pragma mark - 获取设备的状态
- (void)requestData:(HelpFunction *)request didSuccess:(NSDictionary *)dddd{
//    NSLog(@"%@" , dddd);
    if ([dddd[@"data"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dataDic = dddd[@"data"];
        
        self.stateModel = [[StateModel alloc]init];
        
        for (NSString *key in [dataDic allKeys]) {
            [self.stateModel setValue:dataDic[key] forKey:key];
        }
        
        if ([self.serviceModel.devTypeSn isEqualToString:@"4232"]) {
            if (self.stateModel.fSwitch == 2  || self.stateModel.fSwitch == 0) {
                self.bottomBtn.backgroundColor = [UIColor grayColor];
                self.bottomBtn.selected = 0;
                [self.bottomBtn addTarget:self action:@selector(xinFengOpenAtcion:) forControlEvents:UIControlEventTouchUpInside];
            } else if (self.stateModel.fSwitch == 1){
                
                [UIView animateWithDuration:0.3 animations:^{
                    _markView.alpha = 0;
                }];
                self.bottomBtn.backgroundColor = kXinFengKongJingYanSe;
                self.bottomBtn.selected = 1;
                [self.bottomBtn addTarget:self action:@selector(xinFengCloseAtcion:) forControlEvents:UIControlEventTouchUpInside];
                
            }
            
        }
        
        [self.tableView reloadData];
        
    } else {
        
        if ([self.serviceModel.devTypeSn isEqualToString:@"4232"]) {
            
            self.bottomBtn.backgroundColor = [UIColor grayColor];
            [self.bottomBtn addTarget:self action:@selector(xinFengOpenAtcion:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
}

#pragma mark - 按钮开点击事件
- (void)xinFengOpenAtcion:(UIButton *)btn {
    
    [kSocketTCP sendDataToHost:XinFengKongJing(self.serviceModel.devTypeSn, self.serviceModel.devSn, @"01", @"00", @"00", @"00" , @"00") andType:kZhiLing andIsNewOrOld:kNew];
    
    NSLog(@"%@" , XinFengKongJing(self.serviceModel.devTypeSn, self.serviceModel.devSn, @"01", @"00", @"00", @"00" , @"00"));
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getXinFengKongJing:) name:@"4232" object:nil];
}

#pragma mark - 按钮关点击事件
- (void)xinFengCloseAtcion:(UIButton *)btn {
    
    [kSocketTCP sendDataToHost:XinFengKongJing(self.serviceModel.devTypeSn, self.serviceModel.devSn, @"02", @"00", @"00", @"00" , @"00") andType:kZhiLing andIsNewOrOld:kNew];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getXinFengKongJing:) name:@"4232" object:nil];
    
}

#pragma mark - 获取TCP命令
- (void)getXinFengKongJing:(NSNotification *)post {
    NSString *str = post.userInfo[@"Message"];
    
    NSString *kaiGuan = [str substringWithRange:NSMakeRange(28, 2)];
    NSString *devSn = [str substringWithRange:NSMakeRange(14, 12)];
    
    if ([self.serviceModel.devSn isEqualToString:devSn]) {
        if ([kaiGuan isEqualToString:@"02"]) {
            
            self.bottomBtn.selected = 0;
            
            [UIView animateWithDuration:0.3 animations:^{
                _markView.alpha = 0.3;
            }];
            [self.bottomBtn removeTarget:self action:@selector(xinFengCloseAtcion:) forControlEvents:UIControlEventTouchUpInside];
            self.bottomBtn.backgroundColor = [UIColor grayColor];
            [self.bottomBtn addTarget:self action:@selector(xinFengOpenAtcion:) forControlEvents:UIControlEventTouchUpInside];
        } else if ([kaiGuan isEqualToString:@"01"]) {
            
            self.bottomBtn.selected = 1;
            
            [UIView animateWithDuration:0.3 animations:^{
                _markView.alpha = 0;
            }];
            
            [self.bottomBtn removeTarget:self action:@selector(xinFengOpenAtcion:) forControlEvents:UIControlEventTouchUpInside];
            self.bottomBtn.backgroundColor = kXinFengKongJingYanSe;
            [self.bottomBtn addTarget:self action:@selector(xinFengCloseAtcion:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"BottomBtnSelected" object:nil userInfo:@{@"BottomBtnSelected" : @(self.bottomBtn.selected)}]];
        
    }
}

- (void)getXinFengModelIsOpen:(NSNotification *)post {

    NSString *section = [NSString stringWithFormat:@"%d" , 1];
    
    if ([self.dic[section] integerValue] == 0) {
        [self.dic setValue:@(1) forKey:section];
    } else{
        [self.dic setValue:@(0) forKey:section];
    }
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:1];
    [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationFade];
    
    
    if ([self.dic[section] isEqual:@(1)]) {
        NSIndexPath *scrollIndexpath = [NSIndexPath indexPathForRow:0 inSection:1];
        [self.tableView scrollToRowAtIndexPath:scrollIndexpath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }

    
//    if ([isOpen isEqualToString:@"YES"]) {
//
//    } else if ([isOpen isEqualToString:@"NO"]) {
//        
//    }
}

#pragma mark - 布局
- (void)setUI {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getXinFengKongJing:) name:@"4232" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getXinFengModelIsOpen:) name:@"XinFengModelOpen" object:nil];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH ) style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = kACOLOR(28, 157, 247, 1.0);
//    self.tableView.backgroundColor = [UIColor grayColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    for (int i = 1; i < 5; i++) {
        [self.dic setValue:@(0) forKey:[NSString stringWithFormat:@"%d" , i]];
    }
    
    UIView *bottomView = [[UIView alloc]init];
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(kScreenW, kScreenH / 12.3518518));
        make.right.mas_equalTo(self.view.mas_right);
    }];
    bottomView.backgroundColor = [UIColor whiteColor];
    
    self.bottomBtn = [UIButton initWithTitle:@"" andColor:[UIColor grayColor] andSuperView:self.view];
    self.bottomBtn.layer.cornerRadius = kScreenW / 18;
    //注册按钮的约束
    [self.bottomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenW - kScreenW * 2 / 15, kScreenW / 9));
        make.left.mas_equalTo(kScreenW / 15);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-5);
    }];
    [self.bottomBtn addTarget:self action:@selector(xinFengOpenAtcion:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *bottomLable = [UILabel creatLableWithTitle:@"开启" andSuperView:self.bottomBtn andFont:k17 andTextAligment:NSTextAlignmentLeft];
    bottomLable.textColor = [UIColor whiteColor];
    bottomLable.layer.borderWidth = 0;
    [bottomLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(self.bottomBtn.height / 2, self.bottomBtn.height / 2));
        make.left.mas_equalTo(self.bottomBtn.mas_centerX).offset(3);
        make.centerY.mas_equalTo(self.bottomBtn.mas_centerY);
    }];
    
    UIImageView *offImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"iconfont-kaiguan222"]];
    offImageView.image = [offImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    offImageView.tintColor = [UIColor whiteColor];
    [self.bottomBtn addSubview:offImageView];
    [offImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(self.bottomBtn.height / 4, self.bottomBtn.height / 4));
        make.right.mas_equalTo(self.bottomBtn.mas_centerX).offset(-3);
        make.centerY.mas_equalTo(self.bottomBtn.mas_centerY);
    }];
    
    _markView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH - kScreenH / 12.3518518 )];
    [self.view addSubview:_markView];
    [UIView animateWithDuration:0.3 animations:^{
        _markView.alpha = 0.3;
    }];
    _markView.backgroundColor = [UIColor blackColor];
    
    
    self.navView = [UIView creatNavView:self.view WithTarget:self action:@selector(xinFengBackAtcion:)  andTitle:@"新风智能空气净化器"];
    
    UIView *backView = [self.navView.subviews objectAtIndex:0];
    UIImageView *backImageView = [backView.subviews objectAtIndex:1];
    backImageView.image = [UIImage imageNamed:@"iconfont-fanhui"];
    
    UIImageView *gengDuoImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"gengDuo"]];
    [self.navView addSubview:gengDuoImageView];
    gengDuoImageView.userInteractionEnabled = YES;
    [UIImageView setImageViewColor:gengDuoImageView andColor:[UIColor whiteColor]];
    [gengDuoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenW / 20, kScreenW / 20));
        make.centerY.mas_equalTo(self.navView.mas_centerY);
        make.right.mas_equalTo(self.navView.mas_right).offset(- kScreenW / 20);
    }];
    
    UITapGestureRecognizer *gengDuoTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gengDuoTapAtcion:)];
    [gengDuoImageView addGestureRecognizer:gengDuoTap];
    [UIImageView setImageViewColor:backImageView andColor:[UIColor whiteColor]];
    
    UILabel *lable = [self.navView.subviews objectAtIndex:2];
    lable.textColor = [UIColor whiteColor];
    lable.font = [UIFont systemFontOfSize:k17];
    
}


#pragma mark - 移除设备
- (void)requestRemoveService:(HelpFunction *)request didDone:(NSDictionary *)dic{
//    NSLog(@"%@" , dic);
    
    if ([dic[@"state"] integerValue] == 0) {
        
        
        [UIAlertController creatRightAlertControllerWithHandle:^{
            
            if (self.serviceArray.count == 1) {
                AllTypeServiceViewController *allTypeServiceVC = [[AllTypeServiceViewController alloc]init];
                [self.navigationController pushViewController:allTypeServiceVC animated:YES];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        } andSuperViewController:self Title:@"设备删除成功"];
    }
}


#pragma mark - 右上角点击事件
- (void)gengDuoTapAtcion:(UITapGestureRecognizer *)tap {
    
    [UIAlertController creatSheetControllerWithFirstHandle:^{
        NSDictionary *parames = @{@"id" : @(self.serviceModel.userDeviceID)};
//        NSLog(@"%@" , parames);
        
        [HelpFunction requestDataWithUrlString:kDeleteServiceURL andParames:parames andDelegate:self];
    } andFirstTitle:@"移除设备" andSecondHandle:^{
        ConnectWeViewController *connectOueVC = [[ConnectWeViewController alloc]init];
        [self.navigationController pushViewController:connectOueVC animated:YES];
    } andSecondTitle:@"联系我们" andThirtHandle:^{
        AllTypeServiceViewController *allServicesVC = [[AllTypeServiceViewController alloc]init];
        allServicesVC.fromAboutVC = @"YES";
        [self.navigationController pushViewController:allServicesVC animated:YES];
    } andThirtTitle:@"使用帮助" andForthHandle:nil andForthTitle:nil andSuperViewController:self];
}

#pragma mark - 左上角返回点击事件
- (void)xinFengBackAtcion:(UITapGestureRecognizer *)tap{

    [self.navigationController popViewControllerAnimated:YES];
    
    if (self.serviceModel) {
        if (_sendServiceModelToParentVCDelegate && [_sendServiceModelToParentVCDelegate respondsToSelector:@selector(sendServiceModelToParentVC:)]) {
            [_sendServiceModelToParentVCDelegate sendServiceModelToParentVC:self.serviceModel];
        }
    }
    
}

#pragma mark - tableView的代理
#pragma mark - 分区的个数



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0) {
        return 2;
    } else if (section == 1){
        NSString *key = [NSString stringWithFormat:@"%ld" , (long)section];
        if ([self.dic[key] integerValue] == 1) {
            return 1;
        }
        return 0;
        
    } else {
        return 2;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            static NSString *celled = @"first";
            XinFengFirstTableViewCell *cell
            =[tableView dequeueReusableCellWithIdentifier:celled];
            if (!cell) {
                cell = [[XinFengFirstTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:celled];
            }
            
            cell.serviceDataModel = self.serviceDataModel;
            cell.stateModel = self.stateModel;
            return cell;
        } else {
            static NSString *celled = @"second";
            XinFengSecondTableViewCell *cell
            =[tableView dequeueReusableCellWithIdentifier:celled];
            if (!cell) {
                cell = [[XinFengSecondTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:celled];
            }
            cell.serviceModel = self.serviceModel;
            cell.stateModel = self.stateModel;
            return cell;
        }
    } else if (indexPath.section == 1) {
        static NSString *celled = @"Thirt";
        XinFengThirtTableViewCell *cell
        =[tableView dequeueReusableCellWithIdentifier:celled];
        if (!cell) {
            cell = [[XinFengThirtTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:celled];
        }
        
        cell.serviceModel = self.serviceModel;
        return cell;
    } else {
        
        if (indexPath.row == 0) {
            static NSString *celled = @"fifth";
            XinFengFifthTableViewCell *cell
            =[tableView dequeueReusableCellWithIdentifier:celled];
            if (!cell) {
                cell = [[XinFengFifthTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:celled];
            }
            
            cell.servicModel = self.serviceModel;
            return cell;
        } else  {
            static NSString *celled = @"forth";
            XinFengForthTableViewCell *cell
            =[tableView dequeueReusableCellWithIdentifier:celled];
            if (!cell) {
                cell = [[XinFengForthTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:celled];
            }
            
            cell.liearColor = kXinFengKongJingYanSe;
            cell.chaXunLishiJiLu = kKongJingLiShiJiLu;
            cell.serviceModel = self.serviceModel;
            return cell;
        }
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return kScreenH / 1.56 + kScreenW / 10 - kScreenW / 25 + 5;
        } else {
            return kBtnW * 9 / 4;
        }
        
    } else if (indexPath.section == 1) {
        return kBtnW * 3 / 2;
    } else {
        if(indexPath.row == 0){
            return kScreenH / 7;
        } else {
            return kScreenH / 2.9 ;
        }
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row == 0 && indexPath.section == 2) {
        XinFengTimeViewController *xinFengTimeVC = [[XinFengTimeViewController alloc]init];
        xinFengTimeVC.serviceModel = self.serviceModel;
        xinFengTimeVC.delegate = self;
        [self.navigationController pushViewController:xinFengTimeVC animated:YES];
    }
    
}

- (void)xinFengTimeVCSendTimeToParentVCDelegate:(NSArray *)array {
    NSLog(@"%@" , array);
    
    NSString *time = nil;
    NSInteger openTime = [array[0] integerValue];
    NSInteger closeTime = [array[1] integerValue];
    NSInteger openOn = [array[2] integerValue];
    NSInteger closeOn = [array[3] integerValue];
    NSInteger nowTime = [NSString getNowTimeInterval];
    
    if (openOn == 1 && closeOn == 0) {
        if (nowTime > openTime) {
            [kStanderDefault removeObjectForKey:@"XinFengTime"];
        } else {
            NSInteger timeDifference = openTime - nowTime;
            time = [NSString stringWithFormat:@"将于%ld分钟后开启" , timeDifference / 60];
        }
    }  if (openOn == 0 && closeOn == 1) {
        if (nowTime > closeTime) {
            [kStanderDefault removeObjectForKey:@"XinFengTime"];
        } else {
            NSInteger timeDifference = closeTime - nowTime;
            time = [NSString stringWithFormat:@"将于%ld分钟后关闭" , timeDifference / 60];
        }
    }  if (openOn == 1 && closeOn == 1) {
        if (openTime > closeTime) {
            NSInteger timeDifference = closeTime - nowTime;
            NSInteger openTimeHourAndMinute = openTime - nowTime;
            time = [NSString stringWithFormat:@"于%ld分钟后关,于%ld分钟后开" , timeDifference / 60 , openTimeHourAndMinute / 60];
        } else if (closeTime > openTime) {
            NSInteger timeDifference = closeTime - nowTime;
            NSInteger openTimeHourAndMinute = openTime - nowTime;
            time = [NSString stringWithFormat:@"于%ld分钟后开,于%ld分钟后关" , openTimeHourAndMinute / 60 , timeDifference / 60];
        }
    }
    
    XinFengFifthTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    if (time) {
        cell.shuoMingLabel.text = time;
    }
}

@end
