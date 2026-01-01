export BUILD_PROG_VERSION="v1.0.0"
export BUILD_PROG_WORKING_DIR=$PWD
export ANDROID_HOME_DIR=$HOME/android-sdk
export CLI_FILE_NAME="commandlinetools-linux-13114758_latest.zip"
export SDK_MANAGER="${ANDROID_HOME_DIR}/cmdline-tools/latest/bin/sdkmanager"
export TARGET_ARCH="aarch64"

echo "Initializer..."
case "${TARGET_ARCH}" in
    aarch64)
        export NDK_FILE="android-ndk-r28c-aarch64-linux-musl.tar.xz"
        export AAPT_FILE="android-sdk-tools-static-aarch64.zip"
        ;;
    arm)
        export NDK_FILE="android-ndk-r28c-arm-linux-musleabi.tar.xz"
        export AAPT_FILE="android-sdk-tools-static-arm.zip"
        ;;
    x86)
        export NDK_FILE="android-ndk-r28c-x86-linux-musl.tar.xz"
        export AAPT_FILE="android-sdk-tools-static-x86.zip"
        ;;
    x86_64)
        export NDK_FILE="android-ndk-r28c-x86_64-linux-musl.tar.xz"
        export AAPT_FILE="android-sdk-tools-static-x86_64.zip"
        ;;
esac

cil_yesandno() {
    local default_opt="$1"
    local prompt_text="$2"
    local prompt_suffix=""
    local valid_input=0
    local result=""
    
    # 设置提示后缀和默认值
    case "$default_opt" in
        1) prompt_suffix="(Y/n) " ;;
        2) prompt_suffix="(y/N) " ;;
        0) prompt_suffix="(y/n) " ;;
        *) prompt_suffix="(y/n) " ;;
    esac
    
    # 循环直到获得有效输入
    while [[ $valid_input -eq 0 ]]; do
        echo -n "$prompt_text $prompt_suffix"
        read -r user_input
        
        # 处理空输入（使用默认值）
        if [[ -z "$user_input" ]]; then
            case "$default_opt" in
                1) result="y"; valid_input=1 ;;
                2) result="n"; valid_input=1 ;;
                0) 
                    echo -e "\e[1;31m错误：没有默认选项，请输入 y 或 n\e[0m"
                    continue
                    ;;
            esac
        else
            # 处理非空输入
            case "${user_input,,}" in  # 转换为小写比较
                y|yes) result="y"; valid_input=1 ;;
                n|no)  result="n"; valid_input=1 ;;
                *) 
                    echo -e "\e[1;31m错误：请输入 y 或 n\e[0m"
                    continue
                    ;;
            esac
        fi
    done
    
    # 返回结果 (0=yes, 1=no)
    if [[ "$result" == "y" ]]; then
        return 0
    else
        return 1
    fi
}

cil_choose() {
    local option_count="$1"
    local default_id="$2"
    local prompt_text="$3"
    shift 3

    local options=("$@")
    local option_codes=()
    local option_texts=()
    local valid_input=0
    local user_choice=""
    local default_code=""

    # 验证选项数量不超过255
    if [[ $option_count -gt 255 ]]; then
        echo -e "\e[1;31m错误：选项数量不能超过255\e[0m"
        return 1
    fi

    # 解析选项
    for ((i=0; i<option_count; i++)); do
        local option="${options[i]}"
        # 使用第一个 "-" 作为分隔符
        local code="${option%%-*}"
        local text="${option#*-}"
        
        option_codes[i]="$code"
        option_texts[i]="$text"
    done

    # 设置默认选项代码
    if [[ $default_id -gt 0 ]] && [[ $default_id -le $option_count ]]; then
        default_code="${option_codes[$((default_id-1))]}"
    fi

    # 构建选项显示字符串
    local option_display=""
    for ((i=0; i<option_count; i++)); do
        local code="${option_codes[i]}"
        local text="${option_texts[i]}"
        
        if [[ -n "$option_display" ]]; then
            option_display="$option_display, "
        fi
        option_display="$option_display[$code]$text"
    done

    # 构建默认提示
    local default_prompt=""
    if [[ -n "$default_code" ]]; then
        default_prompt=" (Default: $default_code)"
    else
        default_prompt=" (Default: NONE)"
    fi

    # 显示提示信息
    echo -n "$prompt_text $option_display$default_prompt: "

    # 交互循环
    while [[ $valid_input -eq 0 ]]; do
        read -r user_choice
        
        # 处理空输入（使用默认值）
        if [[ -z "$user_choice" ]]; then
            if [[ -n "$default_code" ]]; then
                # 返回默认选项的ID
                return $default_id
            else
                echo -e "\e[1;31m错误：没有默认选项，请选择一个选项\e[0m"
                echo -n "请选择: "
                continue
            fi
        fi
        
        # 验证输入（不区分大小写）
        user_choice_upper="${user_choice^^}"  # 转换为大写
        
        for ((i=0; i<option_count; i++)); do
            code_upper="${option_codes[i]^^}"  # 选项代码也转换为大写比较
            
            if [[ "$user_choice_upper" == "$code_upper" ]]; then
                valid_input=1
                # 返回选项ID（从1开始）
                return $((i + 1))
            fi
        done
        
        # 如果到这里，说明输入无效
        echo -e "\e[1;31m错误：无效选项 '$user_choice'，请从 [${option_codes[*]}] 中选择\e[0m"
        echo -n "请选择: "
    done
}

