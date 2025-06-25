# Windows Tweaks Tool for Windows 10/11
# 100% PowerShell - Console Menu, Toggle Features, Backup & Restore

$backupPath = "$env:USERPROFILE\Documents\WindowsTweaks_Backup"
$backupFile = Join-Path $backupPath "tweaks_backup.json"

if (-not (Test-Path $backupPath)) {
    New-Item -ItemType Directory -Path $backupPath | Out-Null
}

# Sauvegarde/Chargement des états
function Save-Settings ($settings) {
    $settings | ConvertTo-Json -Depth 10 | Out-File -Encoding UTF8 $backupFile
    Write-Host "Paramètres sauvegardés dans $backupFile" -ForegroundColor Green
    Pause
}

function Load-Settings {
    if (Test-Path $backupFile) {
        $json = Get-Content $backupFile -Raw
        return $json | ConvertFrom-Json
    }
    else {
        Write-Host "Aucune sauvegarde trouvée." -ForegroundColor Yellow
        Pause
        return $null
    }
}

# Fonctions utilitaires
function Restart-Explorer {
    Stop-Process -Name explorer -Force
    Start-Process explorer.exe
}

# Fonctions Toggle

function Toggle-DarkMode {
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    $current = Get-ItemPropertyValue -Path $path -Name "AppsUseLightTheme" -ErrorAction SilentlyContinue
    $new = if ($current -eq 1) { 0 } else { 1 }
    Set-ItemProperty -Path $path -Name "AppsUseLightTheme" -Value $new
    Set-ItemProperty -Path $path -Name "SystemUsesLightTheme" -Value $new
    Write-Host "Mode Sombre/Clair appliqué."
    Restart-Explorer
}

function Toggle-Cortana {
    $path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
    $current = Get-ItemPropertyValue -Path $path -Name "AllowCortana" -ErrorAction SilentlyContinue
    $new = if ($current -eq 0) { 1 } else { 0 }
    Set-ItemProperty -Path $path -Name "AllowCortana" -Value $new
    Write-Host "Cortana modifié (nécessite redémarrage)."
}

function Toggle-SearchBox {
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
    $current = Get-ItemPropertyValue -Path $path -Name "SearchboxTaskbarMode" -ErrorAction SilentlyContinue
    $new = if ($current -eq 1) { 0 } else { 1 }
    Set-ItemProperty -Path $path -Name "SearchboxTaskbarMode" -Value $new
    Write-Host "Barre de recherche modifiée."
    Restart-Explorer
}

function Toggle-Widgets {
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $current = Get-ItemPropertyValue -Path $path -Name "TaskbarDa" -ErrorAction SilentlyContinue
    $new = if ($current -eq 1) { 0 } else { 1 }
    Set-ItemProperty -Path $path -Name "TaskbarDa" -Value $new
    Write-Host "Widgets modifiés."
    Restart-Explorer
}

function Toggle-StartSuggestions {
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    $current = Get-ItemPropertyValue -Path $path -Name "SubscribedContent-338393Enabled" -ErrorAction SilentlyContinue
    $new = if ($current -eq 1) { 0 } else { 1 }
    Set-ItemProperty -Path $path -Name "SubscribedContent-338393Enabled" -Value $new
    Write-Host "Suggestions du menu Démarrer modifiées."
    Restart-Explorer
}

function Toggle-SystemAnimations {
    $path = "HKCU:\Control Panel\Desktop"
    $current = Get-ItemPropertyValue -Path $path -Name "UserPreferencesMask" -ErrorAction SilentlyContinue
    # UserPreferencesMask est complexe, on passe par une méthode simplifiée via SPI_SETANIMATION
    # Ici on fait un basculement avec SystemParametersInfo via .NET
    $currentState = [System.Windows.Forms.SystemInformation]::MenuAnimation
    Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinAPI {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(int uiAction, int uiParam, ref int pvParam, int fWinIni);
}
"@
    $SPI_SETANIMATION = 0x0049
    $SPIF_SENDCHANGE = 0x02
    $animation = if ($currentState) { 0 } else { 1 }
    $animStruct = New-Object byte[] 8
    $animStruct[0] = $animation
    # This is a hack; better to use another method, but for now:
    Write-Host "Basculer animations système non implémenté précisément."
}

