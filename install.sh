#!/bin/bash


#################################
#				#
#	xwiki-ctrl install script	#
#				#
#################################

# load the function file
if [[ ! -e usr/lib/xwiki-ctrl/functions ]]; then

echo "Error: I can't find usr/lib/xwiki-ctrl/functions file."
exit 12

fi

if [[ ! -e usr/lib/xwiki-ctrl/vars ]]; then

echo "Error: I can't find usr/lib/xwiki-ctrl/vars file."
exit 15

fi

. usr/lib/xwiki-ctrl/functions
. usr/lib/xwiki-ctrl/vars

xwiki-ctrl_update ()
{

	if [[ -e /usr/lib/xwiki-ctrl/vars ]]; then	

		installed_xwiki-ctrl_version="`grep VERSION /usr/lib/xwiki-ctrl/vars | cut -d = -f 2`"
		current_xwiki-ctrl_version="`grep VERSION usr/lib/xwiki-ctrl/vars | cut -d = -f 2`"

		if [[ $installed_xwiki-ctrl_version != $current_xwiki-ctrl_version ]]; then

			xwiki-ctrl_install

		else

			echo
			echo " Xinit is up to date. Xinit version: $installed_xwiki-ctrl_version"
			echo
			exit 0
		fi

	else

		echo
		echo " Xinit is not installed or the installation is corrupted!"
		echo
		exit 4

	fi 

}

xwiki-ctrl_install ()
{

# check dependencies
check_dependencies;

if [[ ! -e usr/lib/xwiki-ctrl/vars ]]; then
	
	echo
	echo " Couldn't find vars file! Please go into xwiki-ctrl folder and run install.sh!"
	echo
	exit 1

else

	. usr/lib/xwiki-ctrl/vars

fi

if [[ -d $LIB_DIR ]]; then

	echo "Lib dir ($LIB_DIR) already exists. Installing the last one ..."
	rm -rf $LIB_DIR
	cp -r usr/lib/xwiki-ctrl $LIB_DIR
	

else

	echo "Installing lib dir $LIB_DIR..."
	cp -r usr/lib/xwiki-ctrl $LIB_DIR

fi

if [[ -d /var/www/xwiki-static ]]; then

	echo "copy skoll data ..."
	cp -rf www/xwiki-static /etc/init.d/xwiki.sh
	chmod -R a+r www/xwiki-static

fi


if [[ -e /etc/init.d/xwiki.sh ]]; then

	echo "xwiki.sh script already exists! Installing a new one ..."
	rm -f /etc/init.d/xwiki.sh
	cp etc/init.d/xwiki.sh /etc/init.d/xwiki.sh
	chmod a+x /etc/init.d/xwiki.sh

else

	echo "Installing xwiki.sh script ..."
	cp etc/init.d/xwiki.sh /etc/init.d/xwiki.sh
	chmod a+x /etc/init.d/xwiki.sh

fi

if [[ ! -d ${CONF_DIR} ]]; then

	echo "Installing xwiki-ctrl default configuration! Please edit /etc/xwiki-ctrl/xwiki-ctrl.cfg as you need!"
	mkdir ${CONF_DIR}
	cp -f etc/xwiki-ctrl/xwiki-ctrl.cfg /etc/xwiki-ctrl/xwiki-ctrl.cfg
	echo "Installation Finished!"

elif [[ -e "${CONF_DIR}/${XWIKI_CONF_FILE}" ]]; then

	echo "A previous configuration of xwiki-ctrl already exists. I'll not touch it!"
	echo "Installation Finished!"

else

	echo "Installing xwiki-ctrl default configuration! Please edit /etc/xwiki-ctrl/xwiki-ctrl.cfg as you need!"
	cp -f etc/xwiki-ctrl/xwiki-ctrl.cfg /etc/xwiki-ctrl/xwiki-ctrl.cfg
        echo "Installation Finished!"

fi
}

# Function used to migrate xwiki-ctrl conf (vers <= 0.0.17 ) to version >= 1.0
migrate() 
{
	OLD_CONFIGURATION_FILE='/etc/xwiki-ctrl/xwiki-ctrl.cfg';
	NEW_CONFIGURATION_FILE='/etc/xwiki-ctrl/xwiki-ctrl.cfg.new'
	DEFAULT_NEW_CONFIGURATION_FILE='usr/lib/xwiki-ctrl/default.cfg';

	if [[ ! -e $OLD_CONFIGURATION_FILE ]]; then

		echo "Error: I was not able to find old conf file $OLD_CONFIGURATION_FILE"
		exit 13
	fi

	if [[ ! -e $DEFAULT_NEW_CONFIGURATION_FILE ]]; then

                echo "Error: I was not able to find the default new file $DEFAULT_NEW_CONFIGURATION_FILE"
                exit 14
        fi

	./usr/lib/xwiki-ctrl/migrate $OLD_CONFIGURATION_FILE $DEFAULT_NEW_CONFIGURATION_FILE $NEW_CONFIGURATION_FILE
}

case $1 in
        --install)
                        xwiki-ctrl_install
                        ;;
        --update)
                        xwiki-ctrl_update
                        ;;
	--migrate)
			migrate
			;;
        *)
                echo ""
                echo " usage: ./install.sh [ --install | --update | --migrate ]"
                echo
                exit 1

esac

