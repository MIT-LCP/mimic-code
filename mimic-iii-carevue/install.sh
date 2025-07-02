#!/bin/bash

db="MIMIC-III CareVue"

echo -e "===================================="
echo -e "One-Click Installation Universal Script for $db on MAC OS, Windows, and Linux"
echo -e "===================================="
echo -e "$db 数据库全平台通用（MAC OS、Windows、Linux）一键安装脚本"
echo -e "===================================="
echo -e "ningyile@qq.com"
echo -e "===================================="
echo -e "https://github.com/ningyile"
echo -e "===================================="



# display language
while true
do
    echo -e "Enter a choice for display language(输入选项以选择语言):
    1. English(英文)
    2. Chinese(中文)"
    read lan_sel
    echo -e "\n"
    case $lan_sel in
        1)
            echo -e "You select English!\n"
            ;;
        2)
            echo -e "已选择中文!\n"
            ;;
        *)
            continue
    esac
break
done



# check whether the current user name meets the requirements
while true
do
    username=$(whoami)
    # read username
    if [[ $username =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
        echo -e "\n"
    else
        if [ $lan_sel == 1 ]; then
            # 英文
            echo -e "The current username does not meet the requirements!"
            echo -e "The username can contain alphabet(and start with letter), number, and/or underscores(_)!"
            echo -e "Please abort the installation and add a username that meets the requirements!"
            echo -e "Are you aware of the requirements and abort the installation?('Y' or 'N')"
            read abort_sel
            echo -e "\n"
            case $abort_sel in
                'Y'|'y')
                    # 中止
                    exit
                    ;;
                *)
                    continue
            esac
        else
            echo -e "当前用户名不符合要求!"
            echo -e "用户名只能包含英文字母(且字母开头)、数字或者下划线(_)!"
            echo -e "请中止安装并前往系统添加符合要求的用户名!"
            echo -e "你已知晓上述要求并中止安装吗?(请输入'Y' 或 'N')"
            read abort_sel
            echo -e "\n"
            case $abort_sel in
                'Y'|'y')
                    # 中止
                    exit
                    ;;
                *)
                    continue
            esac
        fi
    fi
break
done



# reset pg_hba.conf
user="postgres"
test_db_login=false
ptn="   reject$|   md5$|   password$|   scram-sha-256$|   gss$|   sspi$|   ident$|   peer$|   pam$|   ldap$|   radius$|   cert$"
sed_ptn="s/$ptn/   trust/g"

if [[ $lan_sel == 1 ]]; then
    # English
    while [[ $test_db_login = "false" ]]; do

        unset pass
        while [ -z $pass ]; do
            read -sp "Please type the password of database user 'postgres': " pass
            done
        echo -e "\n"
        # set global login password
        export PGPASSWORD=$pass
        # get abs path of pg_hba.conf
        pg_hba=`(psql -U postgres -t -P format=unaligned -c "show hba_file;")`

            if [[ "$pg_hba" =~ "pg_hba.conf" ]]; then
                test_db_login=true
                echo "The path of 'pg_hba.conf' is $pg_hba"

                if grep -E "$ptn" "$pg_hba"; then
                    echo -e "===================================="
                    echo -e "\n"
                    echo -e "Please type the password of operating system user!"
                    echo -e "\n"
                    echo -e "===================================="
                    pg_hba_dir=$(sudo dirname "$pg_hba")

                    # backup pg_hba.conf
                    cp "$pg_hba" "$pg_hba_dir"/pg_hba.conf.bk
                    # 判断是否是Mac os
                    os="$(uname)"
                    sed_version="$(which sed)"

                    # reset the mode of local connection as "trust"
                    if [[ "$os" == "Darwin" ]] && [[ "$sed_version" == "/usr/bin/sed" ]]; then
                        
                        sed -i.bk -E "$sed_ptn" "$pg_hba"   # FreeBSD-sed
                    else
                        sed -i -E "$sed_ptn" "$pg_hba"   # GNU-sed
                    fi
                    echo -e "\n"
                    echo -e "The mode of local connection has been reset as 'trust'!"
                    echo -e "\n"
                    echo -e "===================================="
                    # restart the database to load the configuration
                    psql -U postgres -q -c "SELECT pg_reload_conf();"
                    echo -e "===================================="
                    echo -e "\n"
                    echo -e "Configuration of 'pg_hba.conf' has been reloaded!"
                    echo -e "\n"
                    echo -e "===================================="
                else
                    echo -e "===================================="
                    echo -e "\n"
                    echo -e "The mode of local connection is 'trust'!"
                    echo -e "\n"
                    echo -e "===================================="
                fi

            else
                test_db_login=false
                echo -e "===================================="
                echo -e "\n"
                echo -e "Password authentication failed for user 'postgres'"
                echo -e "Please retype the correct password of database user 'postgres'!"
                echo -e "\n"
                echo -e "===================================="
            fi
    done

