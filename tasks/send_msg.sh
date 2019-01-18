#!/bin/bash

send_mail_msg()
{
# �����ʼ���ͨ�ó���
# �÷���send_mail_msg -t "����������" -s "��Ҫ�ʼ�����"  -p "����������"
# ������
# 	-t: RDֻ��Ҫ�ṩwarninglevel�����еı�������ȡֵΪ0-3���ű����Զ���ȡ�ü�����ռ���Ϣ��
# 	-s: RDֻ��Ҫ�ṩ��ؼ��ģ����� [��Ҫ������Ϣ] ���ɡ����� [���][ģ����][ʱ��]  ��Ϣ�ɽű��Զ���ȫ
# 	-p: Ҫô��һ�м򵥵����������ģ�Ҫô��һ�������ļ������ļ������޺�׺����ʹ��mail���ͣ������.txt��.html�ļ�������sendmail����

# ����ֵ��
#  0: �������� 
# -1: ������������
# -2: ������ԣ���û��-t,-s,-p�Ȳ�����
# -3: �ʼ������ʽ�����Ϲ淶
# -4: �к�׺�ĸ��������ļ���׺���ԣ�����к�׺�ɱ���Ϊhtml��txt��
# -5: �����к�׺�����ʼ�ʱ����
# -6: �����޺�׺�����ʼ�ʱ����
# -7: ���������ʼ�ʱ����
# -8: �����ļ�warninglevelλ�ò��Ի򲻴���


local FUNC_NAME="send_mail_msg"

# check parameter 
if [ $# -ne 6 ];then
	echo "$FUNC_NAME parameter error!"
	echo "Usage: $FUNC_NAME -t "����������" -s "��Ҫ�ʼ�����" -p '����������' "
	return -1
fi

# ��ȡ����
OPTIND=1
while getopts "t:s:p:" opt;
do
	case "$opt" in
		t) opt_t=$OPTARG;
		;;
		s) opt_s=$OPTARG;
		;;
		p) opt_p=$OPTARG;
		;;
		*) echo "parameter item error!"; return -2;
		;;
	esac
done

# ���warninglevel�У�ģ�����Ƿ�Ϊ����
if [ -z "${MODULE_NAME}" ];then
        echo "the conf item MODULE_NAME is black"
        return -8
fi

# �жϱ�������
if [ "$opt_t" -ge ${LEVEL_NUM} -o "$opt_t"  -ge 4 ];then
	echo "warnling level error!,must be 0-3"
	return -1
fi
case "${opt_t}" in
	"0") _WARNAME=${LEVEL_0_NAME};	_MAILIST=${LEVEL_0_MAILLIST};	_GSMLIST=${LEVEL_0_GSMLIST};
	;;
	"1") _WARNAME=${LEVEL_1_NAME};	_MAILIST=${LEVEL_1_MAILLIST};	_GSMLIST=${LEVEL_1_GSMLIST};
	;;
	"2") _WARNAME=${LEVEL_2_NAME};	_MAILIST=${LEVEL_2_MAILLIST};	_GSMLIST=${LEVEL_2_GSMLIST};
	;;
	"3") _WARNAME=${LEVEL_3_NAME};	_MAILIST=${LEVEL_3_MAILLIST};	_GSMLIST=${LEVEL_3_GSMLIST};
	;;
	"*") echo "parameter item error!"; return -2;
        ;;	
esac
local warnlevel=`echo $_WARNAME | tr [A-Z] [a-z]`
if [ X${warnlevel} = X"stat" ];then
	_DATE=`date +%Y%m%d`
else
	_DATE=`date +%H:%M:%S`
fi

_SUBJECT="[${_WARNAME}][${MODULE_NAME}][${opt_s}][${_DATE}]"

# �򵥼���ռ����Ƿ�淶������Ǹ��ˣ�����ú�������
for tmpi_Qz4_tUw9Pg in  ${_MAILIST};do
        echo ${tmpi_Qz4_tUw9Pg} | grep -E 'spi|mon|-' &>/dev/null
        if [ $? -ne 0 ];then
                check_host_valid "${_MAILIST}"
    			break
	    fi
