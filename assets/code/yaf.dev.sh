#!/usr/bin/env bash
#####################
## 自动编译安装YAF 开发环境[dev]
#####################
PHP_PATH=${PHP_PATH:=php}
TEMP_PATH=${TEMP_PATH:="/tmp/"}

# 获取PHP版本
# GET PHP version
PHP_VERSION=$("$PHP_PATH" -v|grep --only-matching --perl-regexp "\d\.\d+\.\d+"|head -1);
if [[ ${PHP_VERSION} == "7."* ]]; then
    YAF_VERSION=yaf-3.0.3 #php 7
else
    YAF_VERSION=yaf-2.3.5 #php 5 
fi;

# 下载解压yaf
# download yaf
curl https://pecl.php.net/get/${YAF_VERSION}.tgz | tar zx -C "$TEMP_PATH"
# 编译安装 YAF
# compile and install YAF
cd "${TEMP_PATH}/${YAF_VERSION}" && phpize;
./configure && make && sudo make install

## 创建yaf配置文件
## create temp yaf file
cat <<EOF>"$TEMP_PATH/yaf.ini"
extension=yaf.so
[yaf]
yaf.environ=dev
EOF
# 获取 PHP ini 配置目录
# Scan for additional .ini path
PHP_INI_PATH=$("$PHP_PATH" --ini|grep --only-matching --perl-regexp  "/.*\.d$"|sed -r -e 's/cli/*/')
# 复制配置文件到各个目录
# cp the yaf configure to each file 
echo $PHP_INI_PATH | xargs -n 1 sudo cp "$TEMP_PATH/yaf.ini" 
# 删除临时文件
# remove temp ini
rm "$TEMP_PATH/yaf.ini"