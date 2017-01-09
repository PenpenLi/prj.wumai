//----------------------------------------------------------------//
//Created by LDW
//2016.08.24
//----------------------------------------------------------------//


#include "Foundation/Foundation.h"
#import "MessageMgr.h"
#import "ULObjectCBridge.h"



char * unitNativeObjName;
char * unitNativeFuncName;




@implementation ULObjectCBridge


static ULObjectCBridge* instance=nil;


+ (instancetype)getInstance{
    if (!instance) {
        instance = [[self alloc] init];
        
    }
    return instance;
}

-(void) sdkMsgToGame:(NSString *)jsonStr
{
    // [ULNativeController triggerLuaCallbackByJson:paramsInJson];
//    NSLog(@"--->unitNativeObjName:%s", [unitNativeObjName UTF8String] );
//    NSLog(@"--->unitNativeFuncName:%s", [unitNativeFuncName UTF8String] );

//    NSLog(@"--->unitNativeObjName:%s", unitNativeObjName );
//    NSLog(@"--->unitNativeFuncName:%s", unitNativeFuncName );
    
//    NSLog(@"--->%s", [jsonStr UTF8String] );
    
    UnitySendMessage( unitNativeObjName, unitNativeFuncName, [jsonStr UTF8String]);
//    NSLog( @"--> send to game" );
};

@end





#if __cplusplus
extern "C" {
#endif
    
    //字符串转化的工具函数
    // NSString* _CreateNSString (const char* string)
    // {
    //     if (string)
    //         return [NSString stringWithUTF8String: string];
    //     else
    //         return [NSString stringWithUTF8String: ""];
    // }
    
    
     char* _MakeStringCopy( const char* string)
     {
         if (NULL == string) {
             return NULL;
         }
         char* res = (char*)malloc(strlen(string)+1);
         strcpy(res, string);
         return res;
     }
    
    void setReceiver( const char * unityObjName,  const char * methodName )
    {
        NSLog( @"setReceiver" );
//        unitNativeObjName = [NSString stringWithUTF8String:unityObjName];
//        unitNativeFuncName = [NSString stringWithUTF8String:methodName];
        
        unitNativeObjName = _MakeStringCopy( unityObjName );
        unitNativeFuncName = _MakeStringCopy( methodName );
        
        NSLog(@"---> unitNativeObjName:%s", unitNativeObjName );
        NSLog(@"---> unitNativeFuncName:%s", unitNativeFuncName );
    }
    

    void receiveFromUnity(const char* jsonStr) {
        // unitNativeObjName = [NSString stringWithUTF8String:name];
//        NSLog( @"receiveFromUnity" );
        [[MessageMgr getInstance] getGameMsg:[NSString stringWithUTF8String:jsonStr]];
    }
    
#if __cplusplus
}
#endif




