#!/sbin/busybox sh
# Logging
/sbin/busybox cp /data/user.log /data/user.log.bak
/sbin/busybox rm /data/user.log
exec >>/data/user.log
exec 2>&1

echo $(date) START of post-init.sh

# Remount rootfs rw
  #/sbin/busybox mount rootfs -o remount,rw

##### Early-init phase #####

# Android Logger enable tweak
#if /sbin/busybox [ "`/sbin/busybox grep ANDROIDLOGGER /system/etc/tweaks.conf`" ]; then
#  insmod /lib/modules/logger.ko
#fi

#activate log
if /sbin/busybox [ "`/sbin/busybox cat /data/tweaks.conf | grep logger=on`" ];
then
   insmod /lib/modules/logger.ko
fi

#activate defrag
if /sbin/busybox [ "`/sbin/busybox cat /data/tweaks.conf | grep defrag=on`" ];
then
  echo "defrag: on"
  for i in \
    `find /data -iname "*.db"`
    do \
      sqlite3 $i 'VACUUM;'; 
  done
fi

#setup i/o governor
if /sbin/busybox [ "`/sbin/busybox cat /data/tweaks.conf | grep io=sio`" ];
then
   echo "sio" > /sys/block/mmcblk0/queue/scheduler
fi
if /sbin/busybox [ "`/sbin/busybox cat /data/tweaks.conf | grep io=cfq`" ];
then
   echo "cfq" > /sys/block/mmcblk0/queue/scheduler
fi
if /sbin/busybox [ "`/sbin/busybox cat /data/tweaks.conf | grep io=bfq`" ];
then
   echo "bfq" > /sys/block/mmcblk0/queue/scheduler
fi

#setup  cpu governor
if /sbin/busybox [ "`/sbin/busybox cat /data/tweaks.conf | grep cpu=pegasusq`" ];
then
   echo "pegasusq" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
fi
if /sbin/busybox [ "`/sbin/busybox cat /data/tweaks.conf | grep cpu=ondemand`" ];
then
   echo "ondemand" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
fi
if /sbin/busybox [ "`/sbin/busybox cat /data/tweaks.conf | grep cpu=interactive`" ];
then
   echo "interactive" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
fi
if /sbin/busybox [ "`/sbin/busybox cat /data/tweaks.conf | grep cpu=lulzactive`" ];
then
   echo "lulzactive" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
fi
if /sbin/busybox [ "`/sbin/busybox cat /data/tweaks.conf | grep cpu=smartassV2`" ];
then
   echo "smartassV2" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
fi

# IPv6 privacy tweak
#if /sbin/busybox [ "`/sbin/busybox grep IPV6PRIVACY /system/etc/tweaks.conf`" ]; then
  echo "2" > /proc/sys/net/ipv6/conf/all/use_tempaddr
#fi

# Enable CIFS tweak
#if /sbin/busybox [ "`/sbin/busybox grep CIFS /system/etc/tweaks.conf`" ]; then
#  /sbin/busybox insmod /lib/modules/cifs.ko
#else
#  /sbin/busybox rm /lib/modules/cifs.ko
#fi

# Tweak cfq io scheduler
  for i in $(/sbin/busybox find /sys/block/mmc*)
  do echo "0" > $i/queue/rotational
    echo "0" > $i/queue/iostats
    echo "8" > $i/queue/iosched/quantum
    echo "4" > $i/queue/iosched/slice_async_rq
    echo "1" > $i/queue/iosched/low_latency
    echo "0" > $i/queue/iosched/slice_idle
    echo "1" > $i/queue/iosched/back_seek_penalty
    echo "1000000000" > $i/queue/iosched/back_seek_max
  done

# Remount all partitions with noatime
  for k in $(/sbin/busybox mount | /sbin/busybox grep relatime | /sbin/busybox cut -d " " -f3)
  do
        sync
        /sbin/busybox mount -o remount,noatime $k
  done

# Remount ext4 partitions with optimizations
  for k in $(/sbin/busybox mount | /sbin/busybox grep ext4 | /sbin/busybox cut -d " " -f3)
  do
        sync
        /sbin/busybox mount -o remount,commit=15 $k
  done
  
# Miscellaneous tweaks
  echo "4096" > /proc/sys/vm/min_free_kbytes
  echo "0" > /proc/sys/vm/oom_kill_allocating_task;
  echo "0" > /proc/sys/vm/panic_on_oom;
  echo "0" > /proc/sys/vm/laptop_mode;
  echo "0" > /proc/sys/vm/swappiness
  echo "50" > /proc/sys/vm/vfs_cache_pressure
  echo "90" > /proc/sys/vm/dirty_ratio
  echo "70" > /proc/sys/vm/dirty_background_ratio

# CFS scheduler tweaks
  echo HRTICK > /sys/kernel/debug/sched_features

# SD cards (mmcblk) read ahead tweaks
  echo "256" > /sys/block/mmcblk0/bdi/read_ahead_kb
  echo "256" > /sys/block/mmcblk1/bdi/read_ahead_kb

