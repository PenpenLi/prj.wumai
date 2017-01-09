#!/bin/python
# -*- coding: utf-8 -*-


import os
import sys
import json
import shutil
import re









########## 辅助函数 ##########

def readFile( filePath ):
    if not os.path.exists( filePath ):
        return
    verStr = ""
    with open( filePath, 'r') as fb:
        verStr = fb.read()
        verStr = verStr.strip() #取消末尾的‘\n’

    return verStr

def writeFile( filePath, data):
    with open( filePath, "w" ) as fb:
        fb.write( data )

def getNextVersion( ver ):
    return ver + 1

def makePatchData( pid, gitHash ):
    patchData = {}
    # patchData[ "clean" ]    = 0
    # patchData[ "restart"]   = 0
    patchData[ "reboot"] = False
    patchData[ "pid" ] = pid
    patchData[ "hash" ] = gitHash

    if len( config.REBOOT_INFOS ) >= config.B_ID + 1:
        rebootInfos = config.REBOOT_INFOS[ config.B_ID ]
        if str( pid ) in rebootInfos.keys():
            patchData[ "reboot" ] = rebootInfos[str( pid )]

    return patchData

def makeDiffFileToPack( gitHash, gitSocurePath, packerPath, fileDir ):
    rootPath = config.rootPath
    # 计算出文件的完整路径
    prjFilePath = os.path.join( rootPath, gitSocurePath ) + os.sep

     # 通过git获取到src文件的差异数据
    cmd = "git diff %s HEAD --name-only |grep -e %s" % ( gitHash, gitSocurePath )
    cmd = cmd.replace( os.sep, "/") #换行符号的处理 在git命令中 路径分隔符是必须使用 /的 
    # print( " cmd: %s" % cmd)
    fd = os.popen( cmd )
    # print( fd.read() )
    # 找出差异文件 并将当前版本中存在的文件放入文件差异列表中
    # filelist = []
    
    changed = False
    for line in fd.readlines():
        path = line.strip()
        filePath = path.replace( "/", os.sep)
        filePath = os.path.join( rootPath, filePath)
        # 删除文件，不算是更新
        if os.path.exists( filePath ):
            # 得出文件的相对路径
            pathList = filePath.split( prjFilePath , 1)
            if len( pathList ) <= 1 :
                continue

            relativePath = pathList[1]  # src目录下的 相对目录 xx\xx\xx.ext
            
            toPackPath = os.path.join( packerPath, fileDir, relativePath )
            toPackPath = os.path.dirname( toPackPath ) # 去扩展名

            # 将文件拷贝到_toPack目录
            sufix = os.path.splitext( filePath )
            # 排除meta文件
            if len( sufix ) == 2 and sufix[1] != ".meta":
                if not os.path.exists( toPackPath ):
                    os.makedirs( toPackPath )
                shutil.copy( filePath, toPackPath )
                changed = True
    fd.close()

    return changed


def makePatcher( gitHash, version, patcherDir):
    # 计算出git的比较用的目录
    rootPath = config.rootPath + os.sep
    # print( "rootPath: %s" % rootPath)
    src = config.srcReleasePath.split( rootPath, 1)[1]
    res = config.resReleasePath.split( rootPath, 1)[1]

    # 临时存放文件目录
    toPackPath = os.path.join( patcherDir, "_toPack") #patch_data\and\_toPack\
    # print( "toPackPath:%s" % toPackPath)
    # 删除该删的文件
    if os.path.exists( toPackPath ):
        shutil.rmtree( toPackPath )

    # os.system( "pause")

    changed1 = makeDiffFileToPack( gitHash, src, toPackPath, "" )
    changed2 = makeDiffFileToPack( gitHash, res, toPackPath, "" )

    if not changed1 and not changed2:
        print( "------> No File Changed." )
        return False

    # os.system( "pause")

    zipMode = "7z"
    if sys.platform != "win32":
        zipMode = "mac"

    print("platform:%s    zip mode:%s" % (sys.platform, zipMode))

    # 创建补丁zip文件
    zipName = "%s.zip" % version
    zipPath = os.path.join( patcherDir, zipName )
    if zipMode == "7z":
        zipExePath = os.path.join( "common", "7za", "7za" )
        cmdZipPath = "%s a -tzip %s" % (zipExePath, zipPath)

        if changed1:
            cmd = "%s %s*" % (cmdZipPath, os.path.join(toPackPath, "" ))
            os.system(cmd)

        if changed2:
            cmd = "%s %s*" % (cmdZipPath, os.path.join(toPackPath, "" ))
            os.system(cmd)
    elif zipMode == "mac":
        if changed1:
            cmd = "zip -q -r -o -j %s %s" % (zipPath, os.path.join(toPackPath, "" ))
            os.system(cmd)

        if changed2:
            cmd = "zip -q -r -o -j %s %s" % (zipPath, os.path.join(toPackPath, "" ))
            os.system(cmd)
    else:
        zipExePath = os.path.join( "common", "SharpZip", "SharpZip" )

        compressLevel = 6

        if changed1:
            cmd = "%s -c %s %s %s" % ( zipExePath, os.path.join(toPackPath, "" ), zipPath, compressLevel )
            os.system(cmd)

        if changed2:
            cmd = "%s -c %s %s %s" % ( zipExePath, os.path.join(toPackPath, "" ), zipPath, compressLevel )
            os.system(cmd)


    # --删除该删的文件
    if os.path.exists( toPackPath ):
        shutil.rmtree( toPackPath )

    return True


