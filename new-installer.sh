#!/bin/bash
clear;
# clear;
# Reset
Reset='\e[0m'       # Text Reset
# Regular Colors
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White
# Bold
BBlack='\e[1;30m'       # Black
BRed='\e[1;31m'         # Red
BGreen='\e[1;32m'       # Green
BYellow='\e[1;33m'      # Yellow
BBlue='\e[1;34m'        # Blue
BPurple='\e[1;35m'      # Purple
BCyan='\e[1;36m'        # Cyan
BWhite='\e[1;37m'       # White

if [ "$0" == "./installer.sh" ]; then
	echo -ne "You can't run this script here !!!!\n\n";
	exit;
fi
echo -ne "${BGreen}Welcome to IPTVPANEL v2 install By Multics76\n
${BRed}Warning: This install script will remove your existing apache2 and its configuration in instead of it install nginx.${Reset}\n
${BWhite}Do you want continue (y/n):${Reset} ";
read AGREE
if [ "$AGREE" != "y" ]; then
	echo -ne "${BWhite}Exiting... ${Reset}\n";
	exit;
fi
                                                        
# Tweak nameservers
echo "nameserver 8.8.8.8" > /etc/resolv.conf
# Get distro data
. /etc/lsb-release >> /var/log/iptvpanel-install.log 2>&1
if [ "$DISTRIB_ID" != "Ubuntu" ]; then
        echo -e "ERROR: This system requires Ubuntu distro only !";
        exit 1;
else
        if [[ "$DISTRIB_CODENAME" = "trusty" ]]; then
		X=1
        else
                echo -e "ERROR: This system requires Ubuntu ( 14.04 or 15.04 ) distro only !";
                exit 1;
        fi
fi

echo -e "${BCyan}Checking your system...... [OK]${Reset}\n";

# TWEAK SYSTEM VALUES
function tweakSystem {
	echo -ne "${BCyan}Tweaking system...${Reset}"
	dpkg --remove-architecture i386 >> /dev/null 2>&1
	echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
	echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
	echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
	echo "fs.file-max = 327680" >> /etc/sysctl.conf
	echo "kern.maxfiles = 327680" >> /etc/sysctl.conf
	echo "kern.maxfilesperproc = 327680" >> /etc/sysctl.conf
	echo "kernel.core_uses_pid = 1" >> /etc/sysctl.conf
	echo "kernel.core_pattern = /var/crash/core-%e-%s-%u-%g-%p-%t" >> /etc/sysctl.conf
	echo "fs.suid_dumpable = 2" >> /etc/sysctl.conf
	sysctl -p >> /dev/null 2>&1
	echo -e "${BGreen}\t\t\t\tDone.${Reset}"
}
# SET LOCALE TO UTF-8
function setLocale {
	echo -ne "${BCyan}Setting locales...${Reset}"
	locale-gen en_US.UTF-8  >> /dev/null 2>&1
	export LANG="en_US.UTF-8" >> /dev/null 2>&1
	echo -e "${BGreen}\t\t\t\tDone.${Reset}"
}
# SET MIRRORS
function setMirrors {
	echo -ne "${BCyan}Adding mirrors...${Reset}"
	echo "deb http://ubuntu.mirrors.ovh.net/ftp.ubuntu.com/ubuntu/ $DISTRIB_CODENAME main restricted
deb-src http://ubuntu.mirrors.ovh.net/ftp.ubuntu.com/ubuntu/ $DISTRIB_CODENAME main restricted
deb http://ubuntu.mirrors.ovh.net/ftp.ubuntu.com/ubuntu/ $DISTRIB_CODENAME-updates main restricted
deb-src http://ubuntu.mirrors.ovh.net/ftp.ubuntu.com/ubuntu/ $DISTRIB_CODENAME-updates main restricted
deb http://ubuntu.mirrors.ovh.net/ftp.ubuntu.com/ubuntu/ $DISTRIB_CODENAME universe
deb-src http://ubuntu.mirrors.ovh.net/ftp.ubuntu.com/ubuntu/ $DISTRIB_CODENAME universe
deb http://ubuntu.mirrors.ovh.net/ftp.ubuntu.com/ubuntu/ $DISTRIB_CODENAME-updates universe
deb-src http://ubuntu.mirrors.ovh.net/ftp.ubuntu.com/ubuntu/ $DISTRIB_CODENAME-updates universe
deb http://ubuntu.mirrors.ovh.net/ftp.ubuntu.com/ubuntu/ $DISTRIB_CODENAME multiverse
deb-src http://ubuntu.mirrors.ovh.net/ftp.ubuntu.com/ubuntu/ $DISTRIB_CODENAME multiverse
deb http://ubuntu.mirrors.ovh.net/ftp.ubuntu.com/ubuntu/ $DISTRIB_CODENAME-updates multiverse
deb-src http://ubuntu.mirrors.ovh.net/ftp.ubuntu.com/ubuntu/ $DISTRIB_CODENAME-updates multiverse
deb http://ubuntu.mirrors.ovh.net/ftp.ubuntu.com/ubuntu/ $DISTRIB_CODENAME-backports main restricted universe multiverse
deb-src http://ubuntu.mirrors.ovh.net/ftp.ubuntu.com/ubuntu/ $DISTRIB_CODENAME-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu $DISTRIB_CODENAME-security main restricted
deb-src http://security.ubuntu.com/ubuntu $DISTRIB_CODENAME-security main restricted
deb http://security.ubuntu.com/ubuntu $DISTRIB_CODENAME-security universe
deb-src http://security.ubuntu.com/ubuntu $DISTRIB_CODENAME-security universe
deb http://security.ubuntu.com/ubuntu $DISTRIB_CODENAME-security multiverse
deb-src http://security.ubuntu.com/ubuntu $DISTRIB_CODENAME-security multiverse
	" > /etc/apt/sources.list
	#if [[ "$DISTRIB_CODENAME" = "trusty" ]]; then
	#	echo "deb http://ppa.launchpad.net/mc3man/trusty-media/ubuntu trusty main" >> /dev/null
	#else
		#bila podrska za druge distors
	#fi
	echo -e "${BGreen}\t\t\t\tDone.${Reset}"
}

