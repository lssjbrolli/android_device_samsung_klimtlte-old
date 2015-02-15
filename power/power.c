/*
 * Copyright (C) 2012 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <dirent.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
//#define LOG_NDEBUG 0

#define LOG_TAG "Power HAL"
#include <utils/Log.h>

#include <hardware/hardware.h>
#include <hardware/power.h>

#define BOOSTPULSE_PATH "/sys/devices/system/cpu/cpufreq/interactive/boostpulse"
#define BOOST_PATH "/sys/devices/system/cpu/cpufreq/interactive/boost"
#define CPU_MAX_FREQ_PATH "/sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq"
//BOOST_PULSE_DURATION and BOOT_PULSE_DURATION_STR should always be in sync
#define BOOST_PULSE_DURATION 40000
#define BOOST_PULSE_DURATION_STR "40000"
#define NSEC_PER_SEC 1000000000
#define USEC_PER_SEC 1000000
#define NSEC_PER_USEC 100
#define LOW_POWER_MAX_FREQ "650000"
#define NORMAL_MAX_FREQ "1900000"

struct klimtlte_power_module {
    struct power_module base;
    pthread_mutex_t lock;
    int boostpulse_fd;
    int boostpulse_warned;
    const char *touchscreen_power_path;
};

static void sysfs_write(const char *path, char *s)
{
    char buf[80];
    int len;
    int fd = open(path, O_WRONLY);

    if (fd < 0) {
        strerror_r(errno, buf, sizeof(buf));
        ALOGE("Error opening %s: %s\n", path, buf);
        return;
    }

    len = write(fd, s, strlen(s));
    if (len < 0) {
        strerror_r(errno, buf, sizeof(buf));
        ALOGE("Error writing to %s: %s\n", path, buf);
    }

    close(fd);
}

static void init_touchscreen_power_path(struct klimtlte_power_module *klimtlte)
{
    char buf[80];
    const char dir[] = "/sys/devices/platform/s3c2440-i2c.0/i2c-0/0-0020/input";
    const char filename[] = "enabled";
    DIR *d;
    struct dirent *de;
    char *path;
    int pathsize;

    d = opendir(dir);
    if (d == NULL) {
        strerror_r(errno, buf, sizeof(buf));
        ALOGE("Error opening directory %s: %s\n", dir, buf);
        return;
    }
    while ((de = readdir(d)) != NULL) {
        if (strncmp("input1", de->d_name, 5) == 0) {
            pathsize = strlen(dir) + strlen(de->d_name) + sizeof(filename) + 2;
            path = malloc(pathsize);
            if (path == NULL) {
                strerror_r(errno, buf, sizeof(buf));
                ALOGE("Out of memory: %s\n", buf);
                return;
            }
            snprintf(path, pathsize, "%s/%s/%s", dir, de->d_name, filename);
            klimtlte->touchscreen_power_path = path;
            goto done;
        }
    }
    ALOGE("Error failed to find input dir in %s\n", dir);
done:
    closedir(d);
}

static void power_init(struct power_module *module)
{
    struct klimtlte_power_module *klimtlte = (struct klimtlte_power_module *) module;
    struct dirent **namelist;
    int n;
    sysfs_write("/sys/devices/system/cpu/cpufreq/interactive/multi_enter_load",
		"360");
    sysfs_write("/sys/devices/system/cpu/cpufreq/interactive/multi_enter_time",
		"99000");
    sysfs_write("/sys/devices/system/cpu/cpufreq/interactive/multi_exit_load",
		"240");
    sysfs_write("sys/devices/system/cpu/cpufreq/interactive/multi_exit_time",
		"299000");
    sysfs_write("/sys/devices/system/cpu/cpufreq/interactive/single_enter_load",
		"95");
    sysfs_write("/sys/devices/system/cpu/cpufreq/interactive/single_enter_time",
		"199000");
    sysfs_write("/sys/devices/system/cpu/cpufreq/interactive/single_exit_load",
		"60");
    sysfs_write("/sys/devices/system/cpu/cpufreq/interactive/single_exit_time",
		"99000");
    sysfs_write("/sys/devices/system/cpu/cpufreq/interactive/io_is_busy",
                "1");
    sysfs_write("/sys/devices/system/cpu/cpufreq/interactive/timer_rate",
                "20000");
    sysfs_write("/sys/devices/system/cpu/cpufreq/interactive/timer_slack",
                "20000");
    sysfs_write("/sys/devices/system/cpu/cpufreq/interactive/min_sample_time",
                "40000");
    sysfs_write("/sys/devices/system/cpu/cpufreq/interactive/hispeed_freq",
                "1000000");
    sysfs_write("/sys/devices/system/cpu/cpufreq/interactive/go_hispeed_load",
                "90");
    sysfs_write("/sys/devices/system/cpu/cpufreq/interactive/target_loads",
		"70 600000:70 800000:75 1500000:80 1700000:90");
    sysfs_write("/sys/devices/system/cpu/cpufreq/interactive/above_hispeed_delay",
                "20000 1000000:80000 1200000:100000 1700000:20000");
    sysfs_write("/sys/devices/system/cpu/cpufreq/interactive/boostpulse_duration",
                BOOST_PULSE_DURATION_STR);

    init_touchscreen_power_path(klimtlte);
}

static void power_set_interactive(struct power_module *module, int on)
{
    struct klimtlte_power_module *klimtlte = (struct klimtlte_power_module *) module;
    char buf[80];
    int ret;

    ALOGV("power_set_interactive: %d\n", on);

    /*
     * Lower maximum frequency when screen is off.  CPU 0 and 1 share a
     * cpufreq policy.
     */
    sysfs_write(CPU_MAX_FREQ_PATH,
                on ? NORMAL_MAX_FREQ : LOW_POWER_MAX_FREQ);;


    sysfs_write(klimtlte->touchscreen_power_path, on ? "Y" : "N");

    ALOGV("power_set_interactive: %d done\n", on);
}

