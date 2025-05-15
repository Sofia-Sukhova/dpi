#!/usr/bin/env bash

cd build

unset https_proxy
unset http_proxy
unset ftp_proxy
export LC_ALL='en_US.UTF-8'
export LANG=C
export VCS_HOME=/auto/da/cad/synopsys/VCS/vcs_mx_vO-2018.09-SP2_1
source /auto/vgr/tools/lmlicenserc.bash

./simv -cm_name cov_grey -cm line -cm cond -cm branch +random_mode=1000 +constraint

mkdir test_const
bash ../urgwrap -dir simv.vdb -report test_const -metric line+cond+branch -format both
