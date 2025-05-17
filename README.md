# 🎮 OVR Anti-AFK Bot

[TR] Basit ve hafif bir Anti-AFK (boşta kalma önleyici) script. Oyun arkaplanda çalışıyor olsa bile belirlediğiniz tuşu belirli aralıklarla gönderir.

[EN] A lightweight Anti-AFK script that sends a key at set intervals—even when the game is running in the background.

## 🧰 [TR] Gereksinimler | [EN] Requirements

- ✅ AutoHotkey v2.0.19  
  🔗 [https://www.autohotkey.com/download/](https://www.autohotkey.com/download/)  
- ⚠️ **[TR] Scripti yönetici olarak çalıştırmalısınız.**  
  ⚠️ **[EN] You must run the script as administrator.**

## ❓ [TR] Sık Sorulan Sorular | [EN] Frequently Asked Questions

### [TR] Tuş kombinasyonlarını neden desteklemiyor? (Örneğin: `Shift + F1`)  
Bu, Windows'un girdi yönetimiyle ilgilidir. Script, oyun arkaplanda olsa bile komut gönderebilir. Ancak tuş kombinasyonlarını destekleyen bir sürüm için oyun penceresinin öne getirilmesi gerekir. Bu da istenmeyen bir durumdur.  
Yine de, kombinasyon tuşlarını destekleyen bir sürüm isterseniz benimle iletişime geçebilirsiniz.

### [EN] Why doesn't it support key combinations? (e.g., `Shift + F1`)  
This is related to how Windows handles input. The script can send keys even when the game is in the background. However, supporting key combinations would require bringing the game window to the foreground, which is not desirable in this context.  
Still, if you'd like a version that supports combinations, feel free to contact me.

## 💻 [TR] Hızlı Kurulum (PowerShell ile) | [EN] Quick Setup via PowerShell

[TR] Aşağıdaki komutu PowerShell'e yapıştırarak AutoHotkey v2'yi otomatik indirebilir ve kurabilirsiniz:  
[EN] Paste the following command into PowerShell to automatically download and install AutoHotkey v2:

```powershell
iwr "https://www.autohotkey.com/download/ahk-v2.exe" -OutFile "$env:TEMP\ahk.exe"; Start-Process "$env:TEMP\ahk.exe" "/S" -Wait; Remove-Item "$env:TEMP\ahk.exe"
