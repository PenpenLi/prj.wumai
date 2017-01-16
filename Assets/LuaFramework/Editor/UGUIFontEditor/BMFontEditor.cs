/**
 * 
 * 借用NGUI的 BmpFont 创建艺术字
 * 2016/9/28
 * 
 **/

using UnityEngine;
using UnityEditor;
using System.IO;


public class BMFontEditor : EditorWindow
{
    [MenuItem("Tools/BMFont Maker")]
    static public void OpenBMFontMaker()
    {
        EditorWindow.GetWindow<BMFontEditor>(false, "BMFont Maker", true).Show();
    }

    [SerializeField]
    private TextAsset fntData;
    [SerializeField]
    private Texture2D fontTexture;

    private BMFont bmFont = new BMFont();

	string text;

    public BMFontEditor()
    {
    }

    void OnGUI()
    {
        fntData = EditorGUILayout.ObjectField("Fnt Data", fntData, typeof(TextAsset), false) as TextAsset;
        fontTexture = EditorGUILayout.ObjectField("Font Texture", fontTexture, typeof(Texture2D), false) as Texture2D;

        if (GUILayout.Button("Create BMFont"))
        {
			if(!fntData || ! fontTexture){
				Debug.LogWarning( "fnt or png is empty." );
				return;
			}

			Font targetFont = new Font();

            BMFontReader.Load(bmFont, fntData.name, fntData.bytes); // 借用NGUI封装的读取类
            CharacterInfo[] characterInfo = new CharacterInfo[bmFont.glyphs.Count];
            for (int i = 0; i < bmFont.glyphs.Count; i++)
            {
                BMGlyph bmInfo = bmFont.glyphs[i];
                CharacterInfo info = new CharacterInfo();
                info.index = bmInfo.index;
                
                // old
                //info.uv.x = (float)bmInfo.x / (float)bmFont.texWidth;
                //info.uv.y = 1 - (float)bmInfo.y / (float)bmFont.texHeight;
                //info.uv.width = (float)bmInfo.width / (float)bmFont.texWidth;
                //info.uv.height = -1f * (float)bmInfo.height / (float)bmFont.texHeight;

                float x = (float)bmInfo.x / (float)bmFont.texWidth;
                float y = 1 - (float)bmInfo.y / (float)bmFont.texHeight;
                float width = (float)bmInfo.width / (float)bmFont.texWidth;
                float height = -1f * (float)bmInfo.height / (float)bmFont.texHeight;

                info.uvTopLeft = new Vector2(x, y);
                info.uvBottomRight = new Vector2(x + width, y + height);


                //info.vert.x = 0;
                //info.vert.y = -(float)bmInfo.height;
                //info.vert.width = (float)bmInfo.width;
                //info.vert.height = (float)bmInfo.height;

                x = 0;
                y = -bmInfo.height;
                width = bmInfo.width;
                height = bmInfo.height;

                info.minX = 0;
                info.minY = (int)y;
                info.maxX = (int)width;
                info.maxY = (int)(y + height);

                //info.width = (float)bmInfo.advance;
                info.advance = bmInfo.advance;
                
                characterInfo[i] = info;
            }
            targetFont.characterInfo = characterInfo;

			Material fontMaterial = null;
			{
				Shader shader = Shader.Find("GUI/Text Shader");
				fontMaterial = new Material(shader);
			}

			fontMaterial.mainTexture = fontTexture;

			targetFont.material = fontMaterial;

//            fontMaterial.shader = Shader.Find("UI/Default");//如果用standard的shader，放到Android手机上，第一次加载会很慢??

			string path = AssetDatabase.GetAssetPath( fntData );
			string pathRoot = Path.GetDirectoryName(path);
			string fileName = Path.GetFileNameWithoutExtension(path);
			string commonPath = pathRoot + "/" + fileName;

			AssetDatabase.CreateAsset( fontMaterial, commonPath + ".mat" );
			AssetDatabase.CreateAsset( targetFont, commonPath + ".fontsettings" );
			AssetDatabase.SaveAssets();
			AssetDatabase.Refresh();

			Debug.Log( "create font <" + targetFont.name + "> success" + " total char:" + characterInfo.Length);
			Close();
        }
    }
}