using UnityEngine;
using System.Collections;



public class GameMap : GameUnit {

    public override string getAssetBundleName()
    {
        return "Map/Map/prefab";
    }


    private Camera m_camera;

    private Tile[][] m_tiles;

    public override void onCreate(object arguments)
    {
        m_camera = transform.FindChild("Camera").GetComponent<Camera>();

        var m_mapInfo = arguments as int[][];
        
        // 随机一个地图
        int row = 20;
        int col = 20;

        m_mapInfo = new int[row][];
        for (int i = 0; i < row; i++)
        {
            int[] datas = new int[col];
            for (int j = 0; j < col; j++)
            {
                datas[j] = Tools.Random(1, 4);
            }
            m_mapInfo[i] = datas;
        }

        createTiles(m_mapInfo);
    }


    void createTiles(int[][] mapInfo)
    {
        int row = mapInfo.Length;
        m_tiles = new Tile[row][];

        for (int i = 0; i < row; i++)
        {
            int[] info = mapInfo[i];
            Tile[] ts = new Tile[info.Length];
            for (int j = 0; j < info.Length; j++)
            {
                ts[j] = new Tile(info[j]);
                ts[j].setParent(transform);
                ts[j].setPosition(j, i, row + 1);
            }

            m_tiles[i] = ts;
        }
    }


    public override void dispose()
    {
        base.dispose();
        for (int i = 0; i < m_tiles.Length; i++)
        {
            for (int j = 0; j < m_tiles[i].Length; j++)
            {
                m_tiles[i][j].dispose();
            }
        }
    }
}
