//----------------------------------------------------------------//
//Created by UL on 15-10-26.
//----------------------------------------------------------------//



#if(CDSC_ENABLE_JSON_RPC)

#include <string.h>
#include "SdkBridge.h"
#include "ULObjectCBridge.h"




    SdkBridge::SdkBridge()
    {
        
    };
    
    SdkBridge::~SdkBridge()
    {
        
    };

    NSString*  SdkBridge::sdkMsgToGame(NSString *paramsInJson)
    {
        NSLog(@"say hello %@",paramsInJson);//
        [[ULObjectCBridge getInstance]sdkMsgToGame:paramsInJson];
        
        return @"";
    };

#endif