static int boostpulse_open(struct klimtlte_power_module *klimtlte)
{
    char buf[80];

    pthread_mutex_lock(&klimtlte->lock);

    if (klimtlte->boostpulse_fd < 0) {
        klimtlte->boostpulse_fd = open(BOOSTPULSE_PATH, O_WRONLY);

        if (klimtlte->boostpulse_fd < 0) {
            if (!klimtlte->boostpulse_warned) {
                strerror_r(errno, buf, sizeof(buf));
                ALOGE("Error opening %s: %s\n", BOOSTPULSE_PATH, buf);
                klimtlte->boostpulse_warned = 1;
            }
        }
    }

    pthread_mutex_unlock(&klimtlte->lock);
    return klimtlte->boostpulse_fd;
}

static void klimtlte_power_hint(struct power_module *module, power_hint_t hint,
                             void *data)
{
    struct klimtlte_power_module *klimtlte = (struct klimtlte_power_module *) module;
    char buf[80];
    int len;

    switch (hint) {
     case POWER_HINT_INTERACTION:
        if (boostpulse_open(klimtlte) >= 0) {
            len = write(klimtlte->boostpulse_fd, "1", 1);

            if (len < 0) {
                strerror_r(errno, buf, sizeof(buf));
                ALOGE("Error writing to %s: %s\n", BOOSTPULSE_PATH, buf);
            }
        }

        break;

   case POWER_HINT_VSYNC:
        break;

    default:
            break;
    }
}


static struct hw_module_methods_t power_module_methods = {
    .open = NULL,
};

struct klimtlte_power_module HAL_MODULE_INFO_SYM = {
    .base = {
        .common = {
            .tag = HARDWARE_MODULE_TAG,
            .module_api_version = POWER_MODULE_API_VERSION_0_1,
            .hal_api_version = HARDWARE_HAL_API_VERSION,
            .id = POWER_HARDWARE_MODULE_ID,
            .name = "Klimtlte Power HAL",
            .author = "The Android Open Source Project",
            .methods = &power_module_methods,
        },

        .init = power_init,
        .setInteractive = power_set_interactive,
        .powerHint = klimtlte_power_hint,
    },

    .lock = PTHREAD_MUTEX_INITIALIZER,
    .boostpulse_fd = -1,
    .boostpulse_warned = 0,
};
