#!/bin/sh

rm main*

scp -r ssimhandl@ssh.ecs.tuwien.ac.at:~/SPARC-ISP1362/sparc_usb_ISP1362/workspace/hwsw_de2-115/application /usr/tmp > /usr/tmp/tmp

mv /usr/tmp/testapp/main* ./