else
    # Chinese
    while [[ $test_db_login = "false" ]]; do

        unset pass
        while [ -z $pass ]; do
            read -sp "请输入数据库用户'postgres'的登录密码: " pass
            done
        echo -e "\n"
        # set global login password
        export PGPASSWORD=$pass
        # get abs path of pg_hba.conf
        pg_hba=`(psql -U postgres -t -P format=unaligned -c "show hba_file;")`

            if [[ "$pg_hba" =~ "pg_hba.conf" ]]; then
                test_db_login=true
                echo "数据库配置文件'pg_hba.conf'的路径是$pg_hba"

                if grep -E "$ptn" "$pg_hba"; then
                    echo -e "===================================="
                    echo -e "\n"
                    echo -e "请输入操作系统用户登录密码!"
                    echo -e "\n"
                    echo -e "===================================="
                    pg_hba_dir=$(sudo dirname "$pg_hba")

                    # backup pg_hba.conf
                    cp "$pg_hba" "$pg_hba_dir"/pg_hba.conf.bk
                    # 判断是否是Mac OS
                    os="$(uname)"
                    sed_version="$(which sed)"

                    # reset the mode of local connection as "trust"
                    if [[ "$os" == "Darwin" ]] && [[ "$sed_version" == "/usr/bin/sed" ]]; then
                        sed -i.bk -E "$sed_ptn" "$pg_hba"   # FreeBSD-sed
                    else
                        sed -i -E "$sed_ptn" "$pg_hba"   # GNU-sed
                    fi
                    echo -e "\n"
                    echo -e "数据库本地连接模式已重置为'trust'!"
                    echo -e "\n"
                    echo -e "===================================="
                    # restart the database to load the configuration
                    psql -U postgres -q -c "SELECT pg_reload_conf();"
                    echo -e "===================================="
                    echo -e "\n"
                    echo -e "数据库配置文件'pg_hba.conf'已重新加载生效!"
                    echo -e "\n"
                    echo -e "===================================="
                else
                    echo -e "===================================="
                    echo -e "\n"
                    echo -e "数据库本地连接模式为'trust'!"
                    echo -e "\n"
                    echo -e "===================================="
                fi

            else
                test_db_login=false
                echo -e "===================================="
                echo -e "\n"
                echo -e "数据库用户'postgres'登录密码输入错误"
                echo -e "请重新输入数据库用户'postgres'的登录密码!"
                echo -e "\n"
                echo -e "===================================="
            fi
    done
fi



# create database user and database with the same name as the operating system user name
if [[ $lan_sel == 1 ]]; then
    # English

    # create database user
    if psql -U postgres -t -c '\du' | cut -d \| -f 1 | grep -qw "$(whoami)"; then
        # the database user with the same name as the system user exists
        echo ""
    else
        # the database user with the same name as the system user does not exist
        echo "--- The database user with the same name as the system user does not exist. ---"
        echo "--- The database user with the same name as the system user will be created. ---"
        echo ""

        # create database user with the same name as the system user
        psql -U postgres -c "create user $(whoami) with superuser createdb createrole replication bypassrls password '$(whoami)';"
        echo ""

        echo "--- The database user $(whoami) has been created successfully. ---"
        echo "--- The default password of the database user $(whoami) has been set as:：$(whoami) ---"
        echo ""
    fi


    # create database
    if psql -U postgres -t -c '\l' | cut -d \| -f 1 | grep -qw "$(whoami)"; then
        # The database with the same name as the system user exists
        echo ""
    else
        # create database with the same name
        psql -d postgres -c "create database $(whoami) owner $(whoami);"
        echo ""
        
        echo "--- The database with the same name as the system user created successfully. ---"
        echo "--- You just type 'psql' in the terminal to login Postgresql without any other arguements. ---"
        echo ""
    fi

else
    # Chinese

    # create database user
    if psql -U postgres -t -c '\du' | cut -d \| -f 1 | grep -qw "$(whoami)"; then
        # the database user with the same name as the system user exists
        echo ""
    else
        # the database user with the same name as the system user does not exist
        echo "--- 与系统同名的数据库用户不存在，准备以系统用户为名创建数据库用户 ---"
        echo ""

        # create database user with the same name as the system user
        psql -U postgres -c "create user $(whoami) with superuser createdb createrole replication bypassrls password '$(whoami)';"
        echo ""

        echo "--- 成功创建与系统用户同名的数据库用户$(whoami)，用户$(whoami)默认密码已经被设置为：$(whoami) ---"
        echo ""
    fi


    # create database
    if psql -U postgres -t -c '\l' | cut -d \| -f 1 | grep -qw "$(whoami)"; then
        # The database with the same name as the system user exists
        echo ""
    else
        # create database with the same name
        psql -d postgres -c "create database $(whoami) owner $(whoami);"
        echo ""
        
        echo "--- 成功创建与系统用户同名的数据库(方便使用终端登录) ---"
        echo "--- 你只需在终端输入“psql”即可登录，无需其他任何参数 ---"
        echo ""
    fi
    
