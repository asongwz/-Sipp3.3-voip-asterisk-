#!/bin/bash
#caller.csv的生成脚本
echo "SEQUENTIAL" >caller.csv
i=3101
while [ $i != 3400 ]
do
i=$(($i+1))
j=$(($i+1))
echo "$i;8000;[authentication username=$i password=123456]" >>caller.csv
done