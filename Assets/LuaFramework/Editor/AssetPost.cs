using UnityEngine;
using System.Collections;
using UnityEditor;
using System.IO;

public class  AssetPost : AssetPostprocessor 
{

	void OnPostprocessTexture (Texture2D texture) 
	{
//		string AtlasName =  new DirectoryInfo(Path.GetDirectoryName(assetPath)).Name;
//		Debugger.Log (assetPath);
		// TextureImporter textureImporter = assetImporter as TextureImporter;
		// if (assetPath.LastIndexOf (".png") > 0 && assetPath.LastIndexOf (LuaFramework.AppConst.AppResName + "/UI") < 0 && textureImporter.textureType == TextureImporterType.Sprite) {
		// 	textureImporter.textureType = TextureImporterType.Image;
		// 	textureImporter.mipmapEnabled = false;
		// } else {
		// 	textureImporter.mipmapEnabled = false;
		// }

	}

}