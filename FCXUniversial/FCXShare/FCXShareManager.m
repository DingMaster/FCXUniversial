//
//  FCXShareManager.m
//  FCXUniversial
//
//  Created by 冯 传祥 on 16/3/29.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import "FCXShareManager.h"
#import "UMSocial.h"
#import "UMSocialQQHandler.h"
#import "WXApi.h"
#import <MessageUI/MessageUI.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "FCXDefine.h"

#define SHARE_TITLE_NORMALCOLOR UICOLOR_FROMRGB(0x343233)
#define SHARE_TITLE_HCOLOR UICOLOR_FROMRGB(0x818081)

@interface FCXShareManager () <UMSocialUIDelegate>
{
    UIView *_bottomView;
    CGFloat _bottomHeight;
    UIButton *_cancelButton;
    BOOL showAll;
}

@property (nonatomic, unsafe_unretained) FCXShareType shareType;

@end

@implementation FCXShareManager

+ (FCXShareManager *)sharedManager {
    static FCXShareManager *shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[FCXShareManager alloc] init];
    });
    return shareManager;
}

-(id)init
{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:.6];
        
        showAll = YES;
        [self judgeBottomHeight];

        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, _bottomHeight)];
        _bottomView.backgroundColor = [UIColor colorWithWhite:1 alpha:.9];
        _bottomView.backgroundColor = UICOLOR_FROMRGB(0xf0f0f0);
        [self addSubview:_bottomView];
        
        [self createShareButtons];
        
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.backgroundColor = UICOLOR_FROMRGB(0xf8f8f8);
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:SHARE_TITLE_NORMALCOLOR forState:UIControlStateNormal];
        [_cancelButton setTitleColor:SHARE_TITLE_HCOLOR forState:UIControlStateHighlighted];
        [_cancelButton addTarget:self action:@selector(tapAction) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton.frame = CGRectMake(0, _bottomHeight - 50, SCREEN_WIDTH, 50);
        [_bottomView addSubview:_cancelButton];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, .5)];
        line.backgroundColor = UICOLOR_FROMRGB(0x7f7f7f);
        [_cancelButton addSubview:line];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

//根据第三方平台是否安装情况判断显示高度
-(void)judgeBottomHeight {
    if (showAll || [WXApi isWXAppInstalled] && [QQApiInterface isQQInstalled]){
        _bottomHeight = 265;
    }else{
        _bottomHeight = 265 - 80;
    }
}

