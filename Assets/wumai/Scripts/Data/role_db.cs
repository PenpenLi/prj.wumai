using System.Collections.Generic;
using LuaInterface;

public class role_db : DbBase
{
    public string name = null;
    public string icon = null;
    public string quality = null;
    public string attr = null;
    public string upId = null;

    public int id = 0;
    public int order = 0;

    public float heigh = 0f;

    public bool isHero = false;


    private static Dictionary<int, role_db> m_allData = new Dictionary<int,role_db>();
    public override void init(int a, LuaTable data)
    {
        id = (int)data["id"];
        name = (string)data["name"];
        icon = (string)data["icon"];
        quality = (string)data["quality"];
        attr = (string)data["attr"];
        order = (int)data["order"];
        upId = (string)data["upId"];
        heigh = (float)data["heigh"];
        isHero = (bool)data["isHero"];
    }

    public static role_db get(int key)
    {
        role_db db;
        m_allData.TryGetValue(key, out db);
        return db;
    }

}