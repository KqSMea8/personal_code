#!/bin/bash

function usage()
{
    echo "USAGE: $1" 
    echo -e "\t-m <module_name>\t����, ģ��Ŀ¼��" 
    echo -e "\t-c <conf_file>\t\t��ѡ, ģ��confĿ¼�������ļ���, Ĭ��Ϊmodule.conf"
    echo -e "\t-h <help>\t\t��ӡUsage"
}

export WORK_ROOT=$(cd "$(dirname "$0")"; pwd)
DEFAULT_CONF_FILE=module.conf

module_name=""
conf_file=""
while getopts :m:c:h opt; do
    case ${opt} in
    m) 
    module_name=$OPTARG
    ;;
    c) 
    conf_file=$OPTARG
    ;;
    h)
    usage `basename $0` 
    exit 0
    ;;
    \?) echo "invalid argument -"${OPTARG}
    usage `basename $0`
    exit 1
    ;;
    esac
done

if [ -z ${module_name} ]; then
    echo "missing module name"
    usage `basename $0`
    exit 1
fi

if [ -z ${conf_file} ]; then
    conf_file=${DEFAULT_CONF_FILE}
    echo "conf file has not set yet! use [${conf_file}] as default"
fi

conf_full_path=${WORK_ROOT}/${module_name}/conf/${conf_file}
if [ ! -f "${conf_full_path}" ]; then
    echo "module conf [${conf_full_path}] not found!"
    exit 1
fi
source ${conf_full_path}

if [ ! -d "${LOCAL_DATA_PATH}" ]; then
    echo "data_path [${LOCAL_DATA_PATH}] are not dictionary!"
    exit 1
fi

# stop all proc process
running_flag_files=${LOCAL_DATA_PATH}/flag.${module_name}.*.running
cat ${running_flag_files} | xargs kill -9
rm -f ${running_flag_files}

exit 0