#pragma mark - 创建所有的分享按钮（每次show的时候都需要调用，因为本地的第三方软件随时可能发生变化，删除或者下载）
-(void)createShareButtons {
    int i = 0;
    for (int j = 0; j < 7; j++) {
        CGFloat buttonWidth = 65;
        CGFloat buttonHeighh = 85;
        CGFloat space = (SCREEN_WIDTH - buttonWidth * 4)/5.0;
        CGRect buttonFrame = CGRectMake(space + (i%4) * (buttonWidth + space), 10 + (i/4) * (buttonHeighh + 5), buttonWidth, buttonHeighh);
        UIButton *shareButton;
        switch (j) {
            case 0:
            {//微信
                if (showAll || [WXApi isWXAppInstalled]) {
                    i++;
                    shareButton = [self createShareButtonWithFrame:buttonFrame tag:100+j];
                    [shareButton setImage:[UIImage imageNamed:@"share_wx"] forState:UIControlStateNormal];
                    [shareButton setImage:[UIImage imageNamed:@"share_wx_h"] forState:UIControlStateHighlighted];
                    [shareButton setTitle:@"微信好友" forState:UIControlStateNormal];
                    [shareButton setTitle:@"微信" forState:UIControlStateNormal];
                }
            }
                break;
            case 1:
            {//微信朋友圈
                if (showAll || [WXApi isWXAppInstalled]) {
                    i++;
                    shareButton = [self createShareButtonWithFrame:buttonFrame tag:100+j];
                    [shareButton setImage:[UIImage imageNamed:@"share_wxfc"] forState:UIControlStateNormal];
                    [shareButton setImage:[UIImage imageNamed:@"share_wxfc_h"] forState:UIControlStateHighlighted];
                    [shareButton setTitle:@"微信朋友圈" forState:UIControlStateNormal];
                }
            }
                break;
            case 2:
            {//QQ
                if (showAll||[QQApiInterface isQQInstalled]) {
                    shareButton = [self createShareButtonWithFrame:buttonFrame tag:100+j];
                    i++;
                    [shareButton setImage:[UIImage imageNamed:@"share_qq"] forState:UIControlStateNormal];
                    [shareButton setImage:[UIImage imageNamed:@"share_qq_h"] forState:UIControlStateHighlighted];
                    [shareButton setTitle:@"QQ" forState:UIControlStateNormal];
                }
            }
                break;
            case 3:
            {//QQ空间
                if (showAll||[QQApiInterface isQQInstalled]) {
                    shareButton = [self createShareButtonWithFrame:buttonFrame tag:100+j];
                    i++;
                    
                    [shareButton setImage:[UIImage imageNamed:@"share_qqzone"] forState:UIControlStateNormal];
                    [shareButton setImage:[UIImage imageNamed:@"share_qqzone_h"] forState:UIControlStateHighlighted];
                    [shareButton setTitle:@"QQ空间" forState:UIControlStateNormal];
                }
            }
                break;
            case 4:
            {//新浪微博
                i++;
                shareButton = [self createShareButtonWithFrame:buttonFrame tag:100+j];
                
                [shareButton setTitle:@"新浪微博" forState:UIControlStateNormal];
                
                [shareButton setImage:[UIImage imageNamed:@"share_sina"] forState:UIControlStateNormal];
                [shareButton setImage:[UIImage imageNamed:@"share_sina_h"] forState:UIControlStateHighlighted];
            }
                break;
            case 5:
            {//短信
                if(showAll||[MFMessageComposeViewController canSendText]) {
                    i++;
                    shareButton =  [self createShareButtonWithFrame:buttonFrame tag:100+j];
                    [shareButton setTitle:@"短信" forState:UIControlStateNormal];
                    
                    [shareButton setImage:[UIImage imageNamed:@"share_sms"] forState:UIControlStateNormal];
                    [shareButton setImage:[UIImage imageNamed:@"share_sms_h"] forState:UIControlStateHighlighted];
                }
            }
                break;
            default:
                break;
        }
    }
}

-(UIButton *)createShareButtonWithFrame:(CGRect)frame tag:(int)tag
{
    UIButton *button = (UIButton *)[_bottomView viewWithTag:tag];
    if ([button isKindOfClass:[UIButton class]]) {
        button.frame = frame;
        return button;
    }
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.tag = tag;
    [button addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    button.titleEdgeInsets = UIEdgeInsetsMake(80, -65, 0, 0);
    if ([UIDevice currentDevice].systemVersion.floatValue < 7.0) {
        button.titleEdgeInsets = UIEdgeInsetsMake(80, -56, 0, 0);
    }
    [button setTitleColor:SHARE_TITLE_NORMALCOLOR forState:UIControlStateNormal];
    [button setTitleColor:SHARE_TITLE_HCOLOR forState:UIControlStateHighlighted];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    button.exclusiveTouch = YES;
    [_bottomView addSubview:button];
    return button;
}

-(void)tapAction
{
    [self dismissView];
}

-(void)showShareView {
    //每次显示分享界面的时候，需要重新判断显示的分享平台
    for (UIButton *button in _bottomView.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            button.frame = CGRectZero;
        }
    }
    [self judgeBottomHeight];
    _bottomView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, _bottomHeight);
    _cancelButton.frame = CGRectMake(0, _bottomHeight - 50, SCREEN_WIDTH, 50);
    [self createShareButtons];
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [window addSubview:self];
    
    __weak typeof(self) weakSelf = self;

    UIView *weakBottomView = _bottomView;
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        weakSelf.backgroundColor = [UIColor colorWithWhite:0 alpha:.6];
        weakBottomView.frame = CGRectMake(0, SCREEN_HEIGHT - _bottomHeight, SCREEN_WIDTH, _bottomHeight);
        
    } completion:^(BOOL finished){
        
    }];
}

