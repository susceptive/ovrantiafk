#Requires AutoHotkey v2.0.19
#SingleInstance Force

global isRunning := false
global interval := 5000
global lang := "en"

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
        "logs", "Kayıtlar:",
        "status", "Durum:",
        "started", "✅ Bot başlatıldı (her {1} ms).",
        "stopped", "⏹️ Bot durduruldu.",
        "invalidInterval", "⚠️ Geçersiz aralık, en az 100 ms olmalı.",
        "notFound", "❌ ODIN penceresi bulunamadı.",
        "sent", "📨 '{1}' tuşu gönderildi.",
        "active", "🟢 Aktif",
        "inactive", "🔴 Pasif"
    )
)

T(key, args*) {
    global lang, translations
    text := translations[lang][key]
    Loop args.Length
        text := StrReplace(text, "{" A_Index "}", args[A_Index])
    return text
}

SendKeyToODIN() {
    global myGui, logBox, isRunning
    if !isRunning
        return

    keyToSend := myGui["KeyInput"].Value
    keyToSend := StrLower(keyToSend)  ; Küçük harfe çeviriyoruz

    hwnd := WinExist("ahk_exe ProjectLH.exe")
    if !hwnd {
        AddLog(T("notFound"))
        return
    }

    ControlSend(keyToSend, , "ahk_exe ProjectLH.exe")
    AddLog(T("sent", keyToSend))
}

AddLog(text) {
    global logBox
    tStamp := FormatTime(, "HH:mm:ss")
    prevLog := logBox.Text
    newLog := tStamp " - " text "`r`n" prevLog
    logBox.Text := newLog
}

ShowNotification(title, message) {
    TrayTip title, message
}

UpdateStatusIcon() {
    global statusIcon, isRunning
    statusIcon.Value := isRunning ? T("active") : T("inactive")
}

StartBot(*) {
    global isRunning, interval, intervalInput

    intervalRaw := intervalInput.Value
    interval := StrReplace(intervalRaw, " ")
    interval := interval + 0

    if (interval < 100) {
        AddLog(T("invalidInterval"))
        return
    }

    SetTimer(SendKeyToODIN, 0)
    SetTimer(SendKeyToODIN, interval)

    isRunning := true
    UpdateStatusIcon()
    AddLog(T("started", interval))
    ShowNotification("OVR Anti-AFK", T("started", interval))
}

StopBot(*) {
    global isRunning
    SetTimer(SendKeyToODIN, 0)
    isRunning := false
    UpdateStatusIcon()
    AddLog(T("stopped"))
    ShowNotification("OVR Anti-AFK", T("stopped"))
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

; GUI Oluşturma
myGui := Gui("+AlwaysOnTop", T("title"))
intervalLabel := myGui.Add("Text", , T("interval"))
intervalInput := myGui.Add("Edit", "vIntervalInput w150", interval)

keyLabel := myGui.Add("Text", "w150", T("key"))
keyInput := myGui.Add("Edit", "vKeyInput w150", "T")

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

UpdateStatusIcon()
myGui.Show()
