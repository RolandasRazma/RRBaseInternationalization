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


@implementation NSBundle (RRLocalizableString)


+ (void)load {
    
    // here I'm checking for NSLayoutConstraint as simple iOS6 check
    if( !NSClassFromString(@"NSLayoutConstraint") ){
        Class class = [NSBundle class];
        method_exchangeImplementations(class_getInstanceMethod(class, @selector(pathForResource:ofType:)),
                                       class_getInstanceMethod(class, @selector(_r_pathForResource:ofType:)));
    }
    
}


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
    
    if( !path && [extension isEqual:@"storyboardc"] ){
        path = _rr_currentNibPath = [self pathForResource:name ofType:extension inDirectory:@"Base.lproj"];
        _rr_currentNibDirectory = _rr_currentNibName = nil;
    }else if( !path && [extension isEqual:@"nib"] ){
        path = [self pathForResource:name ofType:extension inDirectory:@"Base.lproj"];
        
        if( !path ){
            if( !_rr_currentNibDirectory ){
                _rr_currentNibDirectory = [_rr_currentNibPath stringByReplacingOccurrencesOfString:[self bundlePath] withString:@""];
            }
            
            path = [self pathForResource:name ofType:extension inDirectory: _rr_currentNibDirectory];
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
    
    // here I'm checking for NSLayoutConstraint because NSLocalizableString is private in iOS6
    // keep in mind that I'm NOT using any private classes here as NSLocalizableString doesn't exist in iOS5
    if( !NSClassFromString(@"NSLayoutConstraint") ){
        [NSKeyedUnarchiver setClass:NSClassFromString(@"RRLocalizableString") forClassName:@"NSLocalizableString"];
    }
    
}


#pragma mark -
#pragma mark RRStoryboardEmbedSegue


- (id)initWithCoder:(NSCoder *)aDecoder {
    if( (self = [super init]) ){
        _stringsFileKey             = [aDecoder decodeObjectForKey:@"NSKey"];
        _developmentLanguageString  = [aDecoder decodeObjectForKey:@"NSDev"];
    }
    return self;
}


- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder {
    return [[NSBundle mainBundle] localizedStringForKey: _stringsFileKey
                                                  value: _developmentLanguageString
                                                  table: [NSBundle _rr_currentNibName]];
}


- (NSUInteger)length {
    return [_developmentLanguageString length];
}


- (unichar)characterAtIndex:(NSUInteger)index {
    return [_developmentLanguageString characterAtIndex:index];
}


@end
