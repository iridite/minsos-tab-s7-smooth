#!/system/bin/sh
# debloat.sh — Clean up bloatware and telemetry on Samsung Galaxy Tab S7 (MinOS)
# Author: iridite

echo "=== MinsOS Tab S7 System Debloater ==="

# Category A: Telemetry, Ad, Third-party
CAT_A="
com.microsoft.appmanager
com.hiya.star
com.samsung.android.kidsinstaller
com.samsung.android.knox.analytics.uploader
com.samsung.android.aremoji
com.samsung.android.app.camera.sticker.facearavatar.preload
com.samsung.android.stickercenter
com.samsung.android.rubin.app
"

# Category B: Bixby Voice & Assistant ecosystem
CAT_B="
com.samsung.android.bixby.wakeup
com.samsung.android.bixby.agent
com.samsung.android.bixbyvision.framework
"

# Category C: Functional & Ecosystem Optional
CAT_C="
com.samsung.android.game.gos
com.samsung.android.game.gametools
com.samsung.android.scloud
com.samsung.android.secondscreen
com.samsung.android.mcfserver
"

# Category D: Cellular / IMS Leftovers on Wi-Fi Tablet (T870)
CAT_D="
com.samsung.android.app.telephonyui
com.sec.imsservice
com.sec.imslogger
"

# Category E: Built-in Browser & Galaxy Store
CAT_E="
com.sec.android.app.sbrowser
com.sec.android.app.samsungapps
com.sec.android.app.billing
"

ALL_PKGS="$CAT_A $CAT_B $CAT_C $CAT_D $CAT_E"

count=0
success_count=0

for pkg in $ALL_PKGS; do
    count=$((count + 1))
    echo -n "[$count] Uninstalling $pkg ... "
    res=$(pm uninstall -k --user 0 "$pkg" 2>&1)
    if [ "$res" = "Success" ]; then
        echo "OK"
        success_count=$((success_count + 1))
    else
        echo "Skipped / Already removed"
    fi
    am force-stop "$pkg" >/dev/null 2>&1
done

echo ""
echo "=== Done! Successfully uninstalled $success_count / $count packages for user 0 ==="
echo "Note: To restore any package at any time, run: pm install-existing --user 0 <package_name>"
