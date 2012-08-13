#!/bin/sh

case $1 in
	"lab")
		COM=/dev/ttyS0
	;;
	"home")
		COM=/dev/ttyUSB0
	;;
	
	 *)
                echo "Usage: $0 (home|lab)(init|listen|write|status) [filename]"
        ;;
esac



SERIALCONFIG="115200 parenb -parodd cs8 -hupcl -cstopb cread clocal -crtscts ignbrk -brkint -ignpar -parmrk -inpck -istrip -inlcr -igncr -icrnl -ixon -ixoff -iuclc -ixany -imaxbel -iutf8 -opost -olcuc -ocrnl -onlcr -onocr -onlret -ofill -ofdel nl0 cr0 tab0 bs0 vt0 ff0 -isig -icanon -iexten -echo -echoe -echok -echonl -noflsh -xcase -tostop -echoprt -echoctl -echoke"

case $2 in
        "init")
                echo "initializing Com1 ..."
                echo "stty -F $COM $SERIALCONFIG"
                stty -F $COM $SERIALCONFIG
        ;;
        "listen")
                echo "waiting for replay ..."
                echo "cat $COM"
                cat $COM
        ;;
				"c")
								echo "********************************************"
								echo "RECOMPILE"
								echo "********************************************"
								rm -rf main.srec
								rm -rf main
								make
				;;
        "write")
                if test -z $3
                then
                        echo "********************************************"
                        echo "Usage: $0 write <filename>"
                        echo "********************************************"
                else
												
                        echo "cat $3 > $COM"
                        cat $3 > $COM
                fi
        ;;
        "status")
                echo "status of $COM ..."
                echo "stty -F $COM --all"
                stty -F $COM --all
        ;;
        *)
                echo "Usage: $0 (lab|home) (init|listen|write|status) [filename]"
        ;;
esac


