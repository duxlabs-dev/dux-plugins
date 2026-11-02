import QtQuick
import Quickshell.Io
import qs.Services
import qs.Modules.Plugins

PluginComponent {
    id: root
    Item {}

    property bool enableCriticalAlert: pluginData.enableCriticalAlert ?? true
    property int criticalThreshold: pluginData.criticalThreshold ?? 10
    property string criticalTitle: pluginData.criticalTitle || "Critical Battery Level"
    property string criticalMessage: pluginData.criticalMessage || "Battery at ${level}% - Connect charger immediately!"
    property bool enableWarningAlert: pluginData.enableWarningAlert ?? true
    property int warningThreshold: pluginData.warningThreshold ?? 20
    property string warningTitle: pluginData.warningTitle || "Low Battery"
    property string warningMessage: pluginData.warningMessage || "Battery at ${level}% - Consider charging soon"

    property bool criticalAlertSent: false
    property bool warningAlertSent: false

    Component.onCompleted: {
        console.log("DankBatteryAlerts: Started monitoring battery level");
        console.log("DankBatteryAlerts: Critical alerts:", enableCriticalAlert, "at", criticalThreshold + "%");
        console.log("DankBatteryAlerts: Warning alerts:", enableWarningAlert, "at", warningThreshold + "%");
    }

    Connections {
        target: BatteryService.batteryAvailable ? BatteryService : null

        function onBatteryLevelChanged() {
            const level = BatteryService.batteryLevel;
            const isCharging = BatteryService.isCharging;

            if (isCharging) {
                criticalAlertSent = false;
                warningAlertSent = false;
                return;
            }

            if (enableCriticalAlert && level <= criticalThreshold && !criticalAlertSent) {
                sendNotification(criticalTitle, criticalMessage.replace("${level}", level), "critical", "material:battery_alert");
                criticalAlertSent = true;
            } else if (enableWarningAlert && level <= warningThreshold && !warningAlertSent && !criticalAlertSent) {
                sendNotification(warningTitle, warningMessage.replace("${level}", level), "normal", "material:battery_0_bar");
                warningAlertSent = true;
            }

            if (level > warningThreshold) {
                warningAlertSent = false;
            }
            if (level > criticalThreshold) {
                criticalAlertSent = false;
            }
        }
    }

    function sendNotification(title, message, urgency, icon) {
        const process = notifyProcessComponent.createObject(root, {
            notifyTitle: title,
            notifyMessage: message,
            notifyUrgency: urgency,
            notifyIcon: icon
        });
        process.running = true;
    }

    Component {
        id: notifyProcessComponent

        Process {
            property string notifyTitle: ""
            property string notifyMessage: ""
            property string notifyUrgency: "normal"
            property string notifyIcon: "battery_alert"

            command: ["dms", "notify", "--app", "Dux Shell", "--icon", notifyIcon, "--urgency", notifyUrgency, notifyTitle, notifyMessage]

            onExited: exitCode => {
                if (exitCode !== 0) {
                    console.error("DankBatteryAlerts: dms notify failed with code:", exitCode);
                }
                destroy();
            }
        }
    }

    Component.onDestruction: {
        console.log("DankBatteryAlerts: Stopped monitoring battery level");
    }
}
