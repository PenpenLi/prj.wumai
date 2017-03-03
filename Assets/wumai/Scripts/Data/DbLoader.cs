using LuaInterface;
using LuaFramework;

public class DbLoader
{





    private static bool m_bInited = false;
    public delegate DbBase CreateDbItem();
    private static void callInit<T>(LuaFunction dataFunc, LuaFunction keysFunc, string name) where T : DbBase, new()
    {
        var db = dataFunc.Call(name)[0] as LuaTable;
        var keys = keysFunc.Call(name);
        foreach (var key in keys){
        var dbItem = new T();
        dbItem.init(key.ToString(), db);}
    }

    public static void init()
    {
        if(m_bInited) return;
        var mgr = AppFacade.Instance.GetManager<LuaManager>(ManagerName.Lua);
        var mgrCfg = mgr.DoFile("Manager/MgrCfg")[0] as LuaTable;
        var dataFunc = mgrCfg.GetLuaFunction("getData");
        var keysFunc = mgrCfg.GetLuaFunction("getKeys");
        
        callInit<product_db>(dataFunc, keysFunc, "product_db");
        callInit<role_db>(dataFunc, keysFunc, "role_db");
        
        m_bInited = true;
    }

}