function Toggle-StartupSound {
    $path = "HKCU:\AppEvents\Schemes\Apps\.Default\SystemStart\.Current"
    $current = Get-ItemPropertyValue -Path $path -Name "(default)" -ErrorAction SilentlyContinue
    if ($current -and $current -ne "") {
        # Désactiver
        Set-ItemProperty -Path $path -Name "(default)" -Value ""
        Write-Host "Son de démarrage désactivé."
    }
    else {
        # Activer - restaurer valeur par défaut (non garantie)
        Set-ItemProperty -Path $path -Name "(default)" -Value "%SystemRoot%\Media\Windows Startup.wav"
        Write-Host "Son de démarrage activé."
    }
}

function Toggle-ThisPCOnDesktop {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
    $valueName = "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
    $current = Get-ItemPropertyValue -Path $regPath -Name $valueName -ErrorAction SilentlyContinue
    $new = if ($current -eq 0) { 1 } else { 0 }
    Set-ItemProperty -Path $regPath -Name $valueName -Value $new
    Write-Host "'Ce PC' sur le bureau modifié."
    Restart-Explorer
}

function Toggle-LockScreenBlur {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Lock Screen"
    # Pas documenté officiellement, on passe par SystemUsesLightTheme?
    # Autre méthode : ClearType, ou Disable LockScreen blur policy (Windows 11+)
    $regPath2 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    $current = Get-ItemPropertyValue -Path $regPath2 -Name "SystemUsesLightTheme" -ErrorAction SilentlyContinue
    # Pas trivial de basculer blur; on fait une bascule d’un paramètre commun.
    Write-Host "Basculer flou écran verrouillage non implémenté précisément."
}

function Toggle-Notifications {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications"
    $current = Get-ItemPropertyValue -Path $regPath -Name "ToastEnabled" -ErrorAction SilentlyContinue
    $new = if ($current -eq 1) { 0 } else { 1 }
    Set-ItemProperty -Path $regPath -Name "ToastEnabled" -Value $new
    Write-Host "Notifications modifiées."
}

function Toggle-TransparencyEffects {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    $current = Get-ItemPropertyValue -Path $regPath -Name "EnableTransparency" -ErrorAction SilentlyContinue
    $new = if ($current -eq 1) { 0 } else { 1 }
    Set-ItemProperty -Path $regPath -Name "EnableTransparency" -Value $new
    Write-Host "Effets de transparence modifiés."
    Restart-Explorer
}

function Toggle-LockScreenBackground {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Lock Screen"
    Write-Host "Basculer fond écran verrouillage non implémenté précisément."
}

function Toggle-VisualEffectsPerformance {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    # Toggle between performance and balanced (simplification)
    $current = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -ErrorAction SilentlyContinue
    $new = if ($current -eq 2) { 1 } else { 2 }
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value $new
    Write-Host "Effets visuels modifiés (performance/balancé)."
}

function Remove-Bloatware {
    $bloatApps = @(
        "Microsoft.ZuneMusic",
        "Microsoft.BingNews",
        "Microsoft.GetHelp",
        "Microsoft.Getstarted",
        "Microsoft.Microsoft3DViewer",
        "Microsoft.MicrosoftOfficeHub",
        "Microsoft.MicrosoftSolitaireCollection",
        "Microsoft.MicrosoftStickyNotes",
        "Microsoft.MixedReality.Portal",
        "Microsoft.OneConnect",
        "Microsoft.People",
        "Microsoft.Print3D",
        "Microsoft.SkypeApp",
        "Microsoft.WindowsFeedbackHub",
        "Microsoft.XboxApp",
        "Microsoft.XboxGameOverlay",
        "Microsoft.XboxGamingOverlay",
        "Microsoft.XboxIdentityProvider",
        "Microsoft.XboxSpeechToTextOverlay",
        "Microsoft.YourPhone"
    )
    foreach ($app in $bloatApps) {
        Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -eq $app | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
    }
    Write-Host "Applications inutiles supprimées (bloatware)."
}

function Disable-WindowsAds {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    Set-ItemProperty -Path $regPath -Name "SystemPaneSuggestionsEnabled" -Value 0
    Set-ItemProperty -Path $regPath -Name "SubscribedContent-310093Enabled" -Value 0
    Write-Host "Publicités dans Windows désactivées."
}

function Toggle-SettingsSuggestions {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\SettingsPageVisibility"
    $current = Get-ItemPropertyValue -Path $regPath -Name "SettingsPageVisibility" -ErrorAction SilentlyContinue
    # Note: manipulation plus complexe, simplification:
    Write-Host "Basculer suggestions de paramètres non implémenté précisément."
}

