#!/bin/sh

LX_BASE=""
LX_VERSION=""

if [ -r /etc/os-release ]; then
    . /etc/os-release
	if [ $ID = arch ]; then
		LX_BASE=$ID
    elif [ $ID = ubuntu ]; then
		LX_BASE=$ID
		LX_VERSION=$VERSION_ID
	elif [ ! -z "$UBUNTU_CODENAME" ] ; then
		LX_BASE="ubuntu"
		LX_VERSION=$VERSION_ID
    else
		LX_BASE=$ID
		LX_VERSION=$VERSION
    fi
else
    echo "無法識別您的發行版。請打開腳本並手動運行命令。"
	exit
fi

SUR_MODEL="$(dmidecode | grep "Product Name" -m 1 | xargs | sed -e 's/Product Name: //g')"
SUR_SKU="$(dmidecode | grep "SKU Number" -m 1 | xargs | sed -e 's/SKU Number: //g')"

echo "正在使用 $SUR_MODEL 執行 $LX_BASE 版本 $LX_VERSION。\n"

read -rp "如果上方的資訊正確,請按下鍵盤上的Enter鍵，否則請按下Crlt+C 結束程序並手動運行命令。" cont;echo

echo "\n正在加載主要文件..."

echo "正在拷貝文件到您的電腦..."
for dir in $(ls root/); do cp -Rb root/$dir/* /$dir/; done

echo "正在製作 /lib/systemd/system-sleep/sleep executable...\n"
chmod a+x /lib/systemd/system-sleep/sleep

echo "建議在休眠狀態下關機。如果您選擇使用休眠模式，請確保已按照自述文件中的說明設置了交換文件.\n"
read -rp "你希望吧休眠改爲關機嗎 (y/n) " usehibernate;echo

if [ "$usehibernate" = "y" ]; then
	if [ "$LX_BASE" = "ubuntu" ] && [ 1 -eq "$(echo "${LX_VERSION} >= 17.10" | bc)" ]; then
		echo "正在替換文件...\n"
		ln -sfb /lib/systemd/system/hibernate.target /etc/systemd/system/suspend.target && sudo ln -sfb /lib/systemd/system/systemd-hibernate.service /etc/systemd/system/systemd-suspend.service
	else
		echo "正在替換文件...\n"
		ln -sfb /usr/lib/systemd/system/hibernate.target /etc/systemd/system/suspend.target && sudo ln -sfb /usr/lib/systemd/system/systemd-hibernate.service /etc/systemd/system/systemd-suspend.service
	fi
else
	echo "將不會更改休眠模式檔案\n"
fi

echo "已修補的libwacom軟件包可更好地支持Surface Pen。如果打算使用Surface Pen，建議安裝它們！\n"

read -rp "你希望安裝已修補的libwacom軟件包嗎？ (y/n) " uselibwacom;echo

if [ "$uselibwacom" = "y" ]; then
	echo "正在安裝已修補的libwacom軟件包..."
		dpkg -i packages/libwacom/*.deb
		apt-mark hold libwacom
else
	echo "將不會安裝已修補的libwacom軟件包"
fi

echo "\n此倉庫隨附示例xorg和Pulse音頻配置。如果您選擇保留它們，請確保重命名它們並取消註釋您想要保留的內容！\n"

read -rp "你希望移除Intel 的 Xorg音頻配置嗎? (y/n) " removexorg;echo

if [ "$removexorg" = "y" ]; then
	echo "正在移除Intel Xorg音頻配置..."
		rm /etc/X11/xorg.conf.d/20-intel_example.conf
else
	echo "將不會移除在路徑 /etc/X11/xorg.conf.d/20-intel_example.conf 下的 Intel Xorg 音頻配置"
fi

read -rp "\n您是否要刪除示例Pulse音頻配置文件? (y/n) " removepulse;echo

if [ "$removepulse" = "y" ]; then
	echo "正在移除示例Pulse音頻配置文件..."
		rm /etc/pulse/daemon_example.conf
		rm /etc/pulse/default_example.pa
else
	echo "將不會移除在 /etc/pulse/*_example.* 目錄下的Pulse引文配置文件"
fi

if [ "$SUR_MODEL" = "Surface Pro 3" ]; then
	echo "\n正在正在安裝適用於Surface Pro 3 的 i915 固件...\n"
	mkdir -p /lib/firmware/i915
	unzip -o firmware/i915_firmware_bxt.zip -d /lib/firmware/i915/

	echo "\n移除Surface Pro 3不需要的udev規則...\n"
	rm /etc/udev/rules.d/98-keyboardscovers.rules
fi

if [ "$SUR_MODEL" = "Surface Pro" ]; then
	echo "\n正在安裝適用於 Surface Pro 2017 的 IPTS 固件...\n"
	mkdir -p /lib/firmware/intel/ipts
	unzip -o firmware/ipts_firmware_v102.zip -d /lib/firmware/intel/ipts/

	echo "\n正在安裝適用於Surface Pro 2017 的 i915 固件...\n"
	mkdir -p /lib/firmware/i915
	unzip -o firmware/i915_firmware_kbl.zip -d /lib/firmware/i915/
fi

if [ "$SUR_MODEL" = "Surface Pro 4" ]; then
	echo "\n正在安裝適用於 Surface Pro 4 的 IPTS 固件...\n"
	mkdir -p /lib/firmware/intel/ipts
	unzip -o firmware/ipts_firmware_v78.zip -d /lib/firmware/intel/ipts/

	echo "\n正在安裝適用於Surface Pro 4 的 i915 固件...\n"
	mkdir -p /lib/firmware/i915
	unzip -o firmware/i915_firmware_skl.zip -d /lib/firmware/i915/
fi

if [ "$SUR_MODEL" = "Surface Pro 2017" ]; then
	echo "\n正在安裝適用於 Surface Pro 2017 的 IPTS 固件...\n"
	mkdir -p /lib/firmware/intel/ipts
	unzip -o firmware/ipts_firmware_v102.zip -d /lib/firmware/intel/ipts/

	echo "\n正在安裝適用於Surface Pro 2017 的 i915 固件...\n"
	mkdir -p /lib/firmware/i915
	unzip -o firmware/i915_firmware_kbl.zip -d /lib/firmware/i915/
fi

if [ "$SUR_MODEL" = "Surface Pro 6" ]; then
	echo "\n正在安裝適用於 Surface Pro 6 的 IPTS 固件...\n"
	mkdir -p /lib/firmware/intel/ipts
	unzip -o firmware/ipts_firmware_v102.zip -d /lib/firmware/intel/ipts/

	echo "\n正在安裝適用於Surface Pro 6 的 i915 固件...\n"
	mkdir -p /lib/firmware/i915
	unzip -o firmware/i915_firmware_kbl.zip -d /lib/firmware/i915/
fi

if [ "$SUR_MODEL" = "Surface Studio" ]; then
	echo "\n正在安裝適用於 Surface Studio 的 IPTS 固件...\n"
	mkdir -p /lib/firmware/intel/ipts
	unzip -o firmware/ipts_firmware_v76.zip -d /lib/firmware/intel/ipts/

	echo "\n正在安裝適用於Surface Studio 的 i915 固件...\n"
	mkdir -p /lib/firmware/i915
	unzip -o firmware/i915_firmware_skl.zip -d /lib/firmware/i915/
fi

if [ "$SUR_MODEL" = "Surface Laptop" ]; then
	echo "\n正在安裝適用於 Surface Laptop 的 IPTS 固件...\n"
	mkdir -p /lib/firmware/intel/ipts
	unzip -o firmware/ipts_firmware_v79.zip -d /lib/firmware/intel/ipts/

	echo "\n正在安裝適用於Surface Laptop 的 i915 固件...\n"
	mkdir -p /lib/firmware/i915
	unzip -o firmware/i915_firmware_kbl.zip -d /lib/firmware/i915/
fi

if [ "$SUR_MODEL" = "Surface Laptop 2" ]; then
	echo "\n正在安裝適用於 Surface Laptop 2 的 IPTS 固件...\n"
	mkdir -p /lib/firmware/intel/ipts
	unzip -o firmware/ipts_firmware_v79.zip -d /lib/firmware/intel/ipts/

	echo "\n正在安裝適用於Surface Laptop 2 的 i915 固件...\n"
	mkdir -p /lib/firmware/i915
	unzip -o firmware/i915_firmware_kbl.zip -d /lib/firmware/i915/
fi

if [ "$SUR_MODEL" = "Surface Book" ]; then
	echo "\n正在安裝適用於 Surface Book 的 IPTS 固件...\n"
	mkdir -p /lib/firmware/intel/ipts
	unzip -o firmware/ipts_firmware_v76.zip -d /lib/firmware/intel/ipts/

	echo "\n正在安裝適用於Surface Book 的 i915 固件...\n"
	mkdir -p /lib/firmware/i915
	unzip -o firmware/i915_firmware_skl.zip -d /lib/firmware/i915/
fi

if [ "$SUR_MODEL" = "Surface Book 2" ]; then
	echo "\n正在安裝適用於 Surface Book 2 的 IPTS 固件...\n"
	mkdir -p /lib/firmware/intel/ipts
	if [ "$SUR_SKU" = "Surface_Book_1793" ]; then
		unzip -o firmware/ipts_firmware_v101.zip -d /lib/firmware/intel/ipts/
	else
		unzip -o firmware/ipts_firmware_v137.zip -d /lib/firmware/intel/ipts/
	fi

	echo "\n正在安裝適用於Surface Book 2 的 i915 固件...\n"
	mkdir -p /lib/firmware/i915
	unzip -o firmware/i915_firmware_kbl.zip -d /lib/firmware/i915/

	echo "\n正在安裝適用於 Surface Book 2 的 Nvidia 固件...\n"
	mkdir -p /lib/firmware/nvidia/gp108
	unzip -o firmware/nvidia_firmware_gp108.zip -d /lib/firmware/nvidia/gp108/
	mkdir -p /lib/firmware/nvidia/gv100
	unzip -o firmware/nvidia_firmware_gv100.zip -d /lib/firmware/nvidia/gv100/
fi

if [ "$SUR_MODEL" = "Surface Go" ]; then
	echo "\n正在安裝適用於 Surface Go 的 ath10k 固件...\n"
	mkdir -p /lib/firmware/ath10k
	unzip -o firmware/ath10k_firmware.zip -d /lib/firmware/ath10k/

	if [ ! -f "/etc/init.d/surfacego-touchscreen" ]; then
		echo "\n正在安裝適用於 Surface Go 觸摸屏的修補電源控制...\n"
		echo "echo \"on\" > /sys/devices/pci0000:00/0000:00:15.1/i2c_designware.1/power/control" > /etc/init.d/surfacego-touchscreen
		chmod 755 /etc/init.d/surfacego-touchscreen
		update-rc.d surfacego-touchscreen defaults
	fi
fi

echo "正在安裝通用 marvell 固件...\n"
mkdir -p /lib/firmware/mrvl/
unzip -o firmware/mrvl_firmware.zip -d /lib/firmware/mrvl/

echo "正在安裝通用 mwlwifi 固件...\n"
mkdir -p /lib/firmware/mwlwifi/
unzip -o firmware/mwlwifi_firmware.zip -d /lib/firmware/mwlwifi/

read -rp "\n你希望把你的 Ubuntu 系統時間改爲當地時間嗎而不是國際標準時間嗎？這樣可以修復某些在Windows系統下的啓動問題. (y/n) " uselocaltime;echo

if [ "$uselocaltime" = "y" ]; then
	echo "正在設置時鐘...\n"

	timedatectl set-local-rtc 1
	hwclock --systohc --localtime
else
	echo "將不會設置時鐘\n"
fi

read -rp "您是否想要此腳本為您下載並安裝最新的內核? (y/n) " autoinstallkernel;echo


if [ "$autoinstallkernel" = "y" ]; then
	echo "正在下載最新版的內核..."

	urls=$(curl --silent "https://api.github.com/repos/jakeday/linux-surface/releases/latest" | tr ',' '\n' | grep '"browser_download_url":' | sed -E 's/.*"([^"]+)".*/\1/')

	resp=$(wget -P tmp $urls)

	echo "正在安裝最新版的內核...\n"

	dpkg -i tmp/*.deb
	rm -rf tmp
else
	echo "將不會安裝最新版的內核"
fi

echo "\n固件安裝完畢！我們將會在3秒爲您重啓!"

sleep 1

echo "\n固件安裝完畢！我們將會在2秒內爲您重啓!"

sleep 1

echo "\n固件安裝完畢！我們將會在1秒內爲您重啓!"

reboot