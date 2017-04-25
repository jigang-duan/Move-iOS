# /bin/bash!

#proj_path=`dirname $0`
#scriptpath="$(proj_path)/package.py -u SH"
#echo "$scriptpath"
#.$scriptpath
#pause

proj_path=`pwd`
scriptpath="${proj_path}/buildTool/iosapp-package.py -t ${proj_path}"
exec "${proj_path}/buildTool/iosapp-package.py" -d -t "${proj_path}"
