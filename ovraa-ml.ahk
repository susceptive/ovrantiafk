#Requires AutoHotkey v2.0.19
#SingleInstance Force

global isRunning := false
global interval := 5000
global cleanKeyToSend := ""

translations := Map(
    "en", Map(
        "title", "OVR Anti-AFK",
        "interval", "Duration (ms):",
        "key", "Key to Send:",
        "start", "Start",
        "stop", "Stop",
        "logs", "Logs:",
        "status", "Status:",
        "started", "✅ Bot started (every {1} ms).",
        "stopped", "⏹️ Bot stopped.",
        "invalidInterval", "⚠️ Invalid interval, must be at least 100 ms.",
        "notNumber", "⚠️ Interval must contain only numbers!",
        "notFound", "❌ ODIN window not found.",
        "sent", "📨 Key '{1}' sent.",
        "active", "🟢 Active",
        "inactive", "🔴 Inactive"
    ),
    "tr", Map(
        "title", "OVR Anti-AFK",
        "interval", "Süre (ms):",
        "key", "Gönderilecek Tuş:",
        "start", "Başlat",
        "stop", "Durdur",
        "logs", "Loglar:",
        "status", "Durum:",
        "started", "✅ Bot başlatıldı (her {1} ms).",
        "stopped", "⏹️ Bot durduruldu.",
        "invalidInterval", "⚠️ Geçersiz aralık, en az 100 ms olmalı.",
        "notNumber", "⚠️ Süre sadece rakam içermelidir!",
        "notFound", "❌ ODIN penceresi bulunamadı.",
        "sent", "📨 '{1}' tuşu gönderildi.",
        "active", "🟢 Aktif",
        "inactive", "🔴 Pasif"
    )
)
global lang := "en"

T(key, args*) {
    global lang, translations
    text := translations[lang][key]
    Loop args.Length
        text := StrReplace(text, "{" A_Index "}", args[A_Index])
    return text
}

SendKeyToODIN() {
    global isRunning, cleanKeyToSend, logBox
    if !isRunning
        return

    hwnd := WinExist("ahk_exe ProjectLH.exe")
    if !hwnd {
        AddLog(T("notFound"))
        return
    }

    ControlSend(cleanKeyToSend, , "ahk_exe ProjectLH.exe")
    AddLog(T("sent", cleanKeyToSend))
}

AddLog(text) {
    global logBox
    if !IsObject(logBox)
        return
    tStamp := FormatTime(, "HH:mm:ss")
    prevLog := logBox.Text
    logBox.Text := tStamp " - " text "`r`n" prevLog
}

ShowNotification(title, message) {
    TrayTip title, message
}

UpdateStatusIcon() {
    global statusIcon, isRunning
    statusIcon.Value := isRunning ? T("active") : T("inactive")
}

StartBot(*) {
    global isRunning, intervalInput, keyInput, cleanKeyToSend

    intervalRaw := intervalInput.Value
    intervalRaw := StrReplace(intervalRaw, " ")

    if !RegExMatch(intervalRaw, "^\d+$") {
        AddLog(T("notNumber"))
        ShowNotification("OVR Anti-AFK", T("notNumber"))
        return
    }

    interval := intervalRaw + 0

    if (interval < 100) {
        AddLog(T("invalidInterval"))
        ShowNotification("OVR Anti-AFK", T("invalidInterval"))
        return
    }

    cleanKeyToSend := keyInput.Value
    cleanKeyToSend := RegExReplace(cleanKeyToSend, "^[\+\^\#\!]+")
    if RegExMatch(cleanKeyToSend, "^[A-Za-z]$")
        cleanKeyToSend := StrLower(cleanKeyToSend)

    SetTimer(SendKeyToODIN, 0)
    SetTimer(SendKeyToODIN, interval)

    intervalInput.Enabled := false
    keyInput.Enabled := false

    isRunning := true
    UpdateStatusIcon()
    AddLog(T("started", interval))
    ShowNotification("OVR Anti-AFK", T("started", interval))
}

StopBot(*) {
    global isRunning
    SetTimer(SendKeyToODIN, 0)
    isRunning := false

    intervalInput.Enabled := true
    keyInput.Enabled := true

    UpdateStatusIcon()
    AddLog(T("stopped"))
    ShowNotification("OVR Anti-AFK", T("stopped"))
}

IntervalChanged(*) {
    global isRunning, intervalInput

    static warned := false

    newVal := intervalInput.Value
    filtered := ""

    for ch in StrSplit(newVal)
        if ch ~= "\d"
            filtered .= ch

    if (filtered != newVal) {
        intervalInput.Value := filtered
        if !warned {
            AddLog(T("notNumber"))
            ShowNotification("OVR Anti-AFK", T("notNumber"))
            warned := true
        }
    } else {
        warned := false
    }

    if isRunning
        StopBot()
}

SwitchLanguage(ctrl, info) {
    global lang
    lang := ctrl.Text = "English" ? "en" : "tr"
    UpdateGuiText()
}

UpdateGuiText() {
    global myGui, intervalLabel, keyLabel, startBtn, stopBtn, logLabel, statusLabel, statusIcon

    myGui.Title := T("title")
    intervalLabel.Text := T("interval")
    keyLabel.Text := T("key")
    startBtn.Text := T("start")
    stopBtn.Text := T("stop")
    logLabel.Text := T("logs")
    statusLabel.Text := T("status")
    UpdateStatusIcon()
}

; GUI oluşturma
myGui := Gui("+AlwaysOnTop", T("title"))

intervalLabel := myGui.Add("Text", , T("interval"))
intervalInput := myGui.Add("Edit", "vIntervalInput w150", interval)
intervalInput.OnEvent("Change", IntervalChanged)

keyLabel := myGui.Add("Text", "w150", T("key"))
keyInput := myGui.Add("Hotkey", "vKeyInput w150", "t")

startBtn := myGui.Add("Button", "w100", T("start"))
stopBtn := myGui.Add("Button", "w100", T("stop"))

statusLabel := myGui.Add("Text", , T("status"))
statusIcon := myGui.Add("Text", "vStatusIcon", T("inactive"))

logLabel := myGui.Add("Text", "w300", T("logs"))
logBox := myGui.Add("Edit", "vLogText w300 r3 ReadOnly Wrap HScroll", "")

myGui.Add("Text", , "Language / Dil:")
langDrop := myGui.Add("DropDownList", , ["English", "Türkçe"])
langDrop.OnEvent("Change", SwitchLanguage)
langDrop.Value := 1

startBtn.OnEvent("Click", StartBot)
stopBtn.OnEvent("Click", StopBot)

myGui.OnEvent("Close", (*) => StopBot())

UpdateStatusIcon()
myGui.Show()