# 初始化创建一个patch_info.json文件
def createPatchinfoFile():
    patchinfojson = {}
    patchinfojson[ "P_ID" ]      = config.P_ID
    patchinfojson[ "PATCH_LIST"] = []

    return patchinfojson

def syncPatchdata( patchinfojson ):
    patchinfojson[ "APP"]                  = config.APP
    patchinfojson[ "B_ID" ]                = config.B_ID
    patchinfojson[ "VERESION" ]            = config.VERESION
    patchinfojson[ "HOST" ]                = config.HOST
    patchinfojson[ "PATCH_PATH" ]          = config.PATCH_PATH
    patchinfojson[ "PATCH_INFO_FILENAME" ] = config.PATCH_INFO_FILENAME

    if config.HOST_CDN != None:
        patchinfojson[ "HOST_CDN" ] = config.HOST_CDN

    # 所有渠道可更新补丁信息
    if len( config.CHANNEL_INFOS ) >= config.B_ID + 1:
        patchinfojson[ "CHANNEL_INFO" ] = config.CHANNEL_INFOS[ config.B_ID ]











########## 菜单事件 ##########
def doMakePatch():
    print( "------> begin maker patcher!" )

    workPath = os.path.join( config.pathDataPath, str( config.B_ID ) )

    #源 patchinfo地址
    savePatchInfoPath = os.path.join( workPath, config.PATCH_INFO_FILENAME )
    jsonStr = readFile( savePatchInfoPath )
    if jsonStr == None or jsonStr.isspace():
        # print( "please create \'patch_info.json\' file to path: %s" % workPath)
        # 新版本 从头开始
        patchinfojson = createPatchinfoFile()
    else:
        patchinfojson = json.loads( jsonStr )
    

    syncPatchdata( patchinfojson )



    # 取出当前版本中的大版本信息
    bigVersion = patchinfojson.get( "B_ID" )
    version    = patchinfojson.get( "P_ID")
    # 最后一次打补丁的githash值 用于和现在的githash值进行比较 用于生产差异文件
    gitHash    = patchinfojson.get( "GIT_HASH")

    # 如果补丁保存目录不存在 则创建目录
    if not os.path.exists( workPath ): 
        os.makedirs( workPath )

    # 取出当前最新的githash值
    output = os.popen("git rev-list HEAD -n 1")
    gitHashNew = output.read().strip()
    output.close()

    # 计算出新的补丁号 用于保存到patchinfo中
    versionNew = getNextVersion(version)

    print( "------> bigVersion is: %s" % bigVersion )
    print( "------> oldVersion is: %s" % version )
    print( "------> newVersion is: %s" % versionNew )
    
    if gitHash == None or gitHash == "":
        print( "------> git hash empty")
        # patchinfojson[ "HOST" ]  = config.patchUrl
        patchinfojson[ "PATCH_LIST" ] = []
        patchinfojson[ "GIT_HASH" ] = gitHashNew
    else:
        if makePatcher(gitHash, versionNew, workPath):
            print( "------> add a new version")

            # 记录下当前版本的信息
            patchinfojson["PATCH_LIST"].append( makePatchData( versionNew, gitHashNew ) )
            patchinfojson[ "P_ID" ]     = versionNew
            patchinfojson[ "GIT_HASH" ] = gitHashNew

    jsonStr = json.dumps( patchinfojson )
    # 将版本信息心如 patcher
    writeFile( savePatchInfoPath, jsonStr )
    shutil.copy( savePatchInfoPath, os.path.join( config.releasePath, config.PATCH_INFO_FILENAME) )

    print("------> make patch completed")











########## 菜单相关 ##########
def selectChannel():
    print("")
    print(u"欢迎来到make")
    print(u"  首先，需要选择一个cfg")
    print("")

    dirs = os.listdir( config.pathDataPath )
    menuitems = []
    for dirname in dirs:
        path = os.path.join(config.pathDataPath, dirname)
        if os.path.isdir( path ):
            menuitems.append( dirname )
    menuitems.append("exit")

    for k, v in enumerate(menuitems):
        print( "       %d. %s" % (k + 1, v) )

    print( "" )

    result = raw_input("input option:")

    if not result.isdigit():
        return 0

    idx = int(result) 
    if idx > len(menuitems) or idx < 1 :
        print( "Selection is error, please re-select! your selected idx == %s" % idx)
        return 0
    elif idx == len(menuitems):     #选择最后一项exit
        return -1
    else:
        # 执行打包流程
        # 当前选择的版本
        # path = os.path.join(config.pathDataPath, menuitems[ idx - 1])
        return menuitems[ idx - 1]

def main():    
    # 处理configPath
    # if len(sys.argv) < 1:
    #     print("config path nof found!")
    #     return

    # configPath = sys.argv[1]
    # sys.path.append(configPath)
    global config
    import cfg_patch as config

    doMakePatch()

    # os.system( "pause")



main()

