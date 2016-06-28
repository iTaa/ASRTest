environment=$1

prjName="ASR"          # 修改工程名称

pwdPath=$PWD

cd `dirname $0`

buildCmd="sh/build.sh"
uploadCmd="sh/upload.sh"
submitCmd="sh/submit.sh"

# 进入工作目录，准备工作
cd ..

# 清除IPA文件夹的内容和编译的中间文件
rm -rf ./ipa/*
rm -rf ./Build

# 开始编译安装包
$buildCmd "$PWD" "$PWD/ipa" $environment

# 编译失败
if [ "x"$? = "x1" ]; then
    rm -rf ./ipa/*
    exit 1
fi

# 上传
$uploadCmd $prjName "$PWD/ipa" $environment



