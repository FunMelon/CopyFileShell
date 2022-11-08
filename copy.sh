# name: 文件复制脚本
# parameter: s 源文件夹
# parameter: t 目标文件夹
# author: 李爱卿
# class: 计科2004班
# id: 8208200913

echo -e "\e[36mStart the shell program... \e[0m"

# 变量
source_path="./"
target_path="../res"

declare -A existSuffix  # 设置关联数组来存文件后缀

# 函数
createFolder(){
  if [ ! -d ${1} ]  # 检查文件夹是否存在
  then
    mkdir ${1}
    echo "${1} did not exist, create."
  fi
}

createFile(){
  if [ ! -e ${1} ]  # 检查文件是否存在
  then
    touch ${1}
    echo "${1} did not exist, create."
  fi
}

# parameter: 1 源路径
# parameter: 2 目标路径
# parameter: 3 文件名称（去尾）
# paremeter: 4 文件编号
# paremeter: 5 文件类型
copyHelper() {
  if [[ ${4} == "0" ]] && [ ! -e ${2}"/"${3}${5} ]  # 检查文件是否存在
  then  # 最简单的情况，第一次出现
    echo -e "\e[32mcopy ${1} to ${2}/${3}${5} \e[0m"
    echo "copy ${1} to ${2}/${3}${5}" >> ${analysis}
    cp ${1} ${2}"/"${3}${5}
  elif [ ! -e ${2}"/"${3}${4}${5} ]
  then  # 第二次出现
    echo -e "\e[32mcopy ${1} to ${2}/${3}${4}${5} \e[0m"
    echo "copy ${1} to ${2}/${3}${4}${5} " >> ${analysis}
    cp ${1} ${2}"/"${3}${4}${5}
  else  # 第N次出现
    copyHelper ${1} ${2} ${3} `expr ${4} + 1` ${5}
  fi
}

copyFile(){  # 文件复制函数，参数为源文件夹地址
  echo "Enter folder ${1}"

  for file in `ls ${1}`  # 反引号获取命令执行结果
  do
    if [ -d $1"/"${file} ]  
    then  # 文件夹递归
      copyFile $1"/"${file}
    else  #文件复制
      # echo -e "\e[34m${file##*.} \e[0m"
      # 1.检查后缀文件是否存在，不存在则加入
      if echo "${!existSuffix[@]}" | grep -w ${file##*.} &>/dev/null;
      then
        :
      else  # 第一次发现该后缀
        if [ ! -d ${target_path}"/"${file##*.} ]  # 原有文件夹不存在
        then
          existSuffix[${file##*.}]=${target_path}"/"${file##*.}
        else
          existSuffix[${file##*.}]=${target_path}"/"${file##*.}"_lab"
        fi
        createFolder ${existSuffix[${file##*.}]}  # 暴力创建文件夹
      fi
      # 2.复制文件
      copyHelper ${1}"/"${file} ${existSuffix[${file##*.}]} ${file%.*} 0 "."${file##*.}
    fi
  done

  echo "Finish copy folder ${1}"
}

# 检查参数
while getopts ":s:t:" opt
do
  case $opt in
    s)
      source_path=${OPTARG}
      ;;
    t)
      target_path=${OPTARG}
      ;;
    ?)
      echo -e "\e[41mInvaild argument ${OPTARG}"
      exit 1
      ;;
  esac
done

echo -e "\e[33msource path is ${source_path} \e[0m" 
createFolder ${target_path}
echo -e "\e[33mtarget path is ${target_path} \e[0m" 
echo "begin copy..."

# 添加analysis.txt文件
analysis=${target_path}"/analysis.txt"

createFile ${analysis} 
echo "" > ${analysis}

copyFile ${source_path}

column -t ${analysis} | less -SN

echo -e "\e[33mAll file suffixes are: \n${!existSuffix[*]}\e[0m"
echo -e "\e[36mExit the shell program. \e[0m"
