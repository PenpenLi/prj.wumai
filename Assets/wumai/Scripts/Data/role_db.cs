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


    private static Dictionary<int, role_db> m_allData = new Dictionary<int, role_db>();
    public override void init(string id, LuaTable db)
    {
        var key = int.Parse(id);
        var data = db[key] as LuaTable;
        this.id = int.Parse(data["id"].ToString());
        this.name = (string)data["name"];
        this.icon = (string)data["icon"];
        this.quality = (string)data["quality"];
        this.attr = (string)data["attr"];
        this.order = int.Parse(data["order"].ToString());
        this.upId = (string)data["upId"];
        this.heigh = float.Parse(data["heigh"].ToString());
        this.isHero = bool.Parse(data["isHero"].ToString());
        m_allData.Add(this.id, this);
    }

    public role_db this[int key]
    {
        get{
        role_db db;
        m_allData.TryGetValue(key, out db);
        return db;}
    }

}