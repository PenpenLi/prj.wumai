using UnityEngine;
using System.Collections;

public enum EventId {
    MSG_ERROR_CODE,
    
    MSG_RETRY_CONNECT,
    MSG_DISCONNECTED,
    MSG_CONNECTED,

    MSG_GAME_START,

    MSG_UPDATE_PLAYER_POS,
    MSG_GAME_OVER,

    UI_UPDATE_PING,
    UI_UPDATE_DEBUG_INFO,

    UI_UPDATE_ROOM_CENTER,
    UI_UPDATE_ROOM_INFO,

    UI_UPDATE_SCROE,

    // 更新阵营显示
    UI_UPDATE_GROUP,

    UI_UPDATE_JOYSTICK,

    UI_CLOSE_LOADING,
    UI_UPDATE_LOADING,

    UI_ADD_NAME,
}
