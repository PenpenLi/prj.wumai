using UnityEngine;
using System.Collections;
using LuaInterface;


public abstract class DbBase {
    public abstract void init(int id, LuaTable data);
}

