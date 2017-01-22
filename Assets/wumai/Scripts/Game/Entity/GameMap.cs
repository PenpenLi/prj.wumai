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

        var mapInfo = arguments as int[][];

        if (mapInfo == null)
            mapInfo = getRandomMapInfo();

        m_camera.transform.localPosition = new Vector3(0, mapInfo[0].Length / 2f * 0.7f, 0);
        createTiles(mapInfo);
    }


    int[][] getRandomMapInfo()
    {
        // 随机一个地图
        int row = 20;
        int col = 20;

        int[][] mapInfo = new int[row][];
        for (int i = 0; i < row; i++)
        {
            int[] datas = new int[col];
            for (int j = 0; j < col; j++)
            {
                datas[j] = Tools.Random(1, 4);
            }
            mapInfo[i] = datas;
        }

        return mapInfo;
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

                float x = j * 0.5f - i * 0.5f;
                float y = j * 0.5f * 0.7f + i * 0.5f * 0.7f;

                ts[j].setPosition(x, y, row * 0.5f + 1);
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