done

# # ���ض�����ı����ʼ����뵽EIPϵͳ��Ĭ�ϵ���Error,Fatal���ʼ����������Сд��
# local maillevel=`echo $opt_s | awk -F']' '{print $1}' | sed 's/\[//g' | tr -s [A-Z] [a-z] `
# if [ $maillevel = "error" -o $maillevel = "fatal" ];then
#        /bin/mail_to_eip -s ${opt_s}
#        if [ $? -ne 0 ];then
#                echo "ERROR! �����ʼ�����EIPʱ��������"
#        fi
# fi


# �жϵ����������������ݻ����ļ���������ļ������һ��ȷ���Ƿ����׺
if [  -z "$opt_p" ];then
	# ���������ݲ���Ϊ��
        mail -s "${_SUBJECT}" "${_MAILIST}" < /dev/null
	if [ $? -eq 0 ];then
                return 0
        else
                echo "���������ʼ�ʱ��������"
                return -7
        fi
fi

if [ -f "$opt_p" ];then
        # �ò���Ϊ�ļ����жϺ�׺
	file_name=`echo "$opt_p" | awk -F'/' '{print $NF}'`
	echo $file_name | grep '\.' &>/dev/null
	if [ $? -eq 0 ];then
		# ����׺
		sub_fix=`echo $file_name | awk -F'.' '{print $NF}' | tr [A-Z] [a-z]`
		if [ $sub_fix != "html" -a $sub_fix != "txt" ];then
			echo "���������ļ���׺��Ϊhtml��txt"
			return -4
		fi
		# �����ʼ�	
	   cat "$opt_p" | formail -I "MIME-Version:1.0" -I "Content-type:text/html" -I "Subject:${_SUBJECT}" -I "To:${_MAILIST}" |/usr/sbin/sendmail -oi "${_MAILIST}"
		if [ $? -eq 0 ];then
			return 0
		else
			echo "���ʹ���׺�����ʼ�ʱ��������"
			return -5
		fi
	else
		# ����������׺��ֱ��mail�����ʼ�
		cat "$opt_p" | mail -s "${_SUBJECT}" "${_MAILIST}"
		if [ $? -eq 0 ];then
                        return 0
                else
                        echo "�����޸����ʼ�ʱ��������"
	                return -6
                fi
	fi

else
	# �ò���Ϊ���ݣ�ֱ�ӷ����ʼ�	
        echo "$opt_p" | mail -s "${_SUBJECT}" "${_MAILIST}" 	
        if [ $? -eq 0 ];then
                return 0
        else
                echo "���������ʼ�ʱ��������"
                return -7
        fi
fi

}

check_host_valid()
{
OP_USER=""
OP_MAIL_MASTER=
#OP_MAIL_MASTER=

local i;
local j=0;

if [  -z "$1" ];then
	echo "error: mail id is black"
	return -1
fi

for i in ${OP_USER} ;do
	id ${i} | grep '\-OP' &>/dev/null
	if [ $? -eq 0 ];then 
		let j=j+1
	fi
done
if [ ${j} -gt 3 ];then
	# �û���OP��Ȩ�ޣ����һ��ȥ�����Ի�
	echo "`hostname -s`" | grep -v '\-blmon[0-9]' | grep -v '\-test' &>/dev/null
	if [ $? -eq 0 ];then 
		# �������ʼ���MAIL_MASTER������spider���ϻ������ʼ��������ܴ����쳣�ռ���
		echo "Mail or gsm list include ( ${1} ) at `pwd`" | mail -s "[warn][send_msg.sh][`whoami`@`hostname -s`][${FUNC_NAME}�ռ��˲�������(${1}),���ܲ��淶][`date +%H:%M:%S`]" "${OP_MAIL_MASTER}" 
		echo "waring! include personal postbox"
		return 0
	fi
else
	# OP��Ȩ�ޣ�˵��������������������ڷ����Ϸ������
	return 0
fi	
}

