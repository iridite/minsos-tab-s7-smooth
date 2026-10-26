#!/system/bin/sh
# 99-smooth-performance.sh
# MinsOS Galaxy Tab S7 (T870) Ultimate Smoothness & 120Hz Lock Optimization
# Author: iridite

# 1. Lock 120Hz display refresh rate (prevent unwanted 60Hz drop)
settings put system min_refresh_rate 120.0
settings put system peak_refresh_rate 120.0
settings put global min_refresh_rate 120.0
settings put global peak_refresh_rate 120.0

# 2. Fix SurfaceFlinger Phase Offsets & Backpressure
RP=/data/adb/ksu/bin/resetprop
[ -x "$RP" ] || RP=/data/adb/magisk/resetprop
[ -x "$RP" ] || RP=resetprop

if which "$RP" >/dev/null 2>&1 || [ -x "$RP" ]; then
    # Clear overly strict 0.1ms phase offsets from stock vendor build.prop
    $RP -d debug.sf.early_app_phase_offset_ns
    $RP -d debug.sf.early_phase_offset_ns
    $RP -d debug.sf.high_fps_early_phase_offset_ns
    $RP -d debug.sf.high_fps_late_app_phase_offset_ns
    $RP -d debug.sf.high_fps_late_sf_phase_offset_ns
    $RP -d debug.sf.disable_backpressure
    $RP -d debug.sf.enable_gl_backpressure
    
    # Relax VSYNC app phase offsets to standard 1.5ms (give UI thread breathing room)
    $RP debug.sf.early_app_phase_offset_ns 1500000
    $RP debug.sf.early_phase_offset_ns 1500000
    $RP debug.sf.high_fps_early_phase_offset_ns 1500000
    $RP debug.sf.high_fps_late_app_phase_offset_ns 1500000
    $RP debug.sf.high_fps_late_sf_phase_offset_ns 1500000

    # Enable native GPU Kawase window blur (avoid multi-pass CPU downsampling)
    $RP persist.sys.unica.nativeblur true

    # Disable RAM Plus (virtual memory zram thrashing)
    $RP persist.sys.zram.ram_expand_size 0

    # Expand ART initial heap start size to prevent startup GC thrashing
    $RP dalvik.vm.heapstartsize 16m
fi

# 3. CPU Governor (Schedutil) - 4x faster frequency ramp-up on touch
for p in /sys/devices/system/cpu/cpufreq/policy*; do
    if [ -f "$p/schedutil/rate_limit_us" ]; then
        echo 500 > "$p/schedutil/rate_limit_us"
    fi
done

# Raise Big cluster and Prime core minimum frequency to prevent cold frame stutter
if [ -f /sys/devices/system/cpu/cpufreq/policy4/scaling_min_freq ]; then
    echo 1056000 > /sys/devices/system/cpu/cpufreq/policy4/scaling_min_freq
fi
if [ -f /sys/devices/system/cpu/cpufreq/policy7/scaling_min_freq ]; then
    echo 1075200 > /sys/devices/system/cpu/cpufreq/policy7/scaling_min_freq
fi

# 4. GPU Minimum Frequency to 400MHz
if [ -f /sys/class/kgsl/kgsl-3d0/devfreq/min_freq ]; then
    echo 400000000 > /sys/class/kgsl/kgsl-3d0/devfreq/min_freq
fi

# 5. UFS Flash Read-ahead Cache (512KB)
for q in /sys/block/sd*/queue/read_ahead_kb; do
    if [ -f "$q" ]; then
        echo 512 > "$q"
    fi
done

# 6. Memory & Kernel VFS Tuning
if [ -f /proc/sys/vm/swappiness ]; then
    echo 60 > /proc/sys/vm/swappiness
fi
if [ -f /proc/sys/vm/vfs_cache_pressure ]; then
    echo 50 > /proc/sys/vm/vfs_cache_pressure
fi

# 7. TCP Westwood+ for Lossy Wi-Fi & Wi-Fi Low Latency
if [ -f /proc/sys/net/ipv4/tcp_congestion_control ]; then
    echo westwood > /proc/sys/net/ipv4/tcp_congestion_control
fi
cmd wifi set-power-save-mode 0 >/dev/null 2>&1

# 8. Animation scales & Touch Sensitivity
settings put global window_animation_scale 1.0
settings put global transition_animation_scale 1.0
settings put global animator_duration_scale 1.0
settings put secure high_touch_sensitivity 1
settings put global ram_expand_size 0
