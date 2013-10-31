//
//  HGAppDelegate.m
//  MacInfo
//
//  Created by WangRui on 13-10-31.
//  Copyright (c) 2013年 HamGuy. All rights reserved.
//

#import "HGAppDelegate.h"
#import <ifaddrs.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"


enum {
    ITEM_TAG_IP,
    ITEM_TAG_FILE,
    ITEM_TAG_QIUT
};

@interface HGAppDelegate ()

@property (nonatomic,strong) NSStatusItem *item;
@property (nonatomic,assign) BOOL alreadyHide;

@end

@implementation HGAppDelegate

-(void) awakeFromNib
{
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    _item =[statusBar statusItemWithLength:NSVariableStatusItemLength];
    
    NSMenu *menu = [[NSMenu alloc] init];
    NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"IP: %@",[self getIp]] action:@selector(exitApp) keyEquivalent:@""];
    menuItem.tag = ITEM_TAG_IP;
    [menu addItem:menuItem];
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"显示隐藏文件" action:@selector(showOrHideFile) keyEquivalent:@""];
    menuItem.tag = ITEM_TAG_FILE;
    [menu addItem:menuItem];
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"退出" action:@selector(exitApp) keyEquivalent:@"q"];
    menuItem.tag = ITEM_TAG_QIUT;
    [menu addItem:menuItem];
    
    
    [_item setImage:[NSImage imageNamed:@"tryIcon"]];
    [_item setMenu:menu];
    [_item setHighlightMode: YES];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netwrorkChanged:) name:kReachabilityChangedNotification object:nil];
    Reachability * reach = [Reachability reachabilityForInternetConnection];
    [reach startNotifier];
}

-(NSString *) getIp
{
    NSHost* myhost =[NSHost currentHost];
    return [[myhost addresses] objectAtIndex:1];
}

-(void) showOrHideFile
{
    system(_alreadyHide ? "defaults write com.apple.finder AppleShowAllFiles  NO":"defaults write com.apple.finder AppleShowAllFiles  YES");
    system("killall Finder");
    NSMenuItem *item = [_item.menu itemWithTag:ITEM_TAG_FILE];
    item.title = !_alreadyHide ? @"取消显示隐藏文件":@"显示隐藏文件";
    _alreadyHide=!_alreadyHide;
}

-(void) exitApp
{
//    exit(0);
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:kReachabilityChangedNotification];
    [NSApp performSelector:@selector(terminate:) withObject:Nil afterDelay:0.0];
}

-(void)netwrorkChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    
    if(![reach isReachable])
    {
        [self handleDisconnetion];
    }
    else
    {
        NSMenuItem *item = [_item.menu itemWithTag:ITEM_TAG_IP];
        item.title = [NSString stringWithFormat:@"IP: %@",[self getIp]];
    }
}

-(void) handleDisconnetion
{
    NSMenuItem *item = [_item.menu itemWithTag:ITEM_TAG_IP];
    item.title = @"网络连接中断！";
    NSAlert *alert =[[NSAlert alloc] init];
    alert.informativeText = @"网络连接中断！";
    alert.messageText =@"网络故障";
    alert.alertStyle = NSWarningAlertStyle;
    alert.icon = nil;
    [alert runModal];
}


@end
