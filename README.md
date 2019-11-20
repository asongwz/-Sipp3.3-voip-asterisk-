# 使用Sipp3.3对voip-asterisk进行性能测试
SIPp安装
SIPp 是一个测试 SIP 协议性能的工具软件

下载：
https://sourceforge.net/projects/sipp/files/sipp/3.3/
请下载这个版本，或者在本主题下直接下载sipp-3.3.tar.gz，源码已上传。

安装依赖库：

RedHat

yum install gcc-c++ gcc automake autoconf libtool make

yum install ncurses ncurses-devel

yum install openssl openssl-devel # TLS support

yum install lksctp-tools lksctp-tools-devel # SCTP support

yum install libpcap libpcap-devel libnet libnet-devel # PCAP play support

yum install gsl gsl-devel # distributed pauses


Debian

apt-get install g++ gcc automake autoconf libtool make

apt-get install libncurses5 libncurses5-dev

apt-get install openssl libssl-dev

apt-get install libsctp1 lksctp-tools libsctp-dev

apt-get install libpcap-dev libnet1 libnet1-dev

apt-get install gsl-bin libgsl0-dev libgsl0ldbl

本测试是在ubuntu18.04系统上测试

编译：
# tar xzvf sipp-3.3.tar.gz 

# cd sipp-3.3

# make pcapplay_ossl

脚本文件说明：

callee.csv ： sip分机批量注册时需要用到的脚本

callee_with_bye.xml： 被叫脚本 【作为服务端】

caller_with_auth.xml：主叫脚本

caller_for_confbridge.csv ：呼叫会议脚本，配置多少个人参与会议

caller_for_tonghua.csv：呼叫电话脚本，配置多少路通话

create_callercvs.sh：批量创建脚本

sipp-3.3.tar.gz ： sipp源码

首先在asterisk系统上添加200个pjsip分机【具体步骤，参考asterisk相关文档】

第二： 注册分机 

把脚本文件拷贝到目录sip-3.3

#cd sip-3.3

#./sipp -sf regclient_set_c_port.xml 192.168.215.31:5060 -i 192.168.215.35 -p 5088 -inf callee.csv -set c_port 5088 -m 200

192.168.215.31:5060  : asterisk 服务器的ip和端口

192.168.215.35 ： 本地服务器ip

5088：本地服务器端口

-m 200 ：注册多少个分机， 这里是注册200个分机，这个参数可变，比如想要注册20个分机，即 -m 20

第三： 通话性能测试

打开2个终端窗口

在第一个窗口，sipp作为被叫服务端,输入命令：

#./sipp -sf callee_with_bye.xml -i 192.168.215.35 -p 5088 -trace_err

在第二个窗口，sipp作为主叫客户端，输入命令：

#./sipp -sf caller_with_auth.xml 192.168.215.31:5060 -i 192.168.215.35 -p 5066 -inf caller_for_tonghua.csv -m 50 -d 30000 -oocsn ooc_default -trace_err


说明：
-m 50 ：指定测试多少路通话，这里是50路，这里的数量不超过caller_for_tonghua.csv里面的配置数量，可以根据自己需要，指定不同的通话路数

-d 30000：指定通话时长，这里是30秒

在asterisk服务器上打开一个串口，使用top命令，查看系统占用情况

第四： 电话会议性能测试

（1） 在asterisk配置文件中extension.conf添加会议的拨打方式, 比如：

exten => 8000, 1,NoOp(==========coming confrence 8000===========)

exten => 8000, n,ConfBridge(8000)

exten => 8000, n,Hangup()

（2） 使用软终端注册sip帐号后，拨打8000，新建一个电话会议 8000

（3） 开始批量测试

打开2个窗口

在第一个窗口，sipp作为被叫服务端,输入命令：

#./sipp -sf callee_with_bye.xml -i 192.168.215.35 -p 5088 -trace_err

在第二个串口，sipp作为主叫客户端，输入命令：

#./sipp -sf caller_with_auth.xml 192.168.215.31:5060 -i 192.168.215.35 -p 5066 -inf caller_for_confbridge.csv -m 50 -d 30000 -oocsn ooc_default -trace_err

说明：
-m 50 ：指定测试多少人参与，这里是50个，这里的数量不超过caller_for_tonghua.csv里面的配置数量，可以根据自己需要，指定不同的参与人数

-d 30000：指定通话时长，这里是30秒

在asterisk服务器上打开一个串口，使用top命令，查看系统占用情况

注意：本主题下的脚本适合sipp3.3版本，如果使用更高的版本，运行时会出现错误【Can't bind media raw socket.】, 笔者在测试时遇到了这个问题。
参考文档：

（1） https://www.cnblogs.com/dong1/p/10188712.html 

（2） https://www.jianshu.com/p/a98e760131a0

（3） http://www.51testing.com/html/00/130600-854747.html

（4） https://sipp.readthedocs.io/en/v3.6.0/scenarios/actions.html#media-rtp-commands

（5） https://linuxconfig.org/how-to-install-docker-on-ubuntu-18-04-bionic-beaver