fi




# install the database
if [[ $lan_sel == 1 ]]; then
    # English

    echo -e "===================================="
    echo -e 'Any message like "NOTICE: TABLE "XXXXXX" does not exist" during the installation is normal, do not worry about it!'
    echo -e "===================================="
    echo ""

    # function of timing
    secs_to_human() {
        echo "It takes $(( ${1} / 3600 ))h $(( (${1} / 60) % 60 ))m $(( ${1} % 60 ))s to install the $obj"
    }

    echo "--- Install basic tables of database ---"
    echo ""
    export OP='dbname=mimic3_carevue options=--search_path=mimiciii_cv,mimiciii_derived'

    # build_starttime
    build_starttime=$(date +%s)

    # drop database if exists
    psql -c "drop database if exists mimic3_carevue;"
    # create database
    psql -c "create database mimic3_carevue owner $(whoami);"
    # create schema
    psql -d mimic3_carevue -c "create schema mimiciii_cv;"
    # create schema
    psql -d mimic3_carevue -c "create schema mimiciii_derived;"
    # create tables
    echo "--- create tables ---"
    echo ""
    psql -v on_error_stop=1 -f ./code/buildmimic/01_create_tables.sql "${OP}"
    # load data
    echo "--- load data ---"
    echo ""
    psql -v on_error_stop=1 -v mimic_data_dir='./database' -f ./code/buildmimic/02_load_data_gz.sql "${OP}"
    # create indexes
    echo "--- create indexes ---"
    echo ""
    psql -v on_error_stop=1 -f ./code/buildmimic/03_add_indexes.sql "${OP}"
    # create constraints
    # Several patients are not in the admission tables, create constraint generates errors, but does not affect.
    # psql -v on_error_stop=1 -f ./code/buildmimic/04_add_constraints.sql "${OP}"

    echo "--- The basic tables of database has been installed successfully! ---"
    echo ""

    # build_endtime
    build_endtime=$(date +%s)
    # duration of basic tables
    obj="basic tables of database"
    secs_to_human "$((${build_endtime} - ${build_starttime}))"
    echo ""



    echo "--- Install concepts of database ---"
    echo ""
    export OP='dbname=mimic3_carevue options=--search_path=mimiciii_derived,mimiciii_cv'

    # concepts_starttime
    concepts_starttime=$(date +%s)

    # generate by: ls -a | awk '{print "psql -v on_error_stop=1 -f ./code/concepts/"$0" \"${OP}\""}' > tmp.txt
    psql -v on_error_stop=1 -f ./code/concepts/01_code_status.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/02_ventilation_classification.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/03_ventilation_durations.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/04_crrt_durations.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/05_dobutamine_durations.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/06_dopamine_durations.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/07_epinephrine_durations.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/08_isuprel_durations.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/09_milrinone_durations.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/10_norepinephrine_durations.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/11_phenylephrine_durations.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/12_vasopressin_durations.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/13_vasopressor_durations.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/14_weight_durations.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/15_elixhauser_ahrq_v37.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/16_elixhauser_ahrq_v37_no_drg.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/17_elixhauser_quan.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/18_elixhauser_score_ahrq.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/19_elixhauser_score_quan.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/20_icustay_detail.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/21_blood_gas_first_day.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/22_blood_gas_first_day_arterial.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/23_gcs_first_day.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/24_height_first_day.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/25_labs_first_day.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/26_rrt_first_day.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/27_urine_output_first_day.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/28_ventilation_first_day.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/29_vitals_first_day.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/30_weight_first_day.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/31_urine_output.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/32_angus.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/33_martin.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/34_explicit.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/35_ccs_dx.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/36_kdigo_creatinine.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/37_kdigo_uo.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/38_kdigo_stages.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/39_kdigo_stages_7day.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/40_kdigo_stages_48hr.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/41_meld.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/42_oasis.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/43_sofa.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/44_saps.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/45_sapsii.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/46_apsiii.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/47_lods.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/48_sirs.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/49_qsofa.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/50_sepsis3.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/51_age.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/52_charlson.sql "${OP}"

    echo "--- The concepts of database has been installed successfully! ---"
    echo ""

    # concepts_endtime
    concepts_endtime=$(date +%s)
    # duration of concepts
    obj="concepts of database"
    secs_to_human "$((${concepts_endtime} - ${concepts_starttime}))"
    echo ""



    # check data
    echo "--- check data ---"
    echo ""
    psql -v on_error_stop=1 -f ./code/buildmimic/05_checks.sql "${OP}"

