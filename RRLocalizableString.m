//
//  RRLocalizableString.m
//  RRBaseInternationalization
//
//  Copyright (c) 2013 Rolandas Razma <rolandas@razma.lt>
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "RRLocalizableString.h"
#import <objc/runtime.h>


#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
@implementation NSBundle (RRLocalizableString)


#pragma mark -
#pragma mark NSObject


+ (void)load {
    
    @autoreleasepool {
        // Check if iOS doesn't have support for it
        if( [[[UIDevice currentDevice] systemVersion] compare:@"6.0" options:NSNumericSearch] == NSOrderedAscending ){
            Class class = [NSBundle class];
            method_exchangeImplementations(class_getInstanceMethod(class, @selector(pathForResource:ofType:)),
                                           class_getInstanceMethod(class, @selector(_r_pathForResource:ofType:)));
        }
    }
    
}


#pragma mark -
#pragma mark NSBundle (RRLocalizableString)


static NSString *_rr_currentNibPath;
static NSString *_rr_currentNibDirectory;
static NSString *_rr_currentNibName;


+ (NSString *)_rr_currentNibName {
    if( !_rr_currentNibName ){
        _rr_currentNibName = [[_rr_currentNibPath lastPathComponent] stringByDeletingPathExtension];
    }
    return _rr_currentNibName;
}


- (NSString *)_r_pathForResource:(NSString *)name ofType:(NSString *)extension {
    NSString *path = [self _r_pathForResource:name ofType:extension];
    
    if( !path ){
    
        if( [extension isEqual:@"storyboardc"] ){
            path = [self pathForResource:name ofType:extension inDirectory:@"Base.lproj"];
            
            _rr_currentNibPath = path;
            _rr_currentNibDirectory = _rr_currentNibName = nil;
        }else if( [extension isEqual:@"nib"] ){
            if( (path = [self pathForResource:name ofType:extension inDirectory:@"Base.lproj"]) ){
                if( [path rangeOfString:@".storyboardc"].location == NSNotFound ){
                    _rr_currentNibPath = path;
                    _rr_currentNibDirectory = _rr_currentNibName = nil;
                }
            }else{
                if( !_rr_currentNibDirectory ){
                    _rr_currentNibDirectory = [_rr_currentNibPath stringByReplacingOccurrencesOfString:[self bundlePath] withString:@""];
                }
                
                path = [self pathForResource:name ofType:extension inDirectory: _rr_currentNibDirectory];
            }
        }
    
    }

    return path;
}


@end


@implementation RRLocalizableString {
    NSString *_developmentLanguageString;
    NSString *_stringsFileKey;
}


#pragma mark -
#pragma mark NSObject


+ (void)load {
    
    @autoreleasepool {
        // Check if iOS doesn't have support for it
        // keep in mind that I'm NOT using any private classes here as NSLocalizableString doesn't exist in iOS5
        if( [[[UIDevice currentDevice] systemVersion] compare:@"6.0" options:NSNumericSearch] == NSOrderedAscending ){
            [NSKeyedUnarchiver setClass:[RRLocalizableString class] forClassName:@"NSLocalizableString"];
        }
    }
    
}


#pragma mark -
#pragma mark NSCoding


- (id)initWithCoder:(NSCoder *)aDecoder {
    if( (self = [super init]) ){
        _stringsFileKey             = [aDecoder decodeObjectForKey:@"NSKey"];
        _developmentLanguageString  = [aDecoder decodeObjectForKey:@"NSDev"];
    }
    return self;
}


#pragma mark -
#pragma mark NSObject


- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder {
    return [[NSBundle mainBundle] localizedStringForKey: _stringsFileKey
                                                  value: _developmentLanguageString
                                                  table: [NSBundle _rr_currentNibName]];
}


#pragma mark -
#pragma mark NSString


- (NSUInteger)length {
    return [_developmentLanguageString length];
}


- (unichar)characterAtIndex:(NSUInteger)index {
    return [_developmentLanguageString characterAtIndex:index];
}


@end
#endif