echo "Get Package..."

apt update -y

apt install wget git openjdk-17 zip -y
export JAVA_HOME=$PREFIX/lib/jvm/java-17-openjdk/

echo "Prepare dictionary..."

cd $BUILD_PROG_WORKING_DIR

cd $HOME
if [[ ! -d ${ANDROID_HOME_DIR} ]]; then
    mkdir $ANDROID_HOME_DIR
fi
cd $ANDROID_HOME_DIR

echo "Download file..."
echo "For Chinese:"
echo "如果你能看得懂的话！请仔细阅读这个！"
echo "如果你遇到下载慢甚至根本无法下载的问题，请使用VPN"
echo "程序将在3秒后继续..."
echo "The program will continue in 3 seconds..."

sleep 3

# 下载sdk
if [[ ! -f ${ANDROID_HOME_DIR}/${CLI_FILE_NAME} ]]; then
    wget https://dl.google.com/android/repository/${CLI_FILE_NAME}
    unzip ${ANDROID_HOME_DIR}/${CLI_FILE_NAME}
    rm -rfv ${ANDROID_HOME_DIR}/${CLI_FILE_NAME}
fi

# 移动文件
echo "Move File..."
if [[ ! -d ${ANDROID_HOME_DIR}/cmdline-tools/latest ]]; then
    cd ${ANDROID_HOME_DIR}/cmdline-tools
    mkdir latest
    mv -v * latest
    cd ${ANDROID_HOME_DIR}
fi

# 准备环境变量
echo "Set Environment Variables..."
export ANDROID_HOME=${ANDROID_HOME_DIR}

echo "Consent Permission in..."
yes | ${SDK_MANAGER} --licenses

echo "Install SDK components..."
${SDK_MANAGER} "platforms;android-34" "platform-tools" "build-tools;34.0.0"

echo "Install Android ndk..."
mkdir ${ANDROID_HOME_DIR}/ndk
if [[ -d ${ANDROID_HOME_DIR}/ndk/28.2.13676358 ]]; then
    cil_yesandno 1 "You have installed ndk, do you want to continue? (Will be reinstalled)"
    if [[ $? -eq 0 ]]; then
        rm -rfv ${ANDROID_HOME_DIR}/ndk/28.2.13676358
        rm -rfv ${ANDROID_HOME_DIR}/28.2.13676358
    else
        echo "Then the program terminates."
        exit
    fi
fi

if [ ! -f "${ANDROID_HOME_DIR}/${NDK_FILE}" ]; then
    wget https://github.com/kgultrt/SystemShellBox-Package/releases/download/ndk/${NDK_FILE}
fi

cd ${ANDROID_HOME_DIR}/ndk
tar --no-same-owner -vxf "${ANDROID_HOME_DIR}/${NDK_FILE}" --warning=no-unknown-keyword
mv android-ndk-r28c 28.2.13676358
rm -rfv ${ANDROID_HOME_DIR}/${NDK_FILE}


cd ${BUILD_PROG_WORKING_DIR}
echo "Install some necessary files..."
mkdir -p $HOME/.gradle
cp ${BUILD_PROG_WORKING_DIR}/gradle.properties $HOME/.gradle

echo "Preparation of aapt..."
mkdir -p $HOME/.androidide
mkdir -p $HOME/.androidide/android.jar
cd $HOME/.androidide

if [[ ! -f ${AAPT_FILE} ]]; then
    wget https://github.com/lzhiyong/android-sdk-tools/releases/download/35.0.2/${AAPT_FILE}
    unzip ${AAPT_FILE}
    rm -rfv ${AAPT_FILE}
fi

cp $HOME/.androidide/build-tools/aapt2 $HOME/.androidide

echo "Build an empty project!"
cd ${BUILD_PROG_WORKING_DIR}
unzip project.zip
cd ${BUILD_PROG_WORKING_DIR}/project
bash gradlew "app:assembleDebug" --console=verbose

echo "Set Environment Variables (to file)..."
echo "export ANDROID_HOME=${ANDROID_HOME_DIR}" >> $PREFIX/etc/bash.bashrc

echo "Succees."
echo "Now you just need to quit Termux and restart it to use it."
echo "现在你只需要退出Termux，然后再重启它就可以用了"