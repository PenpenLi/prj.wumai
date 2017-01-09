/*
 * 由SharpDevelop创建。
 * 用户： LDW
 * 日期: 2016/1/18
 * 时间: 13:39
 * 
 */
using System;

using System.IO;

using ICSharpCode.SharpZipLib.Checksums;
using ICSharpCode.SharpZipLib.Zip;

using LuaFramework;

/// <summary>
/// Description of Zip.
/// </summary>
public static class ZIP {
	
	static readonly string DirectorySeparatorChar = Path.DirectorySeparatorChar + "";
	
	
	
	/// <summary>
	/// 压缩目标文件夹
	/// </summary>
	/// <param name="srcPath">需要压缩的资源路径（只能是个路径）</param>
	/// <param name="destZipFile">压缩后保存的文件</param>
	/// <param name="level">store only to 9 - means best compression</param>
	public static void compress(string srcPath, string destZipFile, int level = 6 ) {
		bool isFolder = Directory.Exists(srcPath);
		bool isFile = File.Exists(srcPath);
		
	    ZipOutputStream stream = new ZipOutputStream(File.Create(destZipFile));
		stream.SetLevel( level );
		
		if(isFolder)
			zipFolder(srcPath, ref stream);
		else if(isFile){
			Crc32 crc = new Crc32();
			zipFile(srcPath, ref stream, ref crc, Path.GetDirectoryName(srcPath));
		}else
			Util.LogError("Can't file srcPath " + srcPath);
		
		stream.Finish();
		stream.Close();
	}
	
	
	static void zipFolder(string resPath, ref ZipOutputStream stream, string pathRoot = null ) {
		checkDirectorSeparatorChar(ref resPath);
		if( pathRoot == null )
			pathRoot = resPath;
	    
	    Crc32 crc = new Crc32();
	    string[] filenames = Directory.GetFileSystemEntries(resPath);
	    foreach (string file in filenames) {
	    	if (Directory.Exists(file)) {
				zipFolder(file, ref stream, pathRoot);
	    	} else if(File.Exists(file)) {
				zipFile(file, ref stream, ref crc, pathRoot);
	    	}
	    }
	}
	
	
	static void zipFile(string resPath, ref ZipOutputStream stream, ref Crc32 crc, string pathRoot ) {
	    string file = resPath;
    	if(File.Exists(file)) {
    		FileStream fs = File.OpenRead(file);

    		byte[] buffer = new byte[fs.Length];
    		fs.Read(buffer, 0, buffer.Length);
    		string relativeFile = file.Replace( pathRoot, "" );
			ZipEntry entry = new ZipEntry(relativeFile);

    		entry.DateTime = DateTime.Now;
    		entry.Size = fs.Length;
    		fs.Close();
    		crc.Reset();
    		crc.Update( buffer );
    		entry.Crc = crc.Value;
			
			stream.PutNextEntry(entry);
			stream.Write(buffer, 0, buffer.Length);
    	}
	}
	
	
	/// <summary>
	/// 解压目标文件夹
	/// </summary>
	/// <param name="zipFile">压缩文件</param>
	/// <param name="pathRoot">解压根目录</param>
	public static bool decompress(string zipFile, string pathRoot){
		checkFileSeparatorChar(ref zipFile);
		
		if( !File.Exists( zipFile) ) return false;
		
		return decompress( File.OpenRead(zipFile), pathRoot );
	}
	
	
	/// <summary>
	/// 解压目标文件夹
	/// </summary>
	/// <param name="zipFileData">压缩文件数据</param>
	/// <param name="pathRoot">解压根目录</param>
	public static bool decompress( byte[] zipFileData, string pathRoot){
		if(zipFileData == null ) return false;
		
		return decompress( new MemoryStream( zipFileData ), pathRoot );
	}
	
	
	/// <summary>
	/// 解压目标文件夹
	/// </summary>
	/// <param name="zipFileStream">压缩数据流</param>
	/// <param name="pathRoot">解压根目录</param>
	/// /// <param name="clearRoot">清理解压目录</param>
	public static bool decompress(Stream zipFileStream, string pathRoot, bool clearRoot = false) {
		checkDirectorSeparatorChar(ref pathRoot);
		
		// 若目录存在则清空目录
		if(Directory.Exists(pathRoot)){
			if(clearRoot)
				Directory.Delete(pathRoot, true);
		}else
			Directory.CreateDirectory(pathRoot);
		
		ZipInputStream zipStream = new ZipInputStream(zipFileStream);
        ZipEntry theEntry;
        string newFile = "";
        string newPath = "";
	    try {
	        while ( (theEntry = zipStream.GetNextEntry()) != null) {
	        	newFile = pathRoot + theEntry.Name;
	        	newPath = Path.GetDirectoryName( newFile );
	        	if(!Directory.Exists(newPath)) Directory.CreateDirectory(newPath);
	        	
	            FileStream streamWriter = File.Create( newFile );
	            int size = 2048;
	            byte[] data = new byte[2048];
	            while (true) {
	                size = zipStream.Read(data, 0, data.Length);
	                if (size > 0)
	                    streamWriter.Write(data, 0, size);
	                else
	                    break;
	            }
	            streamWriter.Close();
	        }
	        zipStream.Close();
	    } catch (Exception ex) {
        	Util.LogError( "unZipFile: " + newFile + " msg:" + ex.Message );
        	Util.LogError( "StackTrace: " + ex.StackTrace );
        	zipStream.Close();
        	return false;
	    }
        
        return true;
	}
	
	
	// 直接返回原始数据，不解压到具体的
	public static byte[] decompress(byte[] zipFileData) {
		if(zipFileData == null) return null;
		
		ZipInputStream zipStream = new ZipInputStream( new MemoryStream( zipFileData ) );
        byte[] data = null;
	    try {
	        if (zipStream.GetNextEntry() != null) {
	            data = new byte[zipStream.Length];
	            zipStream.Read(data, 0, data.Length);
	        }
	        zipStream.Close();
	    } catch (Exception ex) {
        	Util.LogError( "StackTrace: " + ex.StackTrace );
        	data = null;
        	zipStream.Close();
	    }
        
        return data;
	}
	
	
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