-(void)dismissView {
    __weak typeof(self) weakSelf = self;
    UIView *weakBottomView = _bottomView;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        weakSelf.backgroundColor = [UIColor colorWithWhite:0 alpha:.0];
        weakBottomView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, _bottomHeight);
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}

#pragma mark - 邀请好友的分享
-(void)showInviteFriendsShareView {
    [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeDefault url:nil];
    
    self.musicURL = nil;
    self.shareType = FCXShareTypeDefault;
    
    self.shareTitle = @"铃声大全";
    self.shareContent = @"最好听的铃声尽在【铃声大全】，快来下载使用吧！";
    self.shareURL = [NSString stringWithFormat:@"http://itunes.apple.com/cn/app/id%@?mt=8", APPID];
    
    NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
    NSString *icon = [[infoPlist valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
    self.shareImage = [UIImage imageNamed:icon];
    [self showShareView];
}

#pragma mark - 只分享图片

- (void)showImageShare {
    self.musicURL = nil;
    self.shareContent = nil;
    self.shareType = FCXShareTypeImage;
    [self showShareView];
}

#pragma mark -  带音乐的分享
-(void)showMusicShare {
    [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeMusic url:self.musicURL];
    
    self.shareType = FCXShareTypeMusic;

    self.shareURL = [NSString stringWithFormat:@"http://itunes.apple.com/cn/app/id%@?mt=8", APPID];
    [self showShareView];
}

-(void)shareMusicToWXWithType:(int)type {
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = self.shareTitle;
    message.description = self.shareContent;
    [message setThumbImage:self.shareImage];
    
    WXMusicObject *musicObject = [WXMusicObject object];
    musicObject.musicUrl = self.shareURL;
    musicObject.musicDataUrl = self.musicURL;
    
    message.mediaObject = musicObject;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = type;
    
    [WXApi sendReq:req];
}

-(void)shareMusicToQQWithType:(int)type {
    QQApiAudioObject *audioObj =
    [QQApiAudioObject objectWithURL:[NSURL URLWithString:self.shareURL]
                              title:self.shareTitle
                        description:self.shareContent
                    previewImageURL:[NSURL URLWithString:self.shareImageURL]];
    [audioObj setFlashURL:[NSURL URLWithString:self.musicURL]];
    
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:audioObj];
    //将内容分享到qq
    if (0 == type) {
        [QQApiInterface sendReq:req];
    }else{//将内容分享到qzone
        [QQApiInterface SendReqToQZone:req];
    }
}

#pragma mark - 分享

-(void)shareAction:(UIButton *)button {
    [self dismissView];
    
    NSString *shareContent = self.shareContent;
    
    UIImage *shareImage = self.shareImage;
    
    NSString *shareType = @"";
    
    switch (button.tag) {
        case 100:
        {//微信
            shareType = UMShareToWechatSession;

            if (self.shareType == FCXShareTypeDefault) {
                
                if (self.shareURL) {
                    [UMSocialData defaultData].extConfig.wechatSessionData.url = self.shareURL;
                }
                if (self.shareTitle) {
                    [UMSocialData defaultData].extConfig.wechatSessionData.title = self.shareTitle;
                }
                [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
                shareContent = [self getShortShareContent];
                
            }else if (self.shareType == FCXShareTypeImage) {
                
                [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
                
            }else if (self.shareType == FCXShareTypeMusic) {
                //音乐分享需要单独调用微信的，否则音乐url与跳转url冲突
                [self shareMusicToWXWithType:WXSceneSession];
                return;
            }
        }
            break;
        case 101:
        {//朋友圈
            shareType = UMShareToWechatTimeline;

            if (self.shareType == FCXShareTypeDefault) {
                
                if (self.shareURL) {
                    [UMSocialData defaultData].extConfig.wechatSessionData.url = self.shareURL;
                }
                if (self.shareTitle) {
                    [UMSocialData defaultData].extConfig.wechatTimelineData.title = self.shareTitle;
                }
                [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
                
                shareContent = [self getShortShareContent];

            }else if (self.shareType == FCXShareTypeImage) {
                
                [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;

            }else if (self.shareType == FCXShareTypeMusic) {
                //音乐分享需要单独调用微信的，否则音乐url与跳转url冲突
                [self shareMusicToWXWithType:WXSceneTimeline];
                return;
            }
        }
            break;
        case 102:
        {//QQ好友
            shareType = UMShareToQQ;

            if (self.shareType == FCXShareTypeDefault) {
                
                if (self.shareURL) {
                    [UMSocialData defaultData].extConfig.qqData.url = self.shareURL;
                }
                if (self.shareTitle) {
                    [UMSocialData defaultData].extConfig.qqData.title = self.shareTitle;
                }
                shareContent = [self getShortShareContent];
                [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
                
            }else if (self.shareType == FCXShareTypeImage) {
                
                [UMSocialData defaultData].extConfig.qqData.url = nil;
                [UMSocialData defaultData].extConfig.qqData.title = nil;
                [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeImage;
                
            }else if (self.shareType == FCXShareTypeMusic) {
                //音乐分享需要单独调用腾讯的，否则音乐url与跳转url冲突
                [self shareMusicToQQWithType:0];
                return;
            }
        }
            break;
        case 103:
        {//QQ空间
            shareType = UMShareToQzone;

            if (self.shareType == FCXShareTypeDefault) {
                
                if (self.shareURL) {
                    [UMSocialData defaultData].extConfig.qzoneData.url = self.shareURL;
                }
                if (self.shareTitle) {
                    [UMSocialData defaultData].extConfig.qzoneData.title =  self.shareTitle;
                }
                shareContent = [self getShortShareContent];

            }else if (self.shareType == FCXShareTypeImage) {//qq空间必须有内容
                [UMSocialData defaultData].extConfig.qzoneData.url = nil;
                [UMSocialData defaultData].extConfig.qzoneData.title = nil;
 
            }else if (self.shareType == FCXShareTypeMusic) {
                
                //音乐分享需要单独调用腾讯的，否则音乐url与跳转url冲突
                [self shareMusicToQQWithType:1];
                return;

            }
        }
            break;
        case 104:
        {//新浪微博
            shareType = UMShareToSina;
            if (shareContent.length > 150) {
                shareContent = [[shareContent substringToIndex:150] stringByAppendingString:@"...   "];
            }
            
            if (self.shareType == FCXShareTypeDefault) {
                
                if (self.shareURL) {
                    shareContent = [shareContent stringByAppendingString:self.shareURL];
                }

            }else if (self.shareType == FCXShareTypeImage) {
                
            }else if (self.shareType == FCXShareTypeMusic) {
                shareContent = [NSString stringWithFormat:@"我发现了一首好听的铃声《%@》，大家快来听一听！（分享自：【铃声大全%@】）。点击试听：", self.shareTitle, self.shareURL];
            }

        }
            break;
        case 105:
        {//短信
            shareType = UMShareToSms;
            shareImage = nil;

            if (self.shareType == FCXShareTypeDefault) {
                shareContent = [shareContent stringByAppendingString:self.shareURL];

            }else if (self.shareType == FCXShareTypeImage) {
                
            }else if (self.shareType == FCXShareTypeMusic) {
                shareContent = [NSString stringWithFormat:@"我发现了一首好听的铃声《%@》来自【铃声大全】，大家快来下载应用试听吧！%@", self.shareTitle, self.shareURL];
            }
        }
            break;
        default:
            break;
    }
    
    [[UMSocialControllerService defaultControllerService] setShareText:shareContent shareImage:shareImage socialUIDelegate:self];
    
    //设置分享内容和回调对象
    [UMSocialSnsPlatformManager getSocialPlatformWithName:shareType].snsClickHandler(self.presentedController,[UMSocialControllerService defaultControllerService],YES);
}

- (NSString *)getShortShareContent {
    if (self.shareContent.length > 150) {
        self.shareContent = [self.shareContent substringToIndex:150];
    }
    return self.shareContent;
}

-(void)didCloseUIViewController:(UMSViewControllerType)fromViewControllerType
{
    DBLOG(@"didClose is %d",fromViewControllerType);
}

//下面得到分享完成的回调
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    DBLOG(@"didFinishGetUMSocialDataInViewController with response is %@",response);
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
        DBLOG(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
    }
}

@end
