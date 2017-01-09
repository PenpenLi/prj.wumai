//----------------------------------------------------------------//
//Created by LDW
//2016.08.24
//----------------------------------------------------------------//

#ifndef __ULObjectCBridge_h__
#define __ULObjectCBridge_h__





@interface ULObjectCBridge : NSObject


-(void) sdkMsgToGame:(NSString *) jsonStr;

+(instancetype)getInstance;

@end


#endif
