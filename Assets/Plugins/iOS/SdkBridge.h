//----------------------------------------------------------------//
//Created by UL on 15-10-26.
//----------------------------------------------------------------//

#ifndef __r01x2_Test__MyLuaObjCBridgeTest__
#define __r01x2_Test__MyLuaObjCBridgeTest__



#if(CDSC_ENABLE_JSON_RPC)


#include "MyLuaObjCBridge.h"
#import "ULObjectCBridge.h"
class SdkBridge:public MyLuaObjCBridge
{
public:
    SdkBridge();
    virtual ~SdkBridge();
    virtual NSString* sdkMsgToGame(NSString* paramsInJson);
    
};
#endif
#endif /* defined(__r01x2_pp__MyLuaObjCBridgePP__) */
