package com.learningbird.learning_bird

import android.app.AlarmManager
import android.app.NotificationManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.util.Locale

class MainActivity : FlutterActivity() {
    private val reminderSettingsChannel =
        "com.learningbird.learning_bird/background_reminder_settings"
    private val linkedAppsChannel = "com.learningbird.learning_bird/linked_apps"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            reminderSettingsChannel,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getStatus" -> result.success(readReminderStatus())
                "openExactAlarmSettings" -> {
                    openExactAlarmSettings()
                    result.success(null)
                }
                "openAppDetails" -> {
                    openAppDetails()
                    result.success(null)
                }
                "openNotificationSettings" -> {
                    openNotificationSettings()
                    result.success(null)
                }
                "openBackgroundLaunchSettings" -> {
                    openBackgroundLaunchSettings()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            linkedAppsChannel,
        ).setMethodCallHandler { call, result ->
            val targetPackage = call.argument<String>("packageName")
            when (call.method) {
                "getLaunchableApps" -> result.success(readLaunchableApps())
                "getAppIcon" -> result.success(targetPackage?.let(::readAppIcon))
                "launchApp" -> result.success(targetPackage?.let(::launchApp) ?: false)
                else -> result.notImplemented()
            }
        }
    }

    private fun readLaunchableApps(): List<Map<String, String>> {
        val launcherIntent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        return packageManager.queryIntentActivities(launcherIntent, PackageManager.MATCH_ALL)
            .asSequence()
            .filter { it.activityInfo.packageName != packageName }
            .distinctBy { it.activityInfo.packageName }
            .map {
                mapOf(
                    "packageName" to it.activityInfo.packageName,
                    "label" to it.loadLabel(packageManager).toString(),
                )
            }
            .sortedBy { it["label"]?.lowercase() }
            .toList()
    }

    private fun readAppIcon(targetPackage: String): ByteArray? {
        return try {
            val drawable = packageManager.getApplicationIcon(targetPackage)
            val bitmap = drawable.toBitmap()
            ByteArrayOutputStream().use { stream ->
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
                stream.toByteArray()
            }
        } catch (_: Exception) {
            null
        }
    }

    private fun launchApp(targetPackage: String): Boolean {
        return try {
            val intent = packageManager.getLaunchIntentForPackage(targetPackage) ?: return false
            startActivity(intent)
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun Drawable.toBitmap(): Bitmap {
        if (this is BitmapDrawable && bitmap != null) return bitmap
        val width = intrinsicWidth.takeIf { it > 0 } ?: 96
        val height = intrinsicHeight.takeIf { it > 0 } ?: 96
        return Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888).also { bitmap ->
            val canvas = Canvas(bitmap)
            setBounds(0, 0, canvas.width, canvas.height)
            draw(canvas)
        }
    }

    private fun readReminderStatus(): Map<String, Any> {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val notificationManager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        val canScheduleExactly =
            Build.VERSION.SDK_INT < Build.VERSION_CODES.S || alarmManager.canScheduleExactAlarms()
        return mapOf(
            "canScheduleExactly" to canScheduleExactly,
            "canUseFullScreenIntents" to
                (Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE ||
                    notificationManager.canUseFullScreenIntent()),
            "ignoringBatteryOptimizations" to
                powerManager.isIgnoringBatteryOptimizations(packageName),
            "manufacturer" to Build.MANUFACTURER,
            "sdkInt" to Build.VERSION.SDK_INT,
        )
    }

    private fun openExactAlarmSettings() {
        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            Intent(
                Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM,
                Uri.parse("package:$packageName"),
            )
        } else {
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$packageName")
            }
        }
        startActivitySafely(intent)
    }

    private fun openAppDetails() {
        startActivitySafely(
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$packageName")
            },
        )
    }

    private fun openNotificationSettings() {
        startActivitySafely(
            Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
            },
        )
    }

    private fun openBackgroundLaunchSettings() {
        val manufacturer = Build.MANUFACTURER.lowercase(Locale.ROOT)
        val candidates = mutableListOf<Intent>()

        when {
            manufacturer.contains("oppo") ||
                manufacturer.contains("oneplus") ||
                manufacturer.contains("realme") -> {
                // ColorOS 16 and current OPlus devices.
                candidates += Intent(
                    "com.oplus.battery.permission.startup.StartupAppListActivity",
                ).setPackage("com.oplus.battery")
                // Older ColorOS releases.
                candidates += Intent().setComponent(
                    ComponentName(
                        "com.coloros.safecenter",
                        "com.coloros.safecenter.startupapp.StartupAppListActivity",
                    ),
                )
                // Newer ColorOS protects the pages above with a system-only
                // permission. Open Settings so the user can search 自启动.
                candidates += Intent(Settings.ACTION_SETTINGS)
            }
            manufacturer.contains("xiaomi") || manufacturer.contains("redmi") -> {
                candidates += Intent().setComponent(
                    ComponentName(
                        "com.miui.securitycenter",
                        "com.miui.permcenter.autostart.AutoStartManagementActivity",
                    ),
                )
            }
            manufacturer.contains("vivo") || manufacturer.contains("iqoo") -> {
                candidates += Intent().setComponent(
                    ComponentName(
                        "com.vivo.permissionmanager",
                        "com.vivo.permissionmanager.activity.BgStartUpManagerActivity",
                    ),
                )
            }
            manufacturer.contains("huawei") -> {
                candidates += Intent().setComponent(
                    ComponentName(
                        "com.huawei.systemmanager",
                        "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity",
                    ),
                )
            }
            manufacturer.contains("honor") -> {
                candidates += Intent().setComponent(
                    ComponentName(
                        "com.hihonor.systemmanager",
                        "com.hihonor.systemmanager.startupmgr.ui.StartupNormalAppListActivity",
                    ),
                )
            }
        }

        // A standard Android fallback still gives every brand a useful route.
        candidates += Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
        if (candidates.any(::tryStartActivity)) return
        openAppDetails()
    }

    private fun tryStartActivity(intent: Intent): Boolean {
        return try {
            if (intent.resolveActivity(packageManager) == null) return false
            startActivity(intent)
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun startActivitySafely(intent: Intent) {
        try {
            startActivity(intent)
        } catch (_: Exception) {
            startActivity(
                Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                    data = Uri.parse("package:$packageName")
                },
            )
        }
    }
}
