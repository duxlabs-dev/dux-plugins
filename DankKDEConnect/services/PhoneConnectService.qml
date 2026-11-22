pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
// qs.Services also exports the native DMS DuxConnectService, qualify local services
import "." as LocalServices

Singleton {
    id: root

    enum Backend {
        None,
        KDEConnect,
        Valent,
        DuxConnect
    }

    readonly property string pluginId: "dankKDEConnect"

    readonly property int preferredBackend: backendFromName(settings.preferredBackend ?? "")
    onPreferredBackendChanged: detectBackend()
    property int activeBackend: PhoneConnectService.Backend.None

    readonly property bool available: activeBackend !== PhoneConnectService.Backend.None
    readonly property bool isRefreshing: _backend?.isRefreshing ?? false

    readonly property string announcedName: _backend?.announcedName ?? ""

    property var deviceIds: []
    readonly property var devices: {
        const rawDevices = _backend?.devices ?? {};
        const result = {};
        for (const id in rawDevices) {
            const dev = rawDevices[id];
            if (!dev)
                continue;
            const copy = Object.assign({}, dev);
            if (deviceTypeMap[id])
                copy.type = deviceTypeMap[id];
            result[id] = copy;
        }
        return result;
    }

    readonly property string backendName: {
        switch (activeBackend) {
        case PhoneConnectService.Backend.KDEConnect:
            return "KDE Connect";
        case PhoneConnectService.Backend.Valent:
            return "Valent";
        case PhoneConnectService.Backend.DuxConnect:
            return "Dux Connect";
        default:
            return "Phone Connect";
        }
    }

    readonly property var settings: SettingsData.pluginSettings[pluginId] ?? ({})
    readonly property bool chargingFill: flag("enableChargingAnimation", true)
    readonly property bool clipboardAction: flag("enableClipboardAction", true)
    readonly property bool showOngoingMedia: flag("showOngoingMedia", true)
    readonly property bool showDevicePlaceholder: flag("showDevicePlaceholder", true)
    readonly property bool scanSubdirectories: flag("scanSubdirectories", false)
    readonly property bool hideUnpairedDevices: flag("hideUnpairedDevices", false)
    readonly property int maxRecentImages: parseInt(settings.maxRecentImages) || 4
    readonly property int stateUpdateInterval: {
        const seconds = parseInt(settings.stateUpdateInterval);
        return isNaN(seconds) ? 30 : seconds;
    }
    readonly property string preferredDeviceId: settings.preferredDeviceId ?? ""
    readonly property string selectedDeviceId: settings.selectedDeviceId ?? ""
    readonly property string deviceTypeMapJson: settings.deviceTypeMap ?? ""
    readonly property string deviceImageMapJson: settings.deviceImageMap ?? ""
    readonly property string recentImagesPathMapJson: settings.deviceRecentImagesPathMap ?? ""
    readonly property var deviceTypeMap: parseMap(deviceTypeMapJson)
    readonly property var deviceImageMap: parseMap(deviceImageMapJson)
    readonly property var recentImagesPathMap: parseMap(recentImagesPathMapJson)

    readonly property var selectedDevice: devices[selectedDeviceId] ?? null
    readonly property bool hasDevice: selectedDevice !== null
    readonly property bool selectedReachable: selectedDevice?.isReachable ?? false

    readonly property string recentImagesPath: recentImagesPathFor(selectedDeviceId)
    property var recentImages: []
    readonly property bool loadingImages: imagesScanner.running
    property int imageViewers: 0

    property var _backend: null
    property string _nameWatchSubscription: ""
    property bool _preferredWasUsable: false
    property var _pairingPrompted: ({})
    property var _imagesByPath: ({})

    readonly property var _backendBusNames: ["org.kde.kdeconnect", "ca.andyholmes.Valent"]

    Component.onCompleted: {
        if (DMSService.subscribeConnected)
            resync();
        else
            detectBackend();
    }

    onHideUnpairedDevicesChanged: syncDeviceIds()
    onPreferredDeviceIdChanged: {
        _preferredWasUsable = false;
        autoSelect();
    }
    onRecentImagesPathChanged: {
        recentImages = _imagesByPath[recentImagesPath] ?? [];
        scanImages();
    }
    onMaxRecentImagesChanged: scanImages()
    onScanSubdirectoriesChanged: scanImages()
    onImageViewersChanged: {
        if (imageViewers > 0)
            scanImages();
    }

    function flag(key, fallback) {
        const value = settings[key];
        if (value === undefined || value === null)
            return fallback;
        return value === true || value === "true";
    }

    function parseMap(json) {
        if (!json)
            return {};
        try {
            return JSON.parse(json);
        } catch (e) {
            return {};
        }
    }

    function saveSetting(key, value) {
        PluginService.savePluginData(pluginId, key, value);
    }

    function saveMapEntry(key, map, deviceId, value) {
        if (!deviceId)
            return;
        const updated = Object.assign({}, map);
        if (value)
            updated[deviceId] = value;
        else
            delete updated[deviceId];
        saveSetting(key, JSON.stringify(updated));
    }

    function isFirstDevice(deviceId) {
        const ids = _backend?.deviceIds ?? [];
        return ids.length > 0 && ids[0] === deviceId;
    }

    function deviceImage(deviceId) {
        if (!deviceId)
            return "";
        if (deviceImageMap[deviceId])
            return deviceImageMap[deviceId];
        if (deviceImageMapJson === "" && isFirstDevice(deviceId))
            return settings.customPhoneImage ?? "";
        return "";
    }

    function setDeviceImage(deviceId, path) {
        saveMapEntry("deviceImageMap", deviceImageMap, deviceId, path);
    }

    function recentImagesPathFor(deviceId) {
        if (!deviceId)
            return "";
        if (recentImagesPathMap[deviceId])
            return recentImagesPathMap[deviceId];
        if (isFirstDevice(deviceId))
            return settings.recentImagesPath ?? "";
        return "";
    }

    function setRecentImagesPath(deviceId, path) {
        saveMapEntry("deviceRecentImagesPathMap", recentImagesPathMap, deviceId, path);
    }

    function setDeviceType(deviceId, type) {
        saveMapEntry("deviceTypeMap", deviceTypeMap, deviceId, type);
    }

    Connections {
        target: DMSService
        function onConnectionStateChanged() {
            if (!DMSService.isConnected)
                root._nameWatchSubscription = "";
        }

        function onCapabilitiesReceived() {
            root.resync();
        }

        function onDbusSignalReceived(subId, data) {
            if (data.member !== "NameOwnerChanged")
                return;
            const name = data.body?.[0];
            if (!root._backendBusNames.includes(name))
                return;
            switch (name) {
            case "org.kde.kdeconnect":
                KDEConnectService.checkAvailability();
                break;
            case "ca.andyholmes.Valent":
                ValentService.checkAvailability();
                break;
            }
            root.detectBackend();
        }
    }

    // Daemons before the match-ownership fix drop every dbus match when the shell re-dials its subscribe socket.
    function resync() {
        if (DMSService.capabilities.includes("dbus"))
            watchBusNames();
        detectBackend();
    }

    function watchBusNames() {
        if (_nameWatchSubscription !== "")
            DMSService.dbusUnsubscribe(_nameWatchSubscription);
        _nameWatchSubscription = "";
        DMSService.dbusSubscribe("session", "org.freedesktop.DBus", "/org/freedesktop/DBus", "org.freedesktop.DBus", "NameOwnerChanged", function (response) {
            if (response.error) {
                console.warn("[PhoneConnect] NameOwnerChanged subscription failed:", response.error);
                return;
            }
            root._nameWatchSubscription = response.result.subscriptionId;
        });
    }

    Connections {
        target: root._backend

        function onDevicesListChanged() {
            root.syncDeviceIds();
        }

        function onDeviceUpdated(deviceId) {
            root.syncDeviceIds();
            if (!root._backend.devices[deviceId]?.isPairRequestedByPeer)
                delete root._pairingPrompted[deviceId];
        }

        function onPairingRequestReceived(deviceId, verificationKey) {
            root.promptPairing(deviceId, verificationKey);
        }

        function onShareReceived(deviceId, url) {
            root.notifyShare(deviceId, url);
        }

        function onAvailableChanged() {
            if (!root._backend.available)
                root.detectBackend();
        }
    }

    // Dux Connect talks over its own socket, so it is not among the watched bus names.
    Connections {
        target: LocalServices.DuxConnectService

        function onAvailableChanged() {
            root.detectBackend();
        }
    }

    property int _detectionGeneration: 0

    function backendFromName(name) {
        switch (name) {
        case "Valent":
            return PhoneConnectService.Backend.Valent;
        case "Dux Connect":
        case "DankConnect": // value saved by pre-rebrand alpha builds
            return PhoneConnectService.Backend.DuxConnect;
        default:
            return PhoneConnectService.Backend.KDEConnect;
        }
    }

    function activateBackend(newBackend) {
        if (newBackend === activeBackend)
            return;
        activeBackend = newBackend;
        switch (activeBackend) {
        case PhoneConnectService.Backend.KDEConnect:
            _backend = KDEConnectService;
            break;
        case PhoneConnectService.Backend.Valent:
            _backend = ValentService;
            break;
        case PhoneConnectService.Backend.DuxConnect:
            _backend = LocalServices.DuxConnectService;
            break;
        default:
            _backend = null;
        }
        syncDeviceIds();
    }

    function detectBackend() {
        _detectionGeneration++;
        const generation = _detectionGeneration;
        const hasDuxConnect = LocalServices.DuxConnectService.available;

        if (preferredBackend === PhoneConnectService.Backend.DuxConnect && !hasDuxConnect)
            LocalServices.DuxConnectService.launch();

        if (preferredBackend === PhoneConnectService.Backend.DuxConnect && hasDuxConnect) {
            activateBackend(PhoneConnectService.Backend.DuxConnect);
            return;
        }

        if (!DMSService.isConnected || !DMSService.capabilities.includes("dbus")) {
            activateBackend(hasDuxConnect ? PhoneConnectService.Backend.DuxConnect : PhoneConnectService.Backend.None);
            return;
        }

        DMSService.dbusListNames("session", function (response) {
            if (generation !== root._detectionGeneration)
                return;

            const names = response.error ? [] : (response.result?.names || []);
            const hasKDE = names.includes("org.kde.kdeconnect");
            const hasValent = names.includes("ca.andyholmes.Valent");
            if (!hasKDE || !names.includes("dev.duxlabs.connect.daemon")) {
                root._selectDetected(hasKDE, hasValent);
                return;
            }
            // org.kde.kdeconnect may be dux-connect's compatibility facade;
            // matching bus-name owners means the same daemon, and the native
            // socket backend is the richer surface for it.
            DMSService.dbusCall("session", "org.freedesktop.DBus", "/org/freedesktop/DBus", "org.freedesktop.DBus", "GetNameOwner", ["org.kde.kdeconnect"], function (kdeOwner) {
                if (generation !== root._detectionGeneration)
                    return;
                DMSService.dbusCall("session", "org.freedesktop.DBus", "/org/freedesktop/DBus", "org.freedesktop.DBus", "GetNameOwner", ["dev.duxlabs.connect.daemon"], function (duxOwner) {
                    if (generation !== root._detectionGeneration)
                        return;
                    const kde = kdeOwner.result?.values?.[0] || "";
                    const dux = duxOwner.result?.values?.[0] || "";
                    root._selectDetected(!kde || kde !== dux, hasValent);
                });
            });
        });
    }

    function _selectDetected(hasKDE, hasValent) {
        const hasDux = LocalServices.DuxConnectService.available;
        let newBackend = PhoneConnectService.Backend.None;

        if (preferredBackend === PhoneConnectService.Backend.KDEConnect && hasKDE) {
            newBackend = PhoneConnectService.Backend.KDEConnect;
        } else if (preferredBackend === PhoneConnectService.Backend.Valent && hasValent) {
            newBackend = PhoneConnectService.Backend.Valent;
        } else if (preferredBackend === PhoneConnectService.Backend.DuxConnect && hasDux) {
            newBackend = PhoneConnectService.Backend.DuxConnect;
        } else if (hasKDE) {
            newBackend = PhoneConnectService.Backend.KDEConnect;
        } else if (hasValent) {
            newBackend = PhoneConnectService.Backend.Valent;
        } else if (hasDux) {
            newBackend = PhoneConnectService.Backend.DuxConnect;
        }

        activateBackend(newBackend);
    }

    function isListed(device) {
        if (!hideUnpairedDevices)
            return true;
        return !!device && (device.isPaired || device.isPairRequested || device.isPairRequestedByPeer);
    }

    // A fresh array per device update would rebuild every list bound to deviceIds.
    function syncDeviceIds() {
        const rawDevices = _backend?.devices ?? {};
        const next = (_backend?.deviceIds ?? []).filter(id => isListed(rawDevices[id]));
        const changed = next.length !== deviceIds.length || next.some((id, i) => id !== deviceIds[i]);
        if (changed)
            deviceIds = next;
        autoSelect();
    }

    function isUsable(deviceId) {
        const dev = _backend?.devices[deviceId];
        return !!dev && deviceIds.includes(deviceId) && dev.isReachable && dev.isPaired;
    }

    function autoSelect() {
        const preferredUsable = preferredDeviceId !== "" && isUsable(preferredDeviceId);
        const preferredArrived = preferredUsable && !_preferredWasUsable;
        _preferredWasUsable = preferredUsable;
        if (preferredArrived) {
            selectDevice(preferredDeviceId);
            return;
        }
        if (isUsable(selectedDeviceId))
            return;
        const usable = preferredUsable ? preferredDeviceId : deviceIds.find(isUsable);
        if (usable) {
            selectDevice(usable);
            return;
        }
        if (deviceIds.length === 0 || deviceIds.includes(selectedDeviceId))
            return;
        selectDevice(deviceIds[0]);
    }

    function selectDevice(deviceId) {
        if (deviceId === selectedDeviceId)
            return;
        saveSetting("selectedDeviceId", deviceId);
    }

    function selectRelative(step) {
        if (deviceIds.length <= 1)
            return;
        const index = deviceIds.indexOf(selectedDeviceId);
        selectDevice(deviceIds[(index + step + deviceIds.length) % deviceIds.length]);
    }

    function promptPairing(deviceId, verificationKey) {
        if (_pairingPrompted[deviceId])
            return;
        _pairingPrompted[deviceId] = true;
        const name = getDevice(deviceId)?.name || deviceId;
        const details = verificationKey ? I18n.trFor(pluginId, "Verification", "Phone Connect pairing verification key label") + ": " + verificationKey : "";
        ToastService.showInfo(I18n.trFor(pluginId, "Pairing request from %1", "Phone Connect pairing request notification").arg(name), details);
    }

    function notifyShare(deviceId, url) {
        const name = getDevice(deviceId)?.name || deviceId;
        const filePath = url.startsWith("file://") ? url.substring(7) : url;
        const filename = url.split("/").pop() || url;
        Quickshell.execDetached(["dms", "notify", "--app", backendName, "--icon", "smartphone", "--file", filePath, I18n.trFor(pluginId, "File received from %1", "Phone Connect file share notification").arg(name), filename]);
    }

    Timer {
        interval: root.stateUpdateInterval * 1000
        running: root.available && root.stateUpdateInterval > 0
        repeat: true
        onTriggered: {
            root.refreshDevices();
            if (root.imageViewers > 0)
                root.scanImages();
        }
    }

    function refreshDevices() {
        if (_backend)
            _backend.refreshDevices();
        else
            detectBackend();
    }

    function getDevice(deviceId) {
        return devices[deviceId] || null;
    }

    function hasPlugin(deviceId, pluginName) {
        const plugins = getDevice(deviceId)?.supportedPlugins;
        if (!plugins)
            return false;
        return plugins.includes(pluginName) || plugins.includes("kdeconnect_" + pluginName);
    }

    function canUse(deviceId, pluginName) {
        const dev = getDevice(deviceId);
        return !!dev && dev.isReachable && dev.isPaired && hasPlugin(deviceId, pluginName);
    }

    function report(failure, success) {
        return function (response) {
            if (response.error) {
                ToastService.showError(failure, response.error);
                return;
            }
            if (success)
                ToastService.showInfo(success);
        };
    }

    function forward(method, args) {
        if (_backend) {
            _backend[method](...args);
            return;
        }
        args[args.length - 1]?.({
            error: "No backend"
        });
    }

    function ring(deviceId) {
        const name = deviceLabel(deviceId);
        forward("ringDevice", [deviceId, report(I18n.trFor(pluginId, "Failed to ring device", "Phone Connect error"), I18n.trFor(pluginId, "Ringing %1...", "Phone Connect ring action").arg(name))]);
    }

    function ping(deviceId) {
        const name = deviceLabel(deviceId);
        forward("sendPing", [deviceId, "", report(I18n.trFor(pluginId, "Failed to send ping", "Phone Connect error"), I18n.trFor(pluginId, "Ping sent to %1", "Phone Connect ping action").arg(name))]);
    }

    function sendClipboard(deviceId) {
        forward("sendClipboard", [deviceId, report(I18n.trFor(pluginId, "Failed to send clipboard", "Phone Connect error"), I18n.trFor(pluginId, "Clipboard sent", "Phone Connect clipboard action"))]);
    }

    function browse(deviceId) {
        forward("startBrowsing", [deviceId, report(I18n.trFor(pluginId, "Failed to browse device", "Phone Connect error"), I18n.trFor(pluginId, "Opening file browser", "Phone Connect browse action") + "...")]);
    }

    function requestPairing(deviceId) {
        forward("requestPairing", [deviceId, report(I18n.trFor(pluginId, "Pairing failed", "Phone Connect error"), I18n.trFor(pluginId, "Pairing request sent", "Phone Connect pairing action"))]);
    }

    function acceptPairing(deviceId) {
        forward("acceptPairing", [deviceId, report(I18n.trFor(pluginId, "Failed to accept pairing", "Phone Connect error"), I18n.trFor(pluginId, "Device paired", "Phone Connect pairing action"))]);
    }

    function rejectPairing(deviceId) {
        forward("cancelPairing", [deviceId, report(I18n.trFor(pluginId, "Failed to reject pairing", "Phone Connect error"), "")]);
    }

    function unpair(deviceId) {
        forward("unpair", [deviceId, report(I18n.trFor(pluginId, "Unpair failed", "Phone Connect error"), I18n.trFor(pluginId, "Device unpaired", "Phone Connect unpair action"))]);
    }

    function shareContent(deviceId, content, isUri) {
        forward(isUri ? "shareUrl" : "shareText", [deviceId, content, report(I18n.trFor(pluginId, "Failed to share", "Phone Connect error"), I18n.trFor(pluginId, "Shared", "Phone Connect share success"))]);
    }

    function shareFile(deviceId, path) {
        const failure = I18n.trFor(pluginId, "Failed to send file", "Phone Connect error");
        const url = localFileUrl(path);
        if (url === "") {
            ToastService.showError(failure, path);
            return;
        }
        forward("shareUrl", [deviceId, url, report(failure, I18n.trFor(pluginId, "Sending %1...", "Phone Connect file send").arg(path.split("/").pop()))]);
    }

    function localFileUrl(path) {
        const filePath = (path ?? "").toString();
        if (filePath.startsWith("file://"))
            return filePath;
        if (!filePath.startsWith("/"))
            return "";
        return "file://" + filePath.split("/").map(encodeURIComponent).join("/");
    }

    function sendSms(deviceId, phoneNumber, message) {
        const done = report(I18n.trFor(pluginId, "Failed to send SMS", "Phone Connect error"), I18n.trFor(pluginId, "SMS sent successfully", "Phone Connect SMS action"));
        if (activeBackend !== PhoneConnectService.Backend.KDEConnect) {
            forward("sendSms", [deviceId, phoneNumber, message, [], done]);
            return;
        }
        Quickshell.execDetached(["kdeconnect-cli", "-d", deviceId, "--send-sms", message, "--destination", phoneNumber]);
        done({});
    }

    function launchSmsApp(deviceId) {
        forward("launchSmsApp", [deviceId, report(I18n.trFor(pluginId, "Failed to launch SMS app", "Phone Connect error"), I18n.trFor(pluginId, "Opening SMS app", "Phone Connect SMS action") + "...")]);
    }

    function mediaAction(deviceId, action) {
        forward("mprisAction", [deviceId, action, function () {}]);
    }

    function mountAndWait(deviceId, callback) {
        if (!_backend) {
            callback(false);
            return;
        }
        _backend.mountAndWait(deviceId, callback);
    }

    function getSftpMountPoint(deviceId, callback) {
        if (!_backend) {
            callback("");
            return;
        }
        _backend.getSftpMountPoint(deviceId, callback);
    }

    function deviceLabel(deviceId) {
        return getDevice(deviceId)?.name || I18n.trFor(pluginId, "device", "Generic device name fallback");
    }

    function scanImages() {
        if (recentImagesPath === "") {
            recentImages = [];
            return;
        }
        if (imageViewers <= 0 || imagesScanner.running)
            return;
        imagesScanner.scannedPath = recentImagesPath;
        imagesScanner.command = ["sh", "-c", "d=\"$1\"; d=\"${d#file://}\"; case \"$d\" in \"~\"*) d=\"$HOME${d#\\~}\";; esac; [ -d \"$d\" ] && find \"$d\" -maxdepth \"$2\" -type f -not -name '.*' -not -name '*trashed*' \\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \\) -printf '%T@|%p\\n' 2>/dev/null | sort -rn | head -n \"$3\"", "sh", recentImagesPath, scanSubdirectories ? "4" : "1", String(maxRecentImages)];
        imagesScanner.running = true;
    }

    Process {
        id: imagesScanner
        property string scannedPath: ""
        onExited: {
            if (scannedPath !== root.recentImagesPath)
                root.scanImages();
        }
        stdout: StdioCollector {
            onStreamFinished: {
                const paths = text.split("\n").map(line => line.substring(line.indexOf("|") + 1)).filter(path => path.startsWith("/"));
                root._imagesByPath[imagesScanner.scannedPath] = paths;
                if (imagesScanner.scannedPath !== root.recentImagesPath)
                    return;
                const unchanged = paths.length === root.recentImages.length && paths.every((path, i) => path === root.recentImages[i]);
                if (!unchanged)
                    root.recentImages = paths;
            }
        }
    }

    function getDeviceIcon(device) {
        switch (device?.type) {
        case "tablet":
            return "tablet";
        case "laptop":
            return "laptop";
        case "desktop":
        case "computer":
            return "desktop_windows";
        case "tv":
            return "tv";
        case "phone":
        case "smartphone":
            return "smartphone";
        default:
            return "devices";
        }
    }

    function getNetworkIcon(device) {
        const strength = device?.networkStrength ?? -1;
        if (strength < 0)
            return "";
        return "signal_cellular_" + Math.min(4, Math.floor(strength)) + "_bar";
    }

    function getBatteryIcon(device) {
        return _backend?.getBatteryIcon(device) ?? "";
    }

    function getNetworkTypeLabel(device) {
        const rawType = (device?.networkType ?? "").toString().trim();
        switch (rawType.toUpperCase()) {
        case "":
            return "";
        case "NR":
        case "5G":
        case "5G_NR":
        case "5G NR":
            return "5G";
        case "LTE":
        case "4G":
            return "LTE";
        case "LTE_CA":
        case "LTE+":
        case "4G+":
        case "4G_CA":
            return "LTE+";
        case "HSPA":
        case "HSDPA":
        case "HSUPA":
        case "HSPAP":
        case "UMTS":
        case "WCDMA":
        case "3G":
            return "3G";
        case "EDGE":
        case "GPRS":
        case "GSM":
        case "2G":
            return "2G";
        default:
            return rawType.charAt(0).toUpperCase() + rawType.slice(1);
        }
    }

    function getNetworkStrengthLabel(device) {
        const strength = device?.networkStrength ?? -1;
        if (strength < 0)
            return I18n.trFor(pluginId, "Unknown", "network signal strength");
        if (strength >= 4)
            return I18n.trFor(pluginId, "Excellent", "network signal strength");
        switch (strength) {
        case 3:
            return I18n.trFor(pluginId, "Good", "network signal strength");
        case 2:
            return I18n.trFor(pluginId, "Fair", "network signal strength");
        case 1:
            return I18n.trFor(pluginId, "Weak", "network signal strength");
        default:
            return I18n.trFor(pluginId, "No Signal", "network signal strength");
        }
    }

    function getNetworkTypeIcon(device) {
        switch (getNetworkTypeLabel(device)) {
        case "":
            return "signal_cellular_nodata";
        case "5G":
            return "5g";
        case "LTE":
        case "LTE+":
            return "4g_mobiledata";
        case "3G":
            return "3g_mobiledata";
        case "2G":
            return "2g_mobiledata";
        default:
            return "signal_cellular_alt";
        }
    }

    function statusText(device) {
        if (!device)
            return I18n.trFor(pluginId, "Unknown", "KDE Connect unknown device status");
        if (device.isPairRequestedByPeer)
            return I18n.trFor(pluginId, "Pairing requested", "KDE Connect pairing requested status");
        if (device.isPairRequested)
            return I18n.trFor(pluginId, "Pairing...", "KDE Connect pairing in progress status");
        if (!device.isPaired)
            return I18n.trFor(pluginId, "Not paired", "KDE Connect not paired status");
        if (!device.isReachable)
            return I18n.trFor(pluginId, "Offline", "KDE Connect offline status");
        return I18n.trFor(pluginId, "Connected", "KDE Connect connected status");
    }
}