else
    # Chinese

    echo -e "===================================="
    echo -e '期间出现任何类似于 "NOTICE: TABLE "XXXXXX" does not exist"的提示为正常现象，不必多虑！'
    echo -e "===================================="
    echo ""

    # 计时函数
    secs_to_human() {
        echo "安装 $obj 共耗时$(( ${1} / 3600 ))h $(( (${1} / 60) % 60 ))m $(( ${1} % 60 ))s"
    }

    echo "--- 安装数据库基础表单 ---"
    echo ""
    export OP='dbname=mimic3_carevue options=--search_path=mimiciii_cv,mimiciii_derived'

    # build安装起始时间
    build_starttime=$(date +%s)

    # drop database if exists
    psql -c "drop database if exists mimic3_carevue;"
    # create database
    psql -c "create database mimic3_carevue owner $(whoami);"
    # create schema
    psql -d mimic3_carevue -c "create schema mimiciii_cv;"
    # create schema
    psql -d mimic3_carevue -c "create schema mimiciii_derived;"
    # create tables
    echo "--- 创建tables ---"
    echo ""
    psql -v on_error_stop=1 -f ./code/buildmimic/01_create_tables.sql "${OP}"
    # load data
    echo "--- 加载数据 ---"
    echo ""
    psql -v on_error_stop=1 -v mimic_data_dir='./database' -f ./code/buildmimic/02_load_data_gz.sql "${OP}"
    # create indexes
    echo "--- 创建索引 ---"
    echo ""
    psql -v on_error_stop=1 -f ./code/buildmimic/03_add_indexes.sql "${OP}"
    # create constraints
    # Several patients are not in the admission tables, create constraint generates errors, but does not affect.
    # psql -v on_error_stop=1 -f ./code/buildmimic/04_add_constraints.sql "${OP}"

    echo "--- 数据库基础表单安装完成 ---"
    echo ""

    # build安装结束时间
    build_endtime=$(date +%s)
    # 基础表单安装耗时
    obj="数据库基础表单"
    secs_to_human "$((${build_endtime} - ${build_starttime}))"
    echo ""



    echo "--- 安装数据库Concepts ---"
    echo ""
    export OP='dbname=mimic3_carevue options=--search_path=mimiciii_derived,mimiciii_cv'

    # concepts安装起始时间
    concepts_starttime=$(date +%s)

    # 以下命令由在终端下使用 ls -a | awk '{print "psql -v on_error_stop=1 -f ./code/concepts/"$0" \"${OP}\""}' > tmp.txt 批量生成
    psql -v on_error_stop=1 -f ./code/concepts/01_code_status.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/02_ventilation_classification.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/03_ventilation_durations.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/04_crrt_durations.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/05_dobutamine_durations.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/06_dopamine_durations.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/07_epinephrine_durations.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/08_isuprel_durations.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/09_milrinone_durations.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/10_norepinephrine_durations.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/11_phenylephrine_durations.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/12_vasopressin_durations.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/13_vasopressor_durations.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/14_weight_durations.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/15_elixhauser_ahrq_v37.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/16_elixhauser_ahrq_v37_no_drg.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/17_elixhauser_quan.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/18_elixhauser_score_ahrq.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/19_elixhauser_score_quan.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/20_icustay_detail.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/21_blood_gas_first_day.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/22_blood_gas_first_day_arterial.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/23_gcs_first_day.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/24_height_first_day.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/25_labs_first_day.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/26_rrt_first_day.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/27_urine_output_first_day.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/28_ventilation_first_day.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/29_vitals_first_day.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/30_weight_first_day.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/31_urine_output.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/32_angus.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/33_martin.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/34_explicit.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/35_ccs_dx.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/36_kdigo_creatinine.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/37_kdigo_uo.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/38_kdigo_stages.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/39_kdigo_stages_7day.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/40_kdigo_stages_48hr.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/41_meld.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/42_oasis.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/43_sofa.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/44_saps.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/45_sapsii.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/46_apsiii.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/47_lods.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/48_sirs.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/49_qsofa.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/50_sepsis3.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/51_age.sql "${OP}"
    psql -v on_error_stop=1 -f ./code/concepts/52_charlson.sql "${OP}"

    echo "--- 数据库concepts安装完成 ---"
    echo ""

    # concepts安装结束时间
    concepts_endtime=$(date +%s)
    # concepts安装耗时
    obj="数据库concepts"
    secs_to_human "$((${concepts_endtime} - ${concepts_starttime}))"
    echo ""



    # check data
    echo "--- 数据核对 ---"
    echo ""
    psql -v on_error_stop=1 -f ./code/buildmimic/05_checks.sql "${OP}"
fi