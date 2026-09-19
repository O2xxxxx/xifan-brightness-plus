#!/system/bin/sh
# 整合版：一套挂载循环 + 属性设置，替代原来两个模块三处重复的 mount
MODDIR=${0%/*}
LOG=/data/local/tmp/brightnessplus.log
: > $LOG

FILES="my_product/vendor/etc/display_brightness_config_P_3.xml
my_product/vendor/etc/display_brightness_app_list.xml
my_product/vendor/etc/multimedia_display_feature_config.xml
my_product/vendor/etc/multimedia_display_trackpoint_config.xml
system_ext/etc/display_brightness_config_common.xml
vendor/etc/displayconfig/display_id_4630946450791512195.xml
vendor/etc/displayconfig/display_id_4630946614210407555.xml
vendor/etc/displayconfig/display_id_4630946994637926275.xml
vendor/etc/displayconfig/display_id_4630947039571902850.xml"

echo "$FILES" | while read -r f; do
  [ -z "$f" ] && continue
  if [ ! -f "/$f" ]; then
    echo "$(date '+%H:%M:%S') MISS /$f" >> $LOG
  elif mount --bind "$MODDIR/$f" "/$f"; then
    echo "$(date '+%H:%M:%S') OK   /$f" >> $LOG
  else
    echo "$(date '+%H:%M:%S') FAIL /$f" >> $LOG
  fi
done

# 属性：沿用 brightnessmax 的设置（去掉了指向不存在文件的 uir_config 挂载）
for kv in "sys.display.hbm.threshold 100" \
          "persist.sys.oplus.sunlight.threshold 500" \
          "persist.sys.oplus.sunlight.enable 1" \
          "persist.sys.brightness.auto_response_speed 1" \
          "ro.config.auto_brightness_speed_up 1" \
          "persist.sys.auto_brightness.smooth_enable 0" \
          "persist.sys.brightness.thermal_protect_enable 0"; do
  resetprop $kv
done

P3=/my_product/vendor/etc/display_brightness_config_P_3.xml
echo "$(date '+%H:%M:%S') 生效曲线: $(grep -o '<lux_table_mode>[0-9]*' $P3) $(grep -o '<hbm_lux_table_mode>[0-9]*' $P3)" >> $LOG
echo "$(date '+%H:%M:%S') done" >> $LOG