send_gsm_msg()
{
# ���Ͷ��ŵ�ͨ�ó���
# �÷���send_gsm_msg  -t "����������" -s "��Ҫ�ʼ�����"
# ������
#       -t: ������������RDֻ��Ҫ�ṩwarninglevel�����еı�������ȡֵΪ0-3���ű����Զ���ȡ�ü�����ռ���Ϣ��
#       -s: RDֻ��Ҫ�ṩ��ؼ��ģ����� [��Ҫ������Ϣ] ���ɡ����� [���][ģ����][������][ʱ��] ��Ϣ�ɽű��Զ���ȫ

# ����ֵ��
#  0: �������� 
# -1: ������������
# -2: ������ԣ���û��-t,-s�Ȳ�����
# -3: ���ű����ʽ�����Ϲ淶
# -4: ���Ͷ������ݴ���
# -5: �����ļ�warninglevelλ�ò��Ի򲻴���

local FUNC_NAME="send_gsm_msg"

# check parameter 
if [ $# -ne 4 ];then
        echo "$FUNC_NAME parameter error!"
        echo "Usage: $FUNC_NAME -t "����������" -s "��Ҫ�ʼ�����""
        return -1
fi

# ��ȡ����
OPTIND=1
while getopts "t:s:" opt;
do
        case "$opt" in
                t) opt_t=$OPTARG;
                ;;
                s) opt_s=$OPTARG; 
                ;;
                *) echo "parameter item error!"; return -2;
                ;;
        esac
done

# ���warninglevel�У�ģ�����Ƿ�Ϊ����
if [ -z "${MODULE_NAME}" ];then
        echo "the conf item MODULE_NAME is black"
        return -8
fi

# �жϱ�������
if [ "$opt_t" -ge ${LEVEL_NUM} -o "$opt_t"  -ge 4 ];then
        echo "warnling level error!,must be 0-3"
        return -1
fi

# ��ȡ�ռ�����Ϣ
case "${opt_t}" in
        "0") _WARNAME=${LEVEL_0_NAME};  _MAILIST=${LEVEL_0_MAILLIST};   _GSMLIST=${LEVEL_0_GSMLIST};
        ;;
        "1") _WARNAME=${LEVEL_1_NAME};  _MAILIST=${LEVEL_1_MAILLIST};   _GSMLIST=${LEVEL_1_GSMLIST};
        ;;
        "2") _WARNAME=${LEVEL_2_NAME};  _MAILIST=${LEVEL_2_MAILLIST};   _GSMLIST=${LEVEL_2_GSMLIST};
        ;;
        "3") _WARNAME=${LEVEL_3_NAME};  _MAILIST=${LEVEL_3_MAILLIST};   _GSMLIST=${LEVEL_3_GSMLIST};
        ;;
        "*") echo "parameter item error!"; return -2;
        ;;
esac

_DATE=`date +%H:%M:%S`
_SUBJECT="[${_WARNAME}][${MODULE_NAME}][`hostname -s`][${opt_s}][${_DATE}]"

echo ${_GSMLIST}| grep 'g_psop_' &>/dev/null
if [ $? -ne 0 ];then
	check_host_valid "${_GSMLIST}"
fi

local gsmname=0
for tmpi_Qz4_tUw9Pg in ${_GSMLIST};do
	# Message format: phone_num@content	
	gsmsend  -s emp01.baidu.com:15001 -semp02.baidu.com:15001  ${tmpi_Qz4_tUw9Pg}@"\"${_SUBJECT}\""
	if [ $? -ne 0 ];then
               let gsmname=gsmname+1
        fi
done

if [ $gsmname -eq 0 ];then
	return 0           
else
	echo "���Ͷ������ݴ����쳣,��${gsmname}��δ�ɹ�������"
    return -4
fi

}