# install base packages
function installBase {
	echo -ne "${BCyan}Installing base packages...${Reset}"
	LANG=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive dpkg --configure -a >> /dev/null 2>&1
	LANG=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive apt-get -y purge apache2* >> /dev/null 2>&1
	LANG=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive apt-get update -y -q >> /dev/null 2>&1
	LANG=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive dpkg --configure -a >> /dev/null 2>&1
	LANG=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes -q install lsb-release apt-utils aptitude apt software-properties-common curl mtr debconf html2text wget whois whiptail vim-nox unzip tzdata sudo sysstat strace sshpass ssh-import-id tcpdump telnet screen python-software-properties python openssl ntpdate mc iptraf mailutils mlocate mtr htop gcc fuse ftp dnsutils ethtool curl dbconfig-common coreutils debianutils debconf bc bash-completion automake autoconf bwm-ng apt-utils aptitude apt git software-properties-common php5-cli dos2unix dialog libjansson-dev curl >> /dev/null 2>&1
	LANG=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive dpkg --configure -a >> /dev/null 2>&1
	echo -e "${BGreen}\t\t\tDone.${Reset}"
}

function updateSSHPassword {
	NEWPASS=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1`
	NPASS=`php -r "echo base64_encode(mcrypt_encrypt(MCRYPT_RIJNDAEL_256, md5('iptvpancrypthash'), '$NEWPASS', MCRYPT_MODE_CBC, md5(md5('iptvpancrypthash'))));"`
	CHKUSER=`cat /etc/passwd | grep system | grep bash`
}

function installDatabase {
	if [ "$ISCMS" = "1" ]; then
		if [ -z `psql -U postgres -l -A -t | grep iptvpanel` ]; then
			echo -ne  "${BCyan}Installing database...${Reset}"
			psql -U postgres -c "CREATE DATABASE iptvpanel2" >> /dev/null 2>&1
			psql -U postgres iptvpanel2 < /opt/iptvpanel2/lib/iptvpanel.sql >> /dev/null 2>&1
			echo -e "${BGreen}\t\t\t\tDone.${Reset}"
		else
			echo "${BCyan}Database found, skipping installing initial database...${Reset}";
		fi
	fi
}
function addServer {
	SERVERPORT=`cat /etc/ssh/sshd_config | grep "Port " | cut -d" " -f2`
	TOKEN=`php -r "echo md5(\"${SERVERIP}\");"`
	RES=`curl -s "http://$CMSURL:$CMSPORT/cron?addServer=true&server_name=$SERVERNAME&server_ip=$SERVERIP&server_private_ip=$SERVERINTIP&server_port=$SERVERPORT&server_auth=$NEWPASS&token=$TOKEN"`
	if [ "$RES" = "OK" ]; then
		echo -e "${BGreen}Server added to the database !${Reset}";
	fi
	if [ "$RES" = "UPDATED" ]; then
		echo -e "${BGreen}Server updated into database !${Reset}";
	fi
	if [ -f /opt/iptvpanel2/bin/ffprobe ]; then
		echo -e "${BGreen}Binaries Ok!${Reset}";
	else
		wget -O /opt/iptvpanel2/bin/ffprobe hhttps://github.com/iptvpanel/iptvpanel.net/raw/master/ffprobe  >> /dev/null 2>&1
		wget -O /opt/iptvpanel2/bin/ffmpeg https://github.com/iptvpanel/iptvpanel.net/raw/master/ffmpeg  >> /dev/null 2>&1
		chmod a+x /opt/iptvpanel2/bin/ffprobe >> /dev/null 2>&1
		chmod a+x /opt/iptvpanel2/bin/ffmpeg >> /dev/null 2>&1
		ln -s /usr/bin/rtmpdump /opt/iptvpanel2/bin
	fi
	RES=`curl -s "http://$CMSURL:$CMSPORT/cron?q=true&server_name=$SERVERNAME&token=$TOKEN"`
}

function updateServerDatabasePass {
	echo -ne "${BCyan}Updating database password...${Reset}"
	PGPASSWORD="Pass22pp2019ssh808" psql -U postgres -h $CMSURL iptvpanel2 -c "UPDATE servers SET server_auth = '$NPASS' WHERE server_host = '$SERVERNAME'" >> /var/log/iptvpanel-install.log 2>&1
	echo -e "${BGreen}\t\t\t\tDone.${Reset}"
}

function writeConfig {
	echo -ne "${BCyan}Writing config files...${Reset}"
	mkdir -p /opt/iptvpanel2/etc/ >> /dev/null 2>&1
	echo "CMSURL=$CMSURL" > /opt/iptvpanel2/etc/iptvpanel.conf
	echo "CMSPORT=$CMSPORT" >> /opt/iptvpanel2/etc/iptvpanel.conf
	echo "SERVERNAME=not_used" >> /opt/iptvpanel2/etc/iptvpanel.conf	
	echo "SERVERID=$RES" >> /opt/iptvpanel2/etc/iptvpanel.conf
	echo "SERVERIP=not_used" >> /opt/iptvpanel2/etc/iptvpanel.conf
	echo "SERVERINTIP=not_used" >> /opt/iptvpanel2/etc/iptvpanel.conf
	echo "LICENSEKEY=$LICENSEKEY" >> /opt/iptvpanel2/etc/iptvpanel.conf
	echo "ISCMS=$ISCMS" >> /opt/iptvpanel2/etc/iptvpanel.conf
	echo "ISSTREAMER=$ISSTREAMER" >> /opt/iptvpanel2/etc/iptvpanel.conf
	echo "SERVERAUTH=$NPASS" >> /opt/iptvpanel2/etc/iptvpanel.conf
	echo -e "${BGreen}\t\t\t\tDone.${Reset}"
}

function upgradeFiles {
	if [ "$ISCMS" = "1" ]; then
		echo -ne "${BCyan}Upgrading CMS...${Reset}"
		wget -O /tmp/iptvpanel.tgz http://37.187.104.191/iptvpanel2-cms.tgz >> /dev/null 2>&1
		tar xzvf /tmp/iptvpanel.tgz -C /opt >> /dev/null 2>&1
		rm -rf /tmp/iptvpanel.tgz >> /dev/null 2>&1
		
		if [ ! -d "/etc/nginx" ]; then
			LANG=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive apt-get -y purge apache2*  >> /dev/null 2>&1
			LANG=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive dpkg --configure -a >> /dev/null 2>&1
			LANG=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive apt-get -y install nginx nginx-core php5-fpm nginx-common >> /dev/null 2>&1
			LANG=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive dpkg --configure -a >> /dev/null 2>&1
			VER="5.5"
			sed -i 's/^max_execution_time =.*/max_execution_time = 300/' /etc/php5/fpm/php.ini
			CHKZEND=`cat /etc/php5/fpm/php.ini | grep zend_exten`
			if [ -z "$CHKZEND" ]; then
				echo "zend_extension=/opt/iptvpanel2/lib/ioncube/ioncube_loader_lin_$VER.so" >> /etc/php5/fpm/php.ini
			fi
			echo "server {
				listen $CMSPORT default_server;
				root /opt/iptvpanel2/portal;
				index index.php index.html index.htm;
				server_name ${CMSURL};
				
				location / {
					try_files \$uri \$uri/ /api.php?\$args;
				}
				location /files/ {
					valid_referers server_names ~.;
				        if (\$invalid_referer) {
				        	return 403;
				        }
				}
				
				location ~ \.php$ {
					fastcgi_split_path_info ^(.+\.php)(/.+)$;
					fastcgi_pass unix:/var/run/php5-fpm.sock;
					fastcgi_read_timeout 300;
					fastcgi_param REDIRECT_URL \$request_uri;
					fastcgi_index index.php;
					include fastcgi_params;
				}
				
				location ~ /\.ht {
					deny all;
				}
				                        
			}
			" > /etc/nginx/sites-enabled/default
			/usr/sbin/service php5-fpm restart >> /dev/null 2>&1
			sleep 2;
			/etc/init.d/nginx restart >> /dev/null 2>&1
		fi
		echo -e "${BGreen}\t\t\t\tDone.${Reset}"
	fi
	if [ "$ISSTREAMER" = "1" ]; then
		echo -ne "${BCyan}Upgrading streamer binaries...${Reset}"
		wget -O /tmp/iptvpanel.tgz https://github.com/iptvpanel/iptvpanel.net/raw/master/iptvpanel2-streamer.tgz >> /dev/null 2>&1
		tar xzvf /tmp/iptvpanel.tgz -C /opt >> /dev/null 2>&1
		rm -rf /tmp/iptvpanel.tgz >> /dev/null 2>&1
		echo -e "${BGreen}\t\t\tDone.${Reset}"
	fi
}

function installCMSPackages {
	echo -ne "${BCyan}Installing CMS packages...${Reset}"
	LANG=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive dpkg --configure -a >> /dev/null 2>&1
	LANG=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive apt-get install nginx nginx-core nginx-common php5-fpm php5-mcrypt php5-pgsql php5-cli php5-curl php5-gd php-pear libssh2-php php5-json libxslt1.1 daemontools postgresql-client -q -y --force-yes >> /dev/null 2>&1
	LANG=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive apt-get install libva1 libxfixes3 libxext6 libasound2 libsdl1.2debian libtheora0 libmp3lame0 libvdpau1 daemontools postgresql-client php5 -q -y --force-yes >> /dev/null 2>&1
	if [ "$DISTRIB_CODENAME" = "trusty" ]; then
		LANG=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive apt-get install libass4 postgresql-9.3 -y --force-yes >> /dev/null 2>&1
		echo -e "local all postgres trust\n" > /etc/postgresql/9.3/main/pg_hba.conf
		echo -e "local all all trust\n" >> /etc/postgresql/9.3/main/pg_hba.conf
		echo -e "host all all 127.0.0.1/32 trust\n" >> /etc/postgresql/9.3/main/pg_hba.conf
		echo -e "host all all ::1/128 trust\n" >> /etc/postgresql/9.3/main/pg_hba.conf
		echo -e "listen_addresses = '127.0.0.1'\n" >> /etc/postgresql/9.3/main/postgresql.conf
	fi
	/etc/init.d/postgresql restart >> /var/log/iptvpanel-install.log 2>&1
	wget -N -O /usr/share/GeoIP.dat.gz https://github.com/iptvpanel/iptvpanel.net/raw/master/GeoIP.dat.gz >> /dev/null 2>&1
	gzip -d /usr/share/GeoIP.dat.gz >> /dev/null 2>&1
	psql -U postgres -c "ALTER USER postgres WITH PASSWORD 'Pass22pp2019ssh808'" >> /var/log/iptvpanel-install.log 2>&1
	echo -e "${BGreen}\t\t\tDone.${Reset}"
}

function installStreamerPackages {
	echo -ne "${BCyan}Installing streamer packages...${Reset}"
	LANG=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive dpkg --configure -a >> /dev/null 2>&1
	LANG=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive apt-get install daemontools postgresql-client x264 -q -y --force-yes >> /dev/null 2>&1
	LANG=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive apt-get purge -y --force-yes -qq apache2* vlc-data vlc-nox vlc >> /dev/null 2>&1
	LANG=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive apt-get autoremove -y --force-yes -qq >> /dev/null 2>&1
	LANG=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes -qq ubuntu-restricted-extras >> /dev/null 2>&1
	LANG=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive apt-get update >> /dev/null 2>&1
	if [ "$DISTRIB_CODENAME" = "trusty" ]; then
		LANG=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes -qq vlc-nox vlc x264 php5 php5-mcrypt rtmpdump >> /dev/null 2>&1
	else 
		#LANG=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes -qq vlc-nox vlc ffmpeg non-free-codecs x264 php5 php5-mcrypt >> /dev/null 2>&1
		echo ss >>/dev/null 2>&1
	fi
	echo "deb http://ppa.launchpad.net/mc3man/trusty-media/ubuntu trusty main" >> /etc/apt/sources.list
	LANG=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive apt-get update -y -q >> /dev/null 2>&1
	LANG=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive dpkg --configure -a >> /dev/null 2>&1
	LANG=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes -q install libx265-59 libvdpau1 fdkaac-encoder libass5 >> /dev/null 2>&1
	LANG=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive dpkg --configure -a >> /dev/null 2>&1
	sed -i '/ppa/d' /etc/apt/sources.list
	LANG=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive apt-get update -y -q >> /dev/null 2>&1
	ln -s /usr/bin/cvlc /opt/iptvpanel2/bin/vlc
	setupMcrypt;
	echo -e "${BGreen}\t\t\tDone.${Reset}"
}

function setupCMS {
	echo -ne "${BCyan}Setting up CMS...${Reset}"
        apt-get install -y --force-yes nginx -q >> /dev/null 2>&1
    	if [[ "$DISTRIB_CODENAME" = "trusty" ]]; then
    		VER="5.5"
    	else
    		VER="5.6"
    	fi
    	
        CHKZEND=`cat /etc/php5/fpm/php.ini | grep zend_exten`
        if [ -z "$CHKZEND" ]; then
                echo "zend_extension=/opt/iptvpanel2/lib/ioncube/ioncube_loader_lin_$VER.so" >> /etc/php5/fpm/php.ini
        fi
    
        CHKZEND=`cat /etc/php5/cli/php.ini | grep zend_exten`
        if [ -z "$CHKZEND" ]; then
                echo "zend_extension=/opt/iptvpanel2/lib/ioncube/ioncube_loader_lin_$VER.so" >> /etc/php5/cli/php.ini
        fi
    
        /etc/init.d/apache2 stop >> /dev/null 2>&1
        cp -R /etc/php5/conf.d/* /etc/php5/fpm/conf.d/ >> /dev/null 2>&1
        cp -R /etc/php5/conf.d/* /etc/php5/cli/conf.d/ >> /dev/null 2>&1
        php5enmod ssh2 >> /dev/null 2>&1
        php5enmod mcrypt >> /dev/null 2>&1
        a2enmod rewrite >> /dev/null 2>&1

        killall -9 apache2 >> /dev/null 2>&1
        echo "server {
				listen $CMSPORT default_server;
				root /opt/iptvpanel2/portal;
				index index.php index.html index.htm;
				server_name ${CMSURL};
				
				location / {
					try_files \$uri \$uri/ /api.php?\$args;
				}
				location /files/ {
					valid_referers server_names ~.;
				        if (\$invalid_referer) {
				        	return 403;
				        }
				}
				
				location ~ \.php$ {
					fastcgi_split_path_info ^(.+\.php)(/.+)$;
					fastcgi_pass unix:/var/run/php5-fpm.sock;
					fastcgi_param REDIRECT_URL \$request_uri;
					fastcgi_read_timeout 300;
					fastcgi_index index.php;
					include fastcgi_params;
				}
				
				location ~ /\.ht {
					deny all;
				}
				                        
			}
			" > /etc/nginx/sites-enabled/default
	/usr/sbin/service php5-fpm restart >> /dev/null 2>&1
        /etc/init.d/nginx restart >> /dev/null 2>&1
        CHKRC=`cat /etc/crontab | grep iptvpanel`
        if [ -z "$CHKRC" ]; then
                echo "*/5 * * * * root wget -O /dev/null \"http://${CMSURL}/cron\" >> /dev/null 2>&1" >> /etc/crontab
        fi
        psql -U postgres iptvpanel2 -c "UPDATE settings SET config_value = '$CMSVER' WHERE config_name = 'current_version' OR config_name = 'new_version'" >> /dev/null 2>&1
        chown -R www-data:www-data /opt/iptvpanel2 >> /dev/null 2>&1
        echo -e "${BGreen}\t\t\t\tDone.${Reset}"
}	
function setupMcrypt {
	php5enmod mcrypt >> /dev/null 2>&1
        cp -R /etc/php5/conf.d/* /etc/php5/fpm/conf.d/ >> /dev/null 2>&1
        cp -R /etc/php5/conf.d/* /etc/php5/cli/conf.d/ >> /dev/null 2>&1
}


function setupStreamer {
	echo -ne "${BCyan}Setting up Streamer...${Reset}"
        cp -R /etc/php5/conf.d/* /etc/php5/fpm/conf.d/ >> /dev/null 2>&1
        cp -R /etc/php5/conf.d/* /etc/php5/cli/conf.d/ >> /dev/null 2>&1
        php5enmod mcrypt >> /dev/null 2>&1
	( killall -9 galaxy2 vlc supervise ; supervise /opt/iptvpanel2/bin & ) >> /dev/null 2>&1
	CHKRC=`cat /etc/rc.local | grep iptvpanel2`
	if [ -z "$CHKRC" ]; then
		echo "( killall -9 galaxy2 vlc supervise ffmpeg ffprobe rtmpdump; supervise /opt/iptvpanel2/bin & ) >> /dev/null 2>&1" > /etc/rc.local
	fi
	echo -e "${BGreen}\t\t\t\tDone.${Reset}"
}

function cleanUp {
	echo -ne "${BCyan}Removing any temporary data used for install...${Reset}"
	# Remove any temp data or package data.
	if [ "$ISSTREAMER" = "1" ]; then
		/etc/init.d/nginx stop >> /dev/null 2>&1
		( killall -9 galaxy2 vlc supervise ; supervise /opt/iptvpanel2/bin & ) >> /dev/null 2>&1
	fi
	if [ "$ISCMS" = "1" ]; then
		/etc/init.d/nginx start >> /dev/null 2>&1
	fi
	apt-get purge -y --force-yes iptvpanel apache2* -q >> /dev/null 2>&1
	
        /etc/init.d/apache2 stop >> /dev/null 2>&1
	killall -9 apache2 >> /dev/null 2>&1
	rm -rf /opt/iptvpanel2/lib/iptvpanel.sql >> /dev/null 2>&1
	rm -rf /tmp/iptvpanel* >> /dev/null 2>&1
	rm -rf /tmp/vlc_3.0.0-1_amd64.deb >> /dev/null 2>&1
	mkdir -p /opt/iptvpanel2/www/vod /opt/iptvpanel2/www/hls >> /dev/null 2>&1
	chown -R www-data:www-data /opt/iptvpanel2 >> /dev/null 2>&1
	chmod -R 777 /opt/iptvpanel2/www/vod >> /dev/null 2>&1
	chmod -R 777 /opt/iptvpanel2/www/hls >> /dev/null 2>&1
	wget -O /dev/null "http://cr.iptvpanel.net/install.php?cmsurl=$CMSURL&servername=$SERVERNAME&serverip=$SERVERIP&serverintip=$SERVERINTIP&iscms=$ISCMS&isstreamer=$ISSTREAMER" > /dev/null 2>&1
	killall -9 galaxy2 >> /dev/null 2>&1
	echo -e "${BGreen}\tDone.${Reset}"
	
}


### STARTING PROPER SCRIPT ### 
tweakSystem;
setLocale;
setMirrors;
installBase;

# Gathering latest version of software
CMSVER=`curl -s "http://cr.iptvpanel.net/VERSION2" | xargs`
HITVER=`curl -s "http://cr.iptvpanel.net/GALAXYVERSION2" | xargs`

# UPGARDE IF EXISTING INSTALLATION
if [ -f /opt/iptvpanel2/etc/iptvpanel.conf ]; then
	. /opt/iptvpanel2/etc/iptvpanel.conf >> /dev/null 2>&1
	if [ -z "$CMSPORT" ]; then
		CMSPORT="80"
	fi
	CURVER=`cat /opt/iptvpanel2/etc/VERSION`
	# CHECK IF UPDATE NEEDED
	if [ "$CMSVER" = "$CURVER" ]; then
		if [ "$1" != "force" ]; then
			echo -e "${BCyan}You already have the latest version ${BYellow}v$CMSVER${BCyan}, no update to make!${Reset}";
			exit 0;
		else 
			echo -e "${BCyan}Forcing update!${Reset}";
		fi
	fi
	setupMcrypt;
	upgradeFiles;
	updateSSHPassword;
	if [ "$ISCMS" = "1" ]; then
		# UPDATE CMS
		echo -e "${BGreen}Updating CMS${Reset}";
        	psql -U postgres iptvpanel2 -c "UPDATE settings SET config_value = '$CMSVER' WHERE config_name = 'current_version' OR config_name = 'new_version'" >> /dev/null 2>&1
	fi
	if [ "$ISSTREAMER" = "1" ]; then
		# UPDATE STREAMER
		echo -e "${BGreen}Updating streamer${Reset}";
		addServer;
		# updateServerDatabasePass;
	fi
	cleanUp;
	echo -e "${BGreen}Updated to version ${BYellow}v$CMSVER${BGreen} !${Reset}";
# NEW INSTALL
else
	echo -ne "${BWhite}What to install ? ( 1|CMS , 2|STREAMER , 3|ALL-IN-ONE ) : ${Reset}";
	read SERVERTYPE
	if [ "$SERVERTYPE" = "1" ]; then
		ISCMS=1
		ISSTREAMER=0
	fi
	if [ "$SERVERTYPE" = "2" ]; then
		ISCMS=0
		ISSTREAMER=1
	fi
	if [ "$SERVERTYPE" = "3" ]; then
		ISCMS=1
		ISSTREAMER=1
	fi
	if [[ "$SERVERTYPE" != "1" && "$SERVERTYPE" != "2" && "$SERVERTYPE" != "3" ]]; then
		echo -e "${Red}You didn't selected anything! Aborting.${Reset}";
		exit;
	fi
	echo -ne "${BWhite}CMS URL without http:// ( subdomain.domain.com ) : ${Reset}";
	read CMSURL
	if [ -z "$CMSURL" ]; then
		echo -e "${BRed}You need to provide CMS URL !${Reset}";
		exit 1;
	fi
	echo -ne "${BWhite}CMS PORT, numeric only ( 8080 ) : ${Reset}";
	read CMSPORT
	if [ -z "$CMSPORT" ]; then
		CMSPORT="80"
	fi
	if [[ "$SERVERTYPE" = "3" && "$CMSPORT" = "80" ]]; then
		echo -e "${Red}You MUST use different port for cms if you want to install all in one! Aborting.${Reset}";
		exit;
	fi
	echo -ne "${BWhite}SERVER NAME ( ex. s01.domain.com ) : ${Reset}";
	read SERVERNAME
	if [ -z "$SERVERNAME" ]; then
		echo -e "${BRed}You need to provide SERVER NAME !${Reset}";
		exit 1;
	fi
	echo -ne "${BWhite}EXTERNAL IP ADDRESS : ${Reset}";
	read SERVERIP
	if [ -z "$SERVERIP" ]; then
		echo -e "${BRed}You need to provide EXTERNAL IP !${Reset}";
		exit 1;
	fi
	echo -ne "${BWhite}PRIVATE IP ADDRESS, if you don't have, same as above : ${Reset}";
	read SERVERINTIP
	if [ -z "$SERVERINTIP" ]; then
		echo -e "${BRed}You need to provide PRIVATE IP !${Reset}";
		exit 1;
	fi
	#writeConfig;
	upgradeFiles;
	### FROM HERE WE INSTALL EVERYTHING ###
	if [ "$ISCMS" = "1" ]; then
		# Install packages
		installCMSPackages;
		# Install INITIAL DATABASE
		installDatabase;
		# Setup configs
		setupCMS;
	fi
		
	if [ "$ISSTREAMER" = "1" ]; then
		# Install packages
		installStreamerPackages;
		# Setup streamer
		setupStreamer;
		# Make new ssh password
		updateSSHPassword;
		# Add the streamer to database
		addServer;
	fi
	# Removing temp files, restarting services
	writeConfig;
	cleanUp;
	echo -e "${BGreen}Installed version ${BYellow}v$CMSVER${BGreen} !${Reset}";	
fi
