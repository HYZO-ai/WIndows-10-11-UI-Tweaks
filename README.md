# Windows UI Tweaker

**Windows UI Tweaker** est un script PowerShell 100% console permettant de modifier et personnaliser plusieurs aspects visuels et fonctionnels de Windows 10 et Windows 11 via un menu interactif. Ce script facilite l'activation ou la désactivation rapide de nombreuses fonctionnalités courantes de l'interface Windows, sans passer par plusieurs menus de configuration.

---

## Prérequis

- **Windows 10 ou Windows 11** (les fonctionnalités sont compatibles avec ces versions)
- **PowerShell 5.1 ou supérieur** (PowerShell intégré par défaut dans Windows 10/11)
- **Droits administrateur** : Le script doit être lancé avec des privilèges administratifs pour modifier le registre et appliquer certains paramètres système.
- **Exécution de scripts PowerShell autorisée** : Assurez-vous que la politique d’exécution permet l’exécution de scripts (`Set-ExecutionPolicy RemoteSigned` ou `Bypass`).

---

## Point d'attention

- Certaines modifications touchent le registre Windows et peuvent affecter le comportement du système.
- Il est fortement recommandé de **sauvegarder vos données importantes** avant d'utiliser ce script.
- Certaines fonctionnalités nécessitent un redémarrage de l'explorateur Windows ou du système pour être pleinement effectives.
- Les fonctionnalités non implémentées sont indiquées dans la liste ci-dessous et peuvent être développées ultérieurement.

---

## Fonctionnalités

Le script propose 25 options principales, chacune permettant d'activer ou désactiver une fonctionnalité, souvent en basculant entre deux états :

| #  | Fonctionnalité                                     | Description                                                      |
|-----|-------------------------------------------------|------------------------------------------------------------------|
| 1   | Basculer Mode Sombre / Clair                     | Change le thème entre mode sombre et clair                        |
| 2   | Activer/Désactiver Cortana                        | Active ou désactive l'assistant vocal Cortana                     |
| 3   | Afficher/Masquer la barre de recherche            | Affiche ou masque la barre de recherche dans la barre des tâches |
| 4   | Afficher/Masquer les widgets                      | Affiche ou masque le panneau des widgets                          |
| 5   | Afficher/Masquer les suggestions du menu Démarrer | Active ou désactive les suggestions dans le menu Démarrer        |
| 6   | Activer/Désactiver animations système             | (Non implémenté)                                                  |
| 7   | Activer/Désactiver son de démarrage                | Active ou désactive le son de démarrage Windows                   |
| 8   | Afficher/Masquer "Ce PC" sur le bureau             | Affiche ou masque l'icône "Ce PC" sur le bureau                   |
| 9   | Activer/Désactiver flou écran de verrouillage      | (Non implémenté)                                                  |
| 10  | Activer/Désactiver notifications                    | Active ou désactive les notifications système                     |
| 11  | Activer/Désactiver transparence                     | Active ou désactive les effets de transparence dans l’interface  |
| 12  | Activer/Désactiver fond écran verrouillage          | (Non implémenté)                                                  |
| 13  | Réduire/Restaurer effets visuels (performance)      | Passe les effets visuels en mode performance ou standard          |
| 14  | Supprimer applications inutiles (bloatware)          | Désinstalle certaines applications préinstallées inutiles        |
| 15  | Désactiver pubs dans Windows                          | Désactive les publicités et suggestions dans Windows              |
| 16  | Activer/Désactiver suggestions de paramètres         | (Non implémenté)                                                  |
| 17  | Supprimer Bing de la recherche Windows                | Désactive la recherche web Bing intégrée dans la recherche locale |
| 18  | Désactiver Timeline / Historique activité             | Désactive la timeline d’activités Windows                         |
| 19  | Afficher/Masquer fichiers récents dans "Accès rapide" | Affiche ou masque les fichiers récents dans l'explorateur        |
| 20  | Désactiver tuiles dynamiques (Live Tiles)              | Désactive l'actualisation des tuiles dynamiques du menu Démarrer |
| 21  | Activer/Désactiver Game Bar                             | Active ou désactive la barre de jeu Game Bar                      |
| 22  | Activer/Désactiver Assistant de concentration auto     | Active ou désactive l'assistant de concentration automatique      |
| 23  | Afficher/Masquer icônes de la barre système              | Affiche ou masque les icônes cachées dans la barre système       |
| 24  | Nettoyer menu contextuel de l'explorateur                 | Supprime certains éléments non désirés dans le menu contextuel   |
| 25  | Réinitialiser tous les réglages visuels                    | Restaure les réglages visuels par défaut                          |
| 26  | Sauvegarder paramètres actuels                              | Enregistre les paramètres actuels dans un fichier de sauvegarde  |
| 27  | Restaurer paramètres sauvegardés                            | Restaure les paramètres à partir du fichier de sauvegarde        |

---

## Utilisation

1. **Exécution**

   Lancez PowerShell en mode administrateur, puis exécutez le script :

   ```powershell
   .\WindowsUITweaker.ps1
