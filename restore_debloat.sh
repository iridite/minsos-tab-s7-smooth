#!/system/bin/sh
# restore_debloat.sh — Restore pre-installed apps uninstalled by debloat.sh
# Author: iridite

echo "=== MinsOS Tab S7 App Restorer ==="

PKGS="
com.microsoft.appmanager
com.hiya.star
com.samsung.android.kidsinstaller
com.samsung.android.knox.analytics.uploader
com.samsung.android.aremoji
com.samsung.android.app.camera.sticker.facearavatar.preload
com.samsung.android.stickercenter
com.samsung.android.rubin.app
com.samsung.android.bixby.wakeup
com.samsung.android.bixby.agent
com.samsung.android.bixbyvision.framework
com.samsung.android.game.gos
com.samsung.android.game.gametools
com.samsung.android.scloud
com.samsung.android.secondscreen
com.samsung.android.mcfserver
com.samsung.android.app.telephonyui
com.sec.imsservice
com.sec.imslogger
com.sec.android.app.sbrowser
com.sec.android.app.samsungapps
com.sec.android.app.billing
"

count=0
success_count=0

for pkg in $PKGS; do
    count=$((count + 1))
    echo -n "[$count] Restoring $pkg ... "
    res=$(pm install-existing --user 0 "$pkg" 2>&1)
    if echo "$res" | grep -q "installed for user"; then
        echo "Restored"
        success_count=$((success_count + 1))
    else
        echo "Failed or already present"
    fi
done

echo ""
echo "=== Done! Restored $success_count packages ==="
