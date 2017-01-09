/*
 * Created by SharpDevelop.
 * User: vineleven
 * Date: 2016/4/6
 * Time: 11:22
 * 
 * To change this template use Tools | Options | Coding | Edit Standard Headers.
 */
using System;

using System.IO;

using ICSharpCode.SharpZipLib.Zip;

using LuaFramework;

using UnityEngine;

public static class ZIP2 {
	
	
	public static void compress(string srcPath, string destZipFile, int level = 6 ) {
		checkFileSeparatorChar(ref srcPath);
		checkFileSeparatorChar(ref destZipFile);
		
		bool exists = File.Exists(destZipFile);
		
		ZipFile zipFile;
		if(exists){
			zipFile = new ZipFile(destZipFile);
		} else {
			zipFile = ZipFile.Create(destZipFile);
		}
		
		string root;
		if(File.Exists(srcPath)){
			root = Path.GetDirectoryName(srcPath);
		} else {
			root = srcPath;
		}
		
		zipFile.BeginUpdate();
		addFile(ref zipFile, srcPath, root);
		zipFile.CommitUpdate();
	}
	
	
	public static bool decompress(string zipFileName, string pathRoot){
		checkFileSeparatorChar(ref zipFileName);
		checkFileSeparatorChar(ref pathRoot);
		
//		ZipFile zipFile = new ZipFile(zipFileName);
//		foreach (ZipEntry entry in zipFile) {
//			Console.WriteLine("entry name:" + entry.Name);
//		}

		try {
			new FastZip().ExtractZip(zipFileName, pathRoot, "");
			return true;
		} catch (Exception e) {
			Debug.LogError("decompress error:" + e.ToString());
			return false;
		}
		
	}
	
	
	
	
	
	
	
	static void addFile(ref ZipFile zipFile, string srcPath, string root){
		string name = srcPath.Replace(root, "");
		if(Directory.Exists(srcPath)){
			if(name != "")
				zipFile.AddDirectory(name);
	
			string[] filenames = Directory.GetFileSystemEntries(srcPath);
			foreach (string file in filenames) {
				addFile(ref zipFile, file, root);
			}
		} else if(File.Exists(srcPath)){
			zipFile.Add(srcPath, name);
		}
	}
	
	
	static readonly string DirectorySeparatorChar = Path.DirectorySeparatorChar + "";
	static void checkDirectorSeparatorChar(ref string dir){
		checkFileSeparatorChar( ref dir);
		
		if(!dir.EndsWith(DirectorySeparatorChar))
			dir += Path.DirectorySeparatorChar;
	}
	
	
	static void checkFileSeparatorChar(ref string file){
		file = file.Replace( "\\", "/" );
		file = file.Replace( "/", DirectorySeparatorChar );
	}
}