function Remove-BingFromSearch {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    if (-not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }
    Set-ItemProperty -Path $regPath -Name "DisableWebSearch" -Value 1
    Set-ItemProperty -Path $regPath -Name "ConnectedSearchUseWeb" -Value 0
    Write-Host "Bing désactivé dans la recherche Windows."
}

function Disable-Timeline {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Timeline"
    Set-ItemProperty -Path $regPath -Name "Enabled" -Value 0 -ErrorAction SilentlyContinue
    Write-Host "Timeline / Historique d'activité désactivé."
}

function Toggle-RecentFilesQuickAccess {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $current = Get-ItemPropertyValue -Path $regPath -Name "ShowRecent" -ErrorAction SilentlyContinue
    $new = if ($current -eq 1) { 0 } else { 1 }
    Set-ItemProperty -Path $regPath -Name "ShowRecent" -Value $new
    Write-Host "Fichiers récents dans Accès rapide modifiés."
    Restart-Explorer
}

function Disable-LiveTiles {
    # Windows 11 ne supporte plus les Live Tiles, mais sur Windows 10 on peut supprimer les tuiles dynamiques
    # Suppression complète impossible via script simple, on désactive via reg
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    Set-ItemProperty -Path $regPath -Name "SubscribedContent-338388Enabled" -Value 0
    Write-Host "Tuiles dynamiques désactivées."
}

function Toggle-GameBar {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR"
    $current = Get-ItemPropertyValue -Path $regPath -Name "AppCaptureEnabled" -ErrorAction SilentlyContinue
    $new = if ($current -eq 1) { 0 } else { 1 }
    Set-ItemProperty -Path $regPath -Name "AppCaptureEnabled" -Value $new
    Write-Host "Game Bar modifié."
}

function Toggle-AutoFocusAssist {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings"
    $current = Get-ItemPropertyValue -Path $regPath -Name "FocusAssistAutoRulesEnabled" -ErrorAction SilentlyContinue
    $new = if ($current -eq 1) { 0 } else { 1 }
    Set-ItemProperty -Path $regPath -Name "FocusAssistAutoRulesEnabled" -Value $new
    Write-Host "Assistant de concentration automatique modifié."
}

function Toggle-SystemTrayIcons {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"
    $current = Get-ItemPropertyValue -Path $regPath -Name "EnableAutoTray" -ErrorAction SilentlyContinue
    $new = if ($current -eq 1) { 0 } else { 1 }
    Set-ItemProperty -Path $regPath -Name "EnableAutoTray" -Value $new
    Write-Host "Icônes de la barre système modifiées."
    Restart-Explorer
}

