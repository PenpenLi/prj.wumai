using LuaInterface;
using LuaFramework;

public class DbLoader
{





    private static bool m_bInited = false;
    public delegate DbBase CreateDbItem();
    private static void callInit<T>(LuaFunction initFunc, string name) where T : DbBase, new()
    {
        CreateDbItem createFunc = () =>{return new T();};
        initFunc.Call(name, createFunc);
    }

    public static void init()
    {
        if(m_bInited) return;
        var mgr = AppFacade.Instance.GetManager<LuaManager>(ManagerName.Lua);
        var tb = mgr.DoFile("Game/Common/DbLoader")[0] as LuaTable;
        var luaInitFunc = tb["init"] as LuaFunction;

        callInit<role_db>(luaInitFunc, "role_db");
        
        m_bInited = true;
    }

}