# TCP tweaks
  echo "2" > /proc/sys/net/ipv4/tcp_syn_retries
  echo "2" > /proc/sys/net/ipv4/tcp_synack_retries
  echo "10" > /proc/sys/net/ipv4/tcp_fin_timeout
# Implement Additional TCP Tweaks
  echo "0" > /proc/sys/net/ipv4/tcp_timestamps
  echo "1" > /proc/sys/net/ipv4/tcp_tw_reuse
  echo "1" > /proc/sys/net/ipv4/tcp_sack
  echo "1" > /proc/sys/net/ipv4/tcp_tw_recycle
  echo "1" > /proc/sys/net/ipv4/tcp_window_scaling
  echo "5" > /proc/sys/net/ipv4/tcp_keepalive_probes
  echo "30" > /proc/sys/net/ipv4/tcp_keepalive_intvl
  echo "30" > /proc/sys/net/ipv4/tcp_fin_timeout
  echo "404480" > /proc/sys/net/core/wmem_max
  echo "404480" > /proc/sys/net/core/rmem_max
  echo "256960" > /proc/sys/net/core/rmem_default
  echo "256960" > /proc/sys/net/core/wmem_default
  echo "4096,16384,404480" > /proc/sys/net/ipv4/tcp_wmem

# SCHED_MC power savings level
  echo "1" > /sys/devices/system/cpu/sched_mc_power_savings

# Turn off debugging for certain modules
  echo "0" > /sys/module/wakelock/parameters/debug_mask
  echo "0" > /sys/module/userwakelock/parameters/debug_mask
  echo "0" > /sys/module/earlysuspend/parameters/debug_mask
  echo "0" > /sys/module/alarm/parameters/debug_mask
  echo "0" > /sys/module/alarm_dev/parameters/debug_mask
  echo "0" > /sys/module/binder/parameters/debug_mask

##### Install SU #####

# Check for auto-root bypass config file

if [ -f /system/.noautoroot ] || [ -f /data/.noautoroot ];
then
	echo "File .noautoroot found. Auto-root will be bypassed."
else
# Start of auto-root section
if [ -f /system/xbin/su ] || [ -f /system/bin/su ];
then
	echo "su already exists"
else
	echo "Copying su binary"
	/sbin/busybox mount /system -o remount,rw
	/sbin/busybox rm /system/bin/su
	/sbin/busybox rm /system/xbin/su
	/sbin/busybox cp /res/misc/su /system/xbin/su
	/sbin/busybox chown 0.0 /system/xbin/su
	/sbin/busybox chmod 6755 /system/xbin/su
	/sbin/busybox mount /system -o remount,ro
fi

if [ -f /system/app/Superuser.apk ] || [ -f /data/app/Superuser.apk ];
then
	echo "Superuser.apk already exists"
else
	echo "Copying Superuser.apk"
	/sbin/busybox mount /system -o remount,rw
	/sbin/busybox rm /system/app/Superuser.apk
	/sbin/busybox rm /data/app/Superuser.apk
	/sbin/busybox cp /res/misc/Superuser.apk /system/app/Superuser.apk
	/sbin/busybox chown 0.0 /system/app/Superuser.apk
	/sbin/busybox chmod 644 /system/app/Superuser.apk
	/sbin/busybox mount /system -o remount,ro
fi
# End of auto-root section
fi

echo $(date) PRE-INIT DONE of post-init.sh
##### Post-init phase #####
sleep 12

# Cleanup busybox
  #/sbin/busybox rm /sbin/busybox
  #/sbin/busybox mount rootfs -o remount,ro

# init.d support
echo $(date) USER EARLY INIT START from /system/etc/init.d
if cd /system/etc/init.d >/dev/null 2>&1 ; then
    for file in E* ; do
        if ! cat "$file" >/dev/null 2>&1 ; then continue ; fi
        echo "START '$file'"
        /system/bin/sh "$file"
        echo "EXIT '$file' ($?)"
    done
fi
echo $(date) USER EARLY INIT DONE from /system/etc/init.d

echo $(date) USER EARLY INIT START from /data/init.d
if cd /data/init.d >/dev/null 2>&1 ; then
    for file in E* ; do
        if ! cat "$file" >/dev/null 2>&1 ; then continue ; fi
        echo "START '$file'"
        /system/bin/sh "$file"
        echo "EXIT '$file' ($?)"
    done
fi
echo $(date) USER EARLY INIT DONE from /data/init.d

echo $(date) USER INIT START from /system/etc/init.d
if cd /system/etc/init.d >/dev/null 2>&1 ; then
    for file in S* ; do
        if ! ls "$file" >/dev/null 2>&1 ; then continue ; fi
        echo "START '$file'"
        /system/bin/sh "$file"
        echo "EXIT '$file' ($?)"
    done
fi
echo $(date) USER INIT DONE from /system/etc/init.d

echo $(date) USER INIT START from /data/init.d
if cd /data/init.d >/dev/null 2>&1 ; then
    for file in S* ; do
        if ! ls "$file" >/dev/null 2>&1 ; then continue ; fi
        echo "START '$file'"
        /system/bin/sh "$file"
        echo "EXIT '$file' ($?)"
    done
fi
echo $(date) USER INIT DONE from /data/init.d

echo $(date) END of post-init.sh
