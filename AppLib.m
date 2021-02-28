//
//  AppLib.m
//  MusicTiles
//
//  Created by Chiraag Bangera on 12/12/14.
//  Copyright (c) 2014 Chiraag Bangera. All rights reserved.
//

#import "AppLib.h"

@implementation AppLib


- (bool)deleteFile:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    return success;
}



-(NSString *)pathToFile:(NSString *)fileName
{
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    return fileAtPath;
}



-(BOOL)fileCheck:(NSString *)fileName
{
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* foofile = [documentsPath stringByAppendingPathComponent:fileName];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:foofile];
    return fileExists;
}





- (void)writeStringToFile:(NSString*)aString and:(NSString *)fileName
{
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
    }
    [[aString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:fileAtPath atomically:NO];
}

- (NSString*)readStringFromFile:(NSString *)fileName
{
    // Build the path...
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    // The main act...
    return [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:fileAtPath] encoding:NSUTF8StringEncoding];
}

-(NSArray *)listFileAtPath:(NSString *)path
{
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    return directoryContent;
}

-(NSString *)documentsPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}


-(void)deleteFilesOfType:(NSString *)extension
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject]))
    {
        if ([[filename pathExtension] isEqualToString:extension])
        {
            [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
        }
    }
}


-(NSString *)sizeOfFolder:(NSString *)folderPath
{
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    NSEnumerator *contentsEnumurator = [contents objectEnumerator];
    NSString *file;
    unsigned long long int folderSize = 0;
    while (file = [contentsEnumurator nextObject])
    {
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:file] error:nil];
        folderSize += [[fileAttributes objectForKey:NSFileSize] intValue];
    }
    //This line will give you formatted size from bytes ....
    NSString *folderSizeStr = [NSByteCountFormatter stringFromByteCount:folderSize countStyle:NSByteCountFormatterCountStyleFile];
    return folderSizeStr;
}



-(NSMutableDictionary *)mergeDictionaries:(NSMutableDictionary *)lhs and:(NSMutableDictionary *)rhs
{
    NSMutableDictionary *ret = [lhs mutableCopy];
    [ret addEntriesFromDictionary:rhs];
    return ret;
}




-(void)saveJSONDataToFile:(NSDictionary *)theData and:(NSString *)fileName
{
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath])
    {
        [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
    }
    [theData writeToFile:fileAtPath atomically:YES];
}


-(NSMutableDictionary *) parseJSONResponse:(NSData *)URLResponse
{
    @try
    {
    NSMutableDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:URLResponse
                                                                        options:kNilOptions
                                                                          error:nil];
    return jsonResponse;
    }
    @catch(NSException *e)
    {
        NSLog(@"Error Parsing JSON");
        return nil;
    }
}



-(NSData *)fetchDatafromServer:(NSString *)URLString
{
    NSURL *url = [[NSURL alloc]initWithString:URLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLResponse *response;
    NSData *GETReply      = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    return GETReply;
}


-(NSMutableDictionary *)loadJSONDataFromFile:(NSString *)fileName;
{
    NSMutableDictionary *myDic = [[NSMutableDictionary alloc] initWithContentsOfFile:[self pathToFile:fileName]];
    return myDic;
}


-(NSString *)loadFromBundle:(NSString *)fileName
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    return [mainBundle pathForResource:fileName  ofType: @"plist"];
}



-(NSMutableArray *)dataFromFile:(NSString *)fileName
{
    return [[NSArray arrayWithContentsOfFile:[self loadFromBundle:fileName]] mutableCopy];
}


-(void)saveImagetoFile:(UIImage *)image and:(NSString *)filename
{
    NSData * binaryImageData = UIImagePNGRepresentation(image);
    NSString *basePath = [self documentsPath];
    [binaryImageData writeToFile:[basePath stringByAppendingPathComponent:filename] atomically:YES];
}


-(UIImage *)loadImagefromFile:(NSString *)filename
{
     NSString *basePath = [self documentsPath];
    NSData *imgData = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[basePath stringByAppendingPathComponent:filename]]];
    UIImage *thumbNail = [[UIImage alloc] initWithData:imgData];
    return thumbNail;
}


-(void)checkAndCopy:(NSString *)filename
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *txtPath = [documentsDirectory stringByAppendingPathComponent:filename];
    if ([fileManager fileExistsAtPath:txtPath] == NO)
    {
        NSString *file = [filename componentsSeparatedByString:@"."][0];
        NSString *ext = [filename componentsSeparatedByString:@"."][1];
        NSLog(@"File: %@ Ext: %@",file,ext);
        NSString *resourcePath = [[NSBundle mainBundle] pathForResource:file ofType:ext];
        [fileManager copyItemAtPath:resourcePath toPath:txtPath error:&error];
    }
}



@end
