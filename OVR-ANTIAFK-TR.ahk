#Requires AutoHotkey v2.0.19
#SingleInstance Force

global isRunning := false
global interval := 5000

SendKeyToODIN() {
    global myGui, logBox
    keyToSend := myGui["KeyInput"].Value

    hwnd := WinExist("ahk_exe ProjectLH.exe")
    if !hwnd {
        AddLog("❌ ODIN penceresi bulunamadı.")
        return
    }

    ControlSend(keyToSend, , "ahk_exe ProjectLH.exe")
    AddLog("📨 '" keyToSend "' tuşu gönderildi.")
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
    interval := StrReplace(intervalRaw, " ") ; boşlukları temizle
    interval := interval + 0 ; string'i sayıya çevir

    if (interval < 100) {
        AddLog("⚠️ Geçersiz aralık, en az 100 ms olmalı.")
        return
    }

    SetTimer(SendKeyToODIN, 0) ; Önceki timer'ı kapat
    SetTimer(SendKeyToODIN, interval) ; Yeni interval ile başlat

    isRunning := true
    AddLog("✅ Bot başlatıldı (her " interval " ms).")
}

StopBot(*) {
    global isRunning
    SetTimer(SendKeyToODIN, 0) ; Timer durdur
    isRunning := false
    AddLog("⏹️ Bot durduruldu.")
}

; GUI oluşturma
myGui := Gui("+AlwaysOnTop", "OVR Anti-AFK")
myGui.Add("Text", , "Gönderim Aralığı (ms):")
intervalInput := myGui.Add("Edit", "vIntervalInput w150", interval)

myGui.Add("Text", , "Gönderilecek Tuş:")
keyInput := myGui.Add("Edit", "vKeyInput w150", "T")

startBtn := myGui.Add("Button", "w100", "Başlat")
stopBtn := myGui.Add("Button", "w100", "Durdur")

myGui.Add("Text", , "Loglar:")
logBox := myGui.Add("Edit", "vLogText w300 r10 ReadOnly Wrap HScroll", "")

startBtn.OnEvent("Click", StartBot)
stopBtn.OnEvent("Click", StopBot)

myGui.Show()
