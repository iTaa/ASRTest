prjName=$1
ipaPath=$2
environment=$3

uploadCmd="$PWD/sh/uploadToRemote.sh"
submitCmd="$PWD/sh/submitToAppSotre.sh"

remoteUser="cms"
remotePassword="chinapnr"                       # 修改服务器密码
remoteIP="192.168.3.41"
remotePath="/newapp/mobile/iPhone/$prjName"

itunesAccount="david.yi@chinapnr.com"               # 修改itunesconnect的密码
itunesPassword="Shanghai2013"

# 进入目录，准备工作
cd $ipaPath

# 解析ipa名称
ipaName=`ls -lt *.ipa | awk '{print $9}' | head -1`
ipaName=`basename $ipaName | awk -F '.ipa' '{print $1}'`

# 是否解析出ipa文件
if [ "x"$ipaName = "x" ]; then
    echo "Can NOT parse ipa's name, something went wrong."
    rm -rf *.ipa
    rm -rf *.dSYM
    exit 1
fi

# 上传ipa及dSYM文件
if [ "x"$environment = "xappstore" ]; then
    # 上传到AppSotre
#    $submitCmd "$ipaName".ipa "$itunesAccount" "$itunesPassword"
    echo "unable submit to AppStore right now, please use ApplicationLoader manually."
    echo "IPAFilePath is: ($PWD/$ipaName.ipa)"
    exit 0
else
    # 上传到测试服务器
    $uploadCmd "$ipaName".ipa "$remoteUser"@"$remoteIP":"$remotePath" $remotePassword
    $uploadCmd "$ipaName".dSYM "$remoteUser"@"$remoteIP":"$remotePath" $remotePassword
fi

# 清理现场
rm -rf *.ipa
rm -rf *.dSYM



