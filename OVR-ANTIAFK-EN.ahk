#Requires AutoHotkey v2.0.19
#SingleInstance Force

global isRunning := false
global interval := 5000

SendKeyToODIN() {
    global myGui, logBox
    keyToSend := myGui["KeyInput"].Value

    hwnd := WinExist("ahk_exe ProjectLH.exe")
    if !hwnd {
        AddLog("❌ ODIN window not found.")
        return
    }

    ControlSend(keyToSend, , "ahk_exe ProjectLH.exe")
    AddLog("📨 Key '" keyToSend "' sent.")
}

AddLog(text) {
    global logBox
    tStamp := FormatTime(, "HH:mm:ss")
    prevLog := logBox.Text
    newLog := tStamp " - " text "`r`n" prevLog
    logBox.Text := newLog
}

StartBot(*) {
    global isRunning, interval, intervalInput

    intervalRaw := intervalInput.Value
    interval := StrReplace(intervalRaw, " ") ; remove spaces
    interval := interval + 0 ; convert string to number

    if (interval < 100) {
        AddLog("⚠️ Invalid interval, must be at least 100 ms.")
        return
    }

    SetTimer(SendKeyToODIN, 0) ; Stop previous timer
    SetTimer(SendKeyToODIN, interval) ; Start with new interval

    isRunning := true
    AddLog("✅ Bot started (every " interval " ms).")
}

StopBot(*) {
    global isRunning
    SetTimer(SendKeyToODIN, 0) ; Stop timer
    isRunning := false
    AddLog("⏹️ Bot stopped.")
}

; Create GUI
myGui := Gui("+AlwaysOnTop", "OVR Anti-AFK")
myGui.Add("Text", , "Send Interval (ms):")
intervalInput := myGui.Add("Edit", "vIntervalInput w150", interval)

myGui.Add("Text", , "Key to Send:")
keyInput := myGui.Add("Edit", "vKeyInput w150", "T")

startBtn := myGui.Add("Button", "w100", "Start")
stopBtn := myGui.Add("Button", "w100", "Stop")

myGui.Add("Text", , "Logs:")
logBox := myGui.Add("Edit", "vLogText w300 r10 ReadOnly Wrap HScroll", "")

startBtn.OnEvent("Click", StartBot)
stopBtn.OnEvent("Click", StopBot)

myGui.Show()