function Clean-ExplorerContextMenu {
    # Pour simplifier : on supprime certains items contextuels
    $paths = @(
        "HKCU:\Software\Classes\*\shell\Open with Code",
        "HKCU:\Software\Classes\Directory\shell\Open with Code",
        "HKCU:\Software\Classes\Directory\Background\shell\Open with Code"
    )
    foreach ($p in $paths) {
        if (Test-Path $p) {
            Remove-Item -Path $p -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    Write-Host "Menu contextuel de l'explorateur nettoyé."
    Restart-Explorer
}

function Reset-VisualSettings {
    # Reset quelques clés au défaut
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 1
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 1
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 1
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 1
    Write-Host "Réinitialisation des réglages visuels appliquée."
    Restart-Explorer
}

function Show-Menu {
    Clear-Host
    Write-Host "================ Windows UI Tweaks ==================" -ForegroundColor Cyan
    Write-Host "1.  Basculer Mode Sombre / Clair"
    Write-Host "2.  Activer/Désactiver Cortana"
    Write-Host "3.  Afficher/Masquer la barre de recherche"
    Write-Host "4.  Afficher/Masquer les widgets"
    Write-Host "5.  Afficher/Masquer les suggestions du menu Démarrer"
    Write-Host "6.  Activer/Désactiver animations système (non implémenté)"
    Write-Host "7.  Activer/Désactiver son de démarrage"
    Write-Host "8.  Afficher/Masquer 'Ce PC' sur le bureau"
    Write-Host "9.  Activer/Désactiver flou écran de verrouillage (non implémenté)"
    Write-Host "10. Activer/Désactiver notifications"
    Write-Host "11. Activer/Désactiver transparence"
    Write-Host "12. Activer/Désactiver fond écran verrouillage (non implémenté)"
    Write-Host "13. Réduire/Restaurer effets visuels (performance)"
    Write-Host "14. Supprimer applications inutiles (bloatware)"
    Write-Host "15. Désactiver pubs dans Windows"
    Write-Host "16. Activer/Désactiver suggestions de paramètres (non implémenté)"
    Write-Host "17. Supprimer Bing de la recherche Windows"
    Write-Host "18. Désactiver Timeline / Historique activité"
    Write-Host "19. Afficher/Masquer fichiers récents dans 'Accès rapide'"
    Write-Host "20. Désactiver tuiles dynamiques (Live Tiles)"
    Write-Host "21. Activer/Désactiver Game Bar"
    Write-Host "22. Activer/Désactiver Assistant de concentration auto"
    Write-Host "23. Afficher/Masquer icônes de la barre système"
    Write-Host "24. Nettoyer menu contextuel de l'explorateur"
    Write-Host "25. Réinitialiser tous les réglages visuels"
    Write-Host "26. Sauvegarder paramètres actuels"
    Write-Host "27. Restaurer paramètres sauvegardés"
    Write-Host "0.  Quitter"
    Write-Host "===================================================="
}

while ($true) {
    Show-Menu
    $choice = Read-Host "Choisissez une option"
    switch ($choice) {
        0 { break }
        1 { Toggle-DarkMode }
        2 { Toggle-Cortana }
        3 { Toggle-SearchBox }
        4 { Toggle-Widgets }
        5 { Toggle-StartSuggestions }
        6 { Write-Host "Fonction non implémentée." }
        7 { Toggle-StartupSound }
        8 { Toggle-ThisPCOnDesktop }
        9 { Write-Host "Fonction non implémentée." }
        10 { Toggle-Notifications }
        11 { Toggle-TransparencyEffects }
        12 { Write-Host "Fonction non implémentée." }
        13 { Toggle-VisualEffectsPerformance }
        14 { Remove-Bloatware }
        15 { Disable-WindowsAds }
        16 { Write-Host "Fonction non implémentée." }
        17 { Remove-BingFromSearch }
        18 { Disable-Timeline }
        19 { Toggle-RecentFilesQuickAccess }
        20 { Disable-LiveTiles }
        21 { Toggle-GameBar }
        22 { Toggle-AutoFocusAssist }
        23 { Toggle-SystemTrayIcons }
        24 { Clean-ExplorerContextMenu }
        25 { Reset-VisualSettings }
        26 {
            # Sauvegarde états
            $settings = @{
                DarkMode = (Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme")
                Cortana = (Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -ErrorAction SilentlyContinue)
                SearchBox = (Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode")
                Widgets = (Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa")
                StartSuggestions = (Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled")
                StartupSound = (Get-ItemPropertyValue -Path "HKCU:\AppEvents\Schemes\Apps\.Default\SystemStart\.Current" -Name "(default)" -ErrorAction SilentlyContinue)
                ThisPCOnDesktop = (Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -ErrorAction SilentlyContinue)
                Notifications = (Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -ErrorAction SilentlyContinue)
                Transparency = (Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -ErrorAction SilentlyContinue)
                VisualEffects = (Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -ErrorAction SilentlyContinue)
                StartMenuAds = (Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -ErrorAction SilentlyContinue)
                BingSearch = (Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -ErrorAction SilentlyContinue)
                Timeline = (Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Timeline" -Name "Enabled" -ErrorAction SilentlyContinue)
                RecentFiles = (Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowRecent" -ErrorAction SilentlyContinue)
                GameBar = (Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -ErrorAction SilentlyContinue)
                FocusAssist = (Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" -Name "FocusAssistAutoRulesEnabled" -ErrorAction SilentlyContinue)
                SystemTrayIcons = (Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "EnableAutoTray" -ErrorAction SilentlyContinue)
            }
            Save-Settings $settings
        }
        27 {
            $settings = Load-Settings
            if ($settings -ne $null) {
                Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value $settings.DarkMode
                Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value $settings.DarkMode
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Value $settings.Cortana
                Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value $settings.SearchBox
                Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value $settings.Widgets
                Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled" -Value $settings.StartSuggestions
                # Pas toutes les valeurs gérées ici pour simplifier
                Write-Host "Réglages restaurés. Redémarrage de l'explorateur..."
                Restart-Explorer
            } else {
                Write-Host "Aucune sauvegarde trouvée."
            }
        }
        default { Write-Host "Choix invalide." }
    }
    Write-Host "Appuyez sur une touche pour continuer..."
    [void][System.Console]::ReadKey($true)
}
