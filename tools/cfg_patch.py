#!/bin/python
# -*- coding: utf-8 -*-

# 
#   游戏发布、打包、打补丁的配置文件
#   rootPath:   脚本运行的根目录 
#   prjectPath: 项目目录
#   srcPath:    游戏脚本目录
#   resPath:    游戏资源目录
#   srcReleasePath:   发布脚本目录
#   resReleasePath:   发布资源目录
#   verExportPath:    ver.json发布目录
#

import os
import sys

rootPath = os.path.join("..")
prjectPathName = "wumai"

# 修改后需要boot的文件的正则表达式
# bootReps = [
# 	r"^%s" % os.path.join("src", "updater", ".*"),
# ]


# 压缩和编译后的路径
releasePath			= os.path.join( rootPath, "Assets", "PublishAssets" )
srcReleasePath		= os.path.join( rootPath, "Assets", "StreamingAssets" )
resReleasePath		= os.path.join( releasePath )


# 本地补丁根目录
pathDataPath		= os.path.join( rootPath, "_build", "patch_data" )




# 补丁下载相关的配置


# 下载patchUrl
HOST = "h005.ultralisk.cn:4022"
HOST_CDN = "h005up.ultralisk.cn"


# 补丁库根目录
PATCH_PATH = "u3d_patch"


# 项目补丁目录
APP  = "wumai"


# patchinfo文件名
PATCH_INFO_FILENAME = "patch_info.json"


# http://h005.ultralisk.cn:4022/u3d_patch/game_name/0/patch_info.json
# http://HOST/PATCH_PATH/APP/B_ID



# 初始版本号(新补起始号)
P_ID = 0


# 当前大版本号(大版本只能从0开始，且只能一级一级升)
B_ID = 0


# 当前版本号：运营版本号
VERESION = "1.0.0"



# 配置每个大版本各个渠道可更新到的最后小版本，默认不自动更新
# 若想每次自动更新而不必修改版本号，则可配置一个足够大的版本号，例如: 99999
CHANNEL_INFOS = [
	# 大版本: 0
	{
		"ultralisk": 9999,
	},
	# 大版本: 1
	{
		"ultralisk": 9999,
	},
	# 大版本: 2
	{
		"ultralisk": 9999,
	},
	# 大版本: 3
	{
		"ultralisk": 9999,
	},
	# 大版本: 4
	{
		"ultralisk": 9999,
	},
	# 大版本: 5
	{
		"ultralisk": 9999,
	},
	# 大版本: 6
	{
		"ultralisk": 9999,
	}
]


# 每个版本是否需要重启
REBOOT_INFOS = [
	# 大版本: 0
	{},
	# 大版本: 1
	{},
	# 大版本: 2
	{},
	# 大版本: 3
	{},
	# 大版本: 4
	{},
	# 大版本: 5
	{},
	# 大版本: 6
	{}
]