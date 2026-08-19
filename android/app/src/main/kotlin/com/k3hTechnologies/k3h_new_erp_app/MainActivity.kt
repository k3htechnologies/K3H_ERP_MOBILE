package com.k3hTechnologies.k3h_new_erp_app

import android.content.ComponentName
import android.content.pm.PackageManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.k3h.app/app_icon"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        MethodChannel(
            flutterEngine!!.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            if (call.method == "changeAppIcon") {

                val iconName = call.argument<String>("iconName")

                try {
                    changeAppIcon(iconName)
                    result.success(null)
                } catch (e: Exception) {
                    result.error(
                        "ICON_CHANGE_ERROR",
                        e.message,
                        null
                    )
                }

            } else {
                result.notImplemented()
            }
        }
    }

    private fun changeAppIcon(iconName: String?) {

        val packageManager = applicationContext.packageManager
        val packageName = applicationContext.packageName

        val defaultIcon = ComponentName(
            packageName,
            "$packageName.MainActivity"
        )

        val rakshabandhanIcon = ComponentName(
            packageName,
            "$packageName.RakshabandhanAlias"
        )

        // First enable default icon
        packageManager.setComponentEnabledSetting(
            defaultIcon,
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
            PackageManager.DONT_KILL_APP
        )

        // Disable Rakshabandhan icon
        packageManager.setComponentEnabledSetting(
            rakshabandhanIcon,
            PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
            PackageManager.DONT_KILL_APP
        )

        // If Rakshabandhan period
        if (iconName == "Rakshabandhan") {

            // Disable default launcher icon
            packageManager.setComponentEnabledSetting(
                defaultIcon,
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP
            )

            // Enable Rakshabandhan launcher icon
            packageManager.setComponentEnabledSetting(
                rakshabandhanIcon,
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP
            )
        }
    }
}