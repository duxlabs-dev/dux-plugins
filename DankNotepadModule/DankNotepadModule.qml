import QtQuick
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Modules.Plugins

PluginComponent {
    id: root

    property string sourceContent: ""
    property string fileExtension: ""
    property bool previewActive: false
    property string lastRenderedContent: ""
    property bool renderRunning: false
    property bool renderPending: false
    property string style: SettingsData.getBuiltInPluginSetting("dankNotepadModule", "style", "github-dark")

    Component.onCompleted: {
        refreshSettings()
    }

    Connections {
        target: SettingsData
        function onBuiltInPluginSettingsChanged() {
            refreshSettings()
        }
    }

    Timer {
        id: renderDebounce
        interval: 350
        repeat: false
        onTriggered: renderHighlightedHtml()
    }

    function refreshSettings() {
        sourceContent = SettingsData.getBuiltInPluginSetting("dankNotepadModule", "sourceContent", "")
        fileExtension = SettingsData.getBuiltInPluginSetting("dankNotepadModule", "currentFileExtension", "")
        previewActive = SettingsData.getBuiltInPluginSetting("dankNotepadModule", "previewActive", false)
        style = SettingsData.getBuiltInPluginSetting("dankNotepadModule", "style", "github-dark")

        if (previewActive) {
            renderDebounce.restart()
        }
    }

    function getChromaLanguage() {
        const ext = (fileExtension || "").toLowerCase()
        switch (ext) {
        case "go":
        case "js":
        case "jsx":
        case "ts":
        case "tsx":
        case "py":
        case "json":
        case "sh":
        case "bash":
        case "html":
        case "htm":
        case "css":
        case "md":
        case "markdown":
        case "mdown":
            return ext
        default:
            return ""
        }
    }

    function renderHighlightedHtml() {
        if (!previewActive)
            return

        if (!sourceContent || sourceContent.trim().length === 0) {
            SettingsData.setBuiltInPluginSetting("dankNotepadModule", "highlightedHtml", "")
            lastRenderedContent = ""
            return
        }

        if (sourceContent === lastRenderedContent && !renderPending)
            return

        if (renderRunning) {
            renderPending = true
            return
        }

        const lang = getChromaLanguage()
        const isMarkdown = lang === "md" || lang === "markdown" || lang === "mdown"

        const process = chromaProcessComponent.createObject(root, {
            content: sourceContent,
            mode: isMarkdown ? "markdown" : "code",
            language: isMarkdown ? "" : lang,
            styleName: style,
            showLineNumbers: SettingsData.notepadShowLineNumbers
        })

        if (!process)
            return

        renderRunning = true
        lastRenderedContent = sourceContent
        process.running = true
    }

    Component {
        id: chromaProcessComponent

        Process {
            property string content: ""
            property string mode: "code"
            property string language: ""
            property string styleName: "github-dark"
            property bool showLineNumbers: false

            command: ["sh", "-c", "CONTENT=$1; MODE=$2; LANG=$3; STYLE=$4; LINE_NUMBERS_FLAG=$5; if [ \"$MODE\" = \"markdown\" ]; then printf '%s' \"$CONTENT\" | dms chroma --markdown --inline --style \"$STYLE\" $LINE_NUMBERS_FLAG; elif [ -n \"$LANG\" ]; then printf '%s' \"$CONTENT\" | dms chroma --inline --style \"$STYLE\" -l \"$LANG\" $LINE_NUMBERS_FLAG; else printf '%s' \"$CONTENT\" | dms chroma --inline --style \"$STYLE\" $LINE_NUMBERS_FLAG; fi", "sh", content, mode, language, styleName, showLineNumbers ? "--line-numbers" : ""]

            stdout: StdioCollector {
                onStreamFinished: {
                    let html = text
                    // Ensure code blocks wrap instead of overflowing
                    html = html.replace(/<pre([^>]*)>/g, function(match, attrs) {
                        if (attrs && attrs.indexOf("style=") !== -1) {
                            return '<pre' + attrs.replace(/style=\"([^\"]*)\"/, 'style="white-space:pre-wrap;word-break:break-word;$1"') + '>'
                        }
                        return '<pre style="white-space:pre-wrap;word-break:break-word;"' + (attrs || "") + '>'
                    })
                    SettingsData.setBuiltInPluginSetting("dankNotepadModule", "highlightedHtml", html)
                }
            }

            stderr: StdioCollector {
                onStreamFinished: {
                    if (text.trim()) {
                        console.warn("DankNotepadModule: chroma error", text.trim())
                    }
                }
            }

            onExited: {
                renderRunning = false
                if (renderPending) {
                    renderPending = false
                    Qt.callLater(renderHighlightedHtml)
                }
                destroy()
            }
        }
    }
}
