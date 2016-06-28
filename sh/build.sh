pwdPath=$PWD

prjPath=$1
outPath=$2

# 解析工程名称
prjName=`find "$prjPath" -maxdepth 1 -name *.xcworkspace`
prjName=`basename "$prjName"`
prjName=${prjName%.*}

# 进入源代码包
cd "$prjPath"

# 删除编译文件
# rm -rf ./Build

# 环境
if [ "x"$3 = "x" ]; then
    envriment="test"
else
    envriment=$3
fi

# 编译配置
budConf="-xcconfig ./$envriment.xcconfig"

# 编译文件
mkdir ./Build
xcodebuild -workspace "$prjName".xcworkspace -scheme "$prjName" -configuration 'Release' $budConf -derivedDataPath ./Build > ./Build/build.log 2>&1

# 判断是否编译完成
if [ ! -d ./Build/Build/Products/Release-iphoneos/"$prjName".app.dSYM ]; then
    echo "***build failed, please make sure Provisioning & Cert & Coding is correct."
    cd "$pwdPath"
    exit 1
fi

# 进入编译生成目录
cd ./Build/Build/Products/Release-iphoneos/

# 解析版本号
versionNumber=`plutil -p $prjName.app/Info.plist | sed -n '/CFBundleShortVersionString/p' | awk '{print $3}'`
versionNumber=${versionNumber//"\""/""}
buildNumber=`plutil -p $prjName.app/Info.plist | sed -n '/CFBundleVersion/p' | awk '{print $3}'`
buildNumber=${buildNumber//"\""/""}

# 提取保存的文件名
fleName=`basename "$prjPath"`
fleName="$prjName"_"$fleName"_v"$versionNumber"_iPhone_build"$buildNumber"_"$envriment"
fleName=${fleName//" "/"_"}

# 生成ipa及dSYM
xcrun -sdk iphoneos PackageApplication -v ./"$prjName".app -o "$outPath"/"$fleName".ipa > /dev/null 2>&1
mv ./"$prjName".app.dSYM "$outPath"/"$fleName".dSYM > /dev/null 2>&1

# 清理工作现场
cd ../../../../
rm -rf ./build.log
rm -rf ./Build
cd "$pwdPath"
