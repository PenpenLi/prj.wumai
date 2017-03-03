using System.Collections.Generic;
using LuaInterface;

public class product_db : DbBase
{
    public string id = null;
    public string name = null;

    public int preId = 0;
    public int type = 0;
    public int reqItemId = 0;
    public int reqCount = 0;
    public int reqTime = 0;
    public int outItemId = 0;
    public int outSpeed = 0;
    public int outLimit = 0;




    private static Dictionary<string, product_db> m_allData = new Dictionary<string, product_db>();
    public override void init(string id, LuaTable db)
    {
        var key = id;
        var data = db[key] as LuaTable;
        this.id = (string)data["id"];
        this.name = (string)data["name"];
        this.preId = int.Parse(data["preId"].ToString());
        this.type = int.Parse(data["type"].ToString());
        this.reqItemId = int.Parse(data["reqItemId"].ToString());
        this.reqCount = int.Parse(data["reqCount"].ToString());
        this.reqTime = int.Parse(data["reqTime"].ToString());
        this.outItemId = int.Parse(data["outItemId"].ToString());
        this.outSpeed = int.Parse(data["outSpeed"].ToString());
        this.outLimit = int.Parse(data["outLimit"].ToString());
        m_allData.Add(this.id, this);
    }

    public product_db this[string key]
    {
        get{
        product_db db;
        m_allData.TryGetValue(key, out db);
        return db;}
    }

}