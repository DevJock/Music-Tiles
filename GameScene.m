//
//  GameScene.m
//  Music Tiles
//
//  Created by Chiraag Bangera on 3/15/15.
//  Copyright (c) 2015 Chiraag Bangera. All rights reserved.
//

#import "GameScene.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#include "AppLib.h"
#include "AppDelegate.h"


#define maxX = self.screen.size.width

@implementation GameScene
{
    AppDelegate *appDelegate;
    NSArray *bgColors;
    NSTimer *bgColorTimer;
    NSTimer *tileTimer;
    NSMutableArray *tiles;
    MPMusicPlayerController *musicPlayer;
    BOOL playable;
    float playDuration;
    float tempo;
    SKLabelNode *label;
}


static const uint32_t tileCategory = 0x1 << 0;



-(void)didMoveToView:(SKView *)view
{
    self.view.multipleTouchEnabled = YES ;
    self.physicsWorld.contactDelegate = self;
    tempo = 0.7;
    playDuration = 0 ;
    tiles = [[NSMutableArray alloc] init];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    bgColors = [[appDelegate Colors] objectForKey:@"bgColors"];
    label = [[SKLabelNode alloc] initWithFontNamed:@"Arial"];
    label.fontSize = 22;
    label.fontColor = [SKColor whiteColor];
    label.position = CGPointMake(self.scene.size.width / 2 - label.frame.size.width, label.frame.size.height + 50);
    [self addChild:label];
    if([bgColors count] > 0)
    bgColorTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeColors) userInfo:nil repeats:YES];
    tileTimer = [NSTimer scheduledTimerWithTimeInterval:tempo target:self selector:@selector(tileManager) userInfo:nil repeats:YES];
    [self getSongs];
}


-(void)tileManager
{
    NSLog(@"count: %d",(int)[tiles count]);
    if([tiles count] < 15)
    {
        int rand = arc4random() % 5;
        SKSpriteNode *tile = (SKSpriteNode *) [self newTile:rand];
        if(tile != nil)
        {
            [tiles addObject:tile];
            [self addChild:tile];
        }
    }
    else
    {
        int random = arc4random() % [tiles count];
        @try
        {
         SKSpriteNode *node =  (SKSpriteNode *)[tiles objectAtIndex:random];
        [tiles removeObjectAtIndex:random];
         [node removeFromParent];
        }
        @catch(NSException *e)
        {
            NSLog(@"Error Exception");
        }
    }
}



-(SKSpriteNode *)newTile:(int)tileType
{
    SKSpriteNode *tile = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:CGSizeMake(120 , 120)];
    do
    {
    tile.position = CGPointMake([self randomX] + tile.size.width / 2, [self randomY] + tile.size.height / 2);
   }while([self inside:tile]);
    if(tileType == 0)
    {
        tile.name = @"DeathTile";
        tile.color = [SKColor blackColor];
    }
    else
    {
        tile.name = @"SafeTile";
        tile.color = [SKColor whiteColor];
    }
    tile.zPosition = 5;
    tile.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:tile.frame.size];
    tile.physicsBody.usesPreciseCollisionDetection = YES;
    tile.physicsBody.categoryBitMask = tileCategory;
    tile.physicsBody.contactTestBitMask = tileCategory ;
    tile.physicsBody.affectedByGravity = NO;
    tile.physicsBody.dynamic = NO;
    return tile;
}


-(BOOL)inside:(SKSpriteNode *)tile
{
    for(int i=0;i<[tiles count];i++)
    {
        SKSpriteNode *node = (SKSpriteNode *)[tiles objectAtIndex:i];
        if([tile containsPoint:node.position])
        {
            NSLog(@"Overlap");
            return true;
        }
    }
    return false;
}






-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:self];
        SKNode *node = [self nodeAtPoint:location];
        if ([node.name isEqualToString:@"SafeTile"])
            {
                [self performSelector:@selector(remove:) withObject:node];
                playable = true;
            }
    }
}




-(void)changeColors
{
    int ind = arc4random() % [bgColors count];
    SKColor *color = [SKColor  colorWithRed:[[bgColors objectAtIndex:ind][0] intValue]  green:[[bgColors objectAtIndex:ind][1] intValue] blue:[[bgColors objectAtIndex:ind][2] intValue] alpha:[[bgColors objectAtIndex:ind][3] intValue]];
    self.backgroundColor = color;
    /*
    if(playDuration >= 0.1)
        playDuration -= 0.1;
    
    if(playDuration <= 0.1)
    {
        playable = false;
    }
    else
    {
        playable = true;
    }
    */
    if(playable)
    {
        [self performSelectorInBackground:@selector(playMusicBriefely) withObject:nil];
        [self performSelector:@selector(stopPlayback) withObject:nil afterDelay:1];
    }
    label.text = [NSString stringWithFormat:@"Seconds: %.1f",playDuration];
}

-(void) playMusicBriefely
{
    playable = false;
    [musicPlayer play];
}

-(void)stopPlayback
{
    [NSData cancelPreviousPerformRequestsWithTarget:self selector:@selector(playMusicBriefely) object:nil];
    [musicPlayer pause];
}

-(float)randomX
{
    return (arc4random() % (int)self.scene.size.width) + 10;
}

-(float)randomY
{
    return (arc4random() % (int)self.scene.size.height) + 10;
}

-(void)remove:(SKSpriteNode *)node
{
    playDuration += 0.01;
    SKAction *color = [SKAction colorizeWithColor:[SKColor grayColor] colorBlendFactor:0.8 duration:0.5];
    SKAction *fade = [SKAction fadeOutWithDuration:1];
    SKAction *block = [SKAction group:@[color,fade]];
    [node runAction:block completion:^{
        [node removeFromParent];
        [tiles removeObject:node];
    }];
}

-(void)getSongs
{
    musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    NSString *playlistName = appDelegate.playlist;
    MPMediaPropertyPredicate *playlistPredicate = [MPMediaPropertyPredicate predicateWithValue:playlistName forProperty:MPMediaPlaylistPropertyName];
    NSNumber *mediaTypeNumber = [NSNumber numberWithInteger:MPMediaTypeMusic];
    MPMediaPropertyPredicate *mediaTypePredicate = [MPMediaPropertyPredicate predicateWithValue:mediaTypeNumber forProperty:MPMediaItemPropertyMediaType];
    NSSet *predicateSet = [NSSet setWithObjects:playlistPredicate, mediaTypePredicate, nil];
    MPMediaQuery *mediaTypeQuery = [[MPMediaQuery alloc] initWithFilterPredicates:predicateSet];
    [mediaTypeQuery setGroupingType:MPMediaGroupingPlaylist];
    [musicPlayer setQueueWithQuery:mediaTypeQuery];
}


@end
