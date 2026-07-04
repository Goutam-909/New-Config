-- ######## Window Rules (migrated from float.conf) ########

-- ── Dolphin ──────────────────────────────────────────────────────────────────
hl.window_rule({ match = { class = "^(org.kde.dolphin)$", title = "^(Progress Dialog — Dolphin)$" }, float = true })
hl.window_rule({ match = { class = "^(org.kde.dolphin)$", title = "^(Copying — Dolphin)$" },         float = true })
hl.window_rule({ match = { class = "^(org.kde.dolphin)$", title = "^(Copying — Dolphin)$" },         center = true })
--hl.window_rule({ match = { class = "^(org.kde.dolphin)$" },                                           float = true })
--hl.window_rule({ match = { class = "^(org.kde.dolphin)$" },                                           center = true })
--hl.window_rule({ match = { title = "^(Home — Dolphin)$" },                                            size = { 1100, 720 } })

-- ── Thunar ───────────────────────────────────────────────────────────────────
hl.window_rule({ match = { class = "^(thunar)$" }, float = true })
hl.window_rule({ match = { class = "^(thunar)$" }, center = true })

-- ── Gwenview ─────────────────────────────────────────────────────────────────
hl.window_rule({ match = { class = "^(org.kde.gwenview)$" }, float = true })
hl.window_rule({ match = { class = "^(org.kde.gwenview)$" }, center = true })

-- ── Nautilus ─────────────────────────────────────────────────────────────────
hl.window_rule({ match = { class = "^(org.gnome.Nautilus)$" }, float = true })
hl.window_rule({ match = { class = "^(org.gnome.Nautilus)$" }, center = true })
hl.window_rule({ match = { class = "^(org.gnome.Nautilus)$" }, size = { 1100, 720 } })

-- ── Firefox ───────────────────────────────────────────────────────────────────
hl.window_rule({ match = { title = "^(About Mozilla Firefox)$" },                      float = true })
hl.window_rule({ match = { class = "^(firefox)$", title = "^(Library)$" },             float = true })
hl.window_rule({ match = { class = "^(firefox)$", title = "^(Library)$" },             center = true })

-- ── Zen Browser ──────────────────────────────────────────────────────────────
hl.window_rule({ match = { class = "^(zen)$", title = "^(Library)$" }, float = true })

-- ── Kitty system monitors ─────────────────────────────────────────────────────
hl.window_rule({ match = { class = "^(kitty)$", title = "^(top)$" },  float = true })
hl.window_rule({ match = { class = "^(kitty)$", title = "^(btop)$" }, float = true })
hl.window_rule({ match = { class = "^(kitty)$", title = "^(htop)$" }, float = true })

-- ── Kitty float class ────────────────────────────────────────────────────────
hl.window_rule({ match = { class = "^(kitty-float)$" }, float = true })
hl.window_rule({ match = { class = "^(kitty-float)$" }, size = { 900, 600 } })
hl.window_rule({ match = { class = "^(kitty-float)$" }, center = true })

-- ── Theming / appearance tools ───────────────────────────────────────────────
hl.window_rule({ match = { class = "^(kvantummanager)$" }, float = true })
hl.window_rule({ match = { class = "^(qt5ct)$" },          float = true })
hl.window_rule({ match = { class = "^(qt6ct)$" },          float = true })
hl.window_rule({ match = { class = "^(nwg-look)$" },       float = true })

-- ── Ark ───────────────────────────────────────────────────────────────────────
hl.window_rule({ match = { class = "^(org.kde.ark)$" }, float = true })
hl.window_rule({ match = { class = "^(org.kde.ark)$" }, center = true })

-- ── PulseAudio / pavucontrol ─────────────────────────────────────────────────
hl.window_rule({ match = { class = "^(org.pulseaudio.pavucontrol)$" }, float = true })
hl.window_rule({ match = { class = "^(org.pulseaudio.pavucontrol)$" }, size = { 900, 600 } })
hl.window_rule({ match = { class = "^(org.pulseaudio.pavucontrol)$" }, center = true })

-- ── Bluetooth / Network ───────────────────────────────────────────────────────
hl.window_rule({ match = { class = "^(blueman-manager)$" },      float = true })
hl.window_rule({ match = { class = "^(nm-applet)$" },            float = true })
hl.window_rule({ match = { class = "^(nm-connection-editor)$" }, float = true })

-- ── Polkit ────────────────────────────────────────────────────────────────────
hl.window_rule({ match = { class = "^(org.kde.polkit-kde-authentication-agent-1)$" }, float = true })

-- ── Various GTK/Qt apps ───────────────────────────────────────────────────────
hl.window_rule({ match = { class = "^(Signal)$" },                              float = true }) -- Signal-Gtk
hl.window_rule({ match = { class = "^(com.github.rafostar.Clapper)$" },         float = true }) -- Clapper-Gtk
hl.window_rule({ match = { class = "^(app.drey.Warp)$" },                       float = true }) -- Warp-Gtk
hl.window_rule({ match = { class = "^(net.davidotek.pupgui2)$" },               float = true }) -- ProtonUp-Qt
hl.window_rule({ match = { class = "^(yad)$" },                                 float = true }) -- Protontricks-Gtk
hl.window_rule({ match = { class = "^(org.gnome.eog)$" },                       float = true }) -- Imageviewer-Gtk
hl.window_rule({ match = { class = "^(io.github.alainm23.planify)$" },          float = true }) -- planify-Gtk
hl.window_rule({ match = { class = "^(io.gitlab.theevilskeleton.Upscaler)$" },  float = true }) -- Upscaler-Gtk
hl.window_rule({ match = { class = "^(com.github.unrud.VideoDownloader)$" },    float = true }) -- VideoDownloader-Gtk
hl.window_rule({ match = { class = "^(io.gitlab.adhami3310.Impression)$" },     float = true }) -- Impression-Gtk
hl.window_rule({ match = { class = "^(gpicview)$" },                            float = true })

-- ── YouTube Music (Brave PWA) ─────────────────────────────────────────────────
hl.window_rule({ match = { title = "^(YouTube Music)$" }, float = true })
hl.window_rule({ match = { title = "^(YouTube Music)$" }, center = true })
hl.window_rule({ match = { title = "^(YouTube Music)$" }, size = { 450, 700 } })

-- ── VLC ───────────────────────────────────────────────────────────────────────
--hl.window_rule({ match = { class = "^(vlc)$" }, float = true })
--hl.window_rule({ match = { class = "^(vlc)$" }, center = true })
--hl.window_rule({ match = { class = "^(vlc)$" }, size = { 800, 500 } })

-- ── ProtonVPN ─────────────────────────────────────────────────────────────────
hl.window_rule({ match = { class = "^(protonvpn-app)$" }, float = true })
hl.window_rule({ match = { class = "^(protonvpn-app)$" }, center = true })

-- ── KDialog ───────────────────────────────────────────────────────────────────
hl.window_rule({ match = { class = "^(org.kde.kdialog)$" }, float = true })
hl.window_rule({ match = { class = "^(org.kde.kdialog)$" }, size = { 900, 600 } })
hl.window_rule({ match = { class = "^(org.kde.kdialog)$" }, center = true })

-- ── Loupe (GNOME image viewer) ────────────────────────────────────────────────
hl.window_rule({ match = { class = "^(org.gnome.Loupe)$" }, float = true })

-- ── Library windows (initial title) ──────────────────────────────────────────
hl.window_rule({ match = { initial_title = "^(Library)$" }, float = true })
hl.window_rule({ match = { initial_title = "^(Library)$" }, size = { 900, 600 } })

-- ── Common modal / file dialogs ───────────────────────────────────────────────
hl.window_rule({ match = { title = "^(Open)$" },                    float = true })
hl.window_rule({ match = { title = "^(Choose Files)$" },            float = true })
hl.window_rule({ match = { title = "^(Save As)$" },                 float = true })
hl.window_rule({ match = { title = "^(Confirm to replace files)$" }, float = true })
hl.window_rule({ match = { title = "^(File Operation Progress)$" }, float = true })
hl.window_rule({ match = { class = "^(xdg-desktop-portal-gtk)$" },  float = true })
hl.window_rule({ match = { title = "^(Amberol)$" },                 float = true })

-- ── KCM Bluetooth ────────────────────────────────────────────────────────────
hl.window_rule({ match = { class = "^(kcm_bluetooth)$" }, float = true })
hl.window_rule({ match = { class = "^(kcm_bluetooth)$" }, center = true })
hl.window_rule({ match = { class = "^(kcm_bluetooth)$" }, size = { 500, 600 } })
hl.window_rule({ match = { class = "^(org.kde.bluedevilwizard)$" }, float = true })

-- ── Plasma Windowed ───────────────────────────────────────────────────────────
hl.window_rule({ match = { class = "^(org.kde.plasmawindowed)$" }, float = true })
hl.window_rule({ match = { class = "^(org.kde.plasmawindowed)$" }, size = { 500, 600 } })
hl.window_rule({ match = { class = "^(org.kde.plasmawindowed)$" }, center = true })

-- ── KDE portal / Choose Application ──────────────────────────────────────────
hl.window_rule({ match = { class = "^(org.freedesktop.impl.portal.desktop.kde)$", title = "^(Choose Application)$" }, float = true })

-- ── Settings windows ──────────────────────────────────────────────────────────
hl.window_rule({ match = { title = "^(Settings)$" }, float = true })
hl.window_rule({ match = { title = "^(Settings)$" }, center = true })
hl.window_rule({ match = { title = "^(Settings)$" }, size = { 1000, 700 } })

-- ── Spotify ───────────────────────────────────────────────────────────────────
hl.window_rule({ match = { class = "^(spotify)$" }, float = true })
hl.window_rule({ match = { class = "^(spotify)$" }, center = true })
hl.window_rule({ match = { class = "^(spotify)$" }, size = { 1255, 738 } })

-- ── Baobab (disk usage) ───────────────────────────────────────────────────────
hl.window_rule({ match = { class = "^(org.gnome.baobab)$" }, float = true })
hl.window_rule({ match = { class = "^(org.gnome.baobab)$" }, center = true })

-- ── Quickshell ───────────────────────────────────────────────────────────────
hl.window_rule({ match = { class = "^(org.quickshell)$" }, float = true })
hl.window_rule({ match = { class = "^(org.quickshell)$" }, size = { 1000, 692 } })

-- ── Picture-in-Picture ────────────────────────────────────────────────────────
hl.window_rule({ match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" }, float = true })
hl.window_rule({ match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" }, keep_aspect_ratio = true })
hl.window_rule({ match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" }, move = { "(monitor_w*0.73)", "(monitor_h*0.72)" } })
hl.window_rule({ match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" }, size = { "(monitor_w*0.25)", "(monitor_h*0.25)" } })
hl.window_rule({ match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" }, pin = true })


-- ######## Layer Rules (migrated from float.conf) ########

-- ── Rofi ──────────────────────────────────────────────────────────────────────
hl.layer_rule({ match = { namespace = "rofi" }, blur = true })
hl.layer_rule({ match = { namespace = "rofi" }, ignore_alpha = 0.01 })

-- ── Notifications ─────────────────────────────────────────────────────────────
hl.layer_rule({ match = { namespace = "notifications" }, blur = true })

-- ── SwayNC ────────────────────────────────────────────────────────────────────
hl.layer_rule({ match = { namespace = "swaync-notification-window" }, blur = true })
hl.layer_rule({ match = { namespace = "swaync-notification-window" }, ignore_alpha = 0.3 })
hl.layer_rule({ match = { namespace = "swaync-control-center" },      blur = true })
hl.layer_rule({ match = { namespace = "swaync-control-center" },      ignore_alpha = 0.3 })

-- ── Logout dialog ─────────────────────────────────────────────────────────────
hl.layer_rule({ match = { namespace = "logout_dialog" }, blur = false })
hl.layer_rule({ match = { namespace = "logout_dialog" }, dim_around = true })

-- ── Waybar ────────────────────────────────────────────────────────────────────
hl.layer_rule({ match = { namespace = "waybar" }, blur = true })
hl.layer_rule({ match = { namespace = "waybar" }, ignore_alpha = 0.3 })

-- ── Quickshell (layer) ────────────────────────────────────────────────────────
hl.layer_rule({ match = { namespace = "^(quickshell)$" }, blur = true })
hl.layer_rule({ match = { namespace = "^(quickshell)$" }, ignore_alpha = 0.5 })

-- ── Drawers ───────────────────────────────────────────────────────────────────
hl.layer_rule({ match = { namespace = "drawers" }, blur = true })
hl.layer_rule({ match = { namespace = "drawers" }, ignore_alpha = 0.3 })

-- ── Border ────────────────────────────────────────────────────────────────────
hl.layer_rule({ match = { namespace = "border" }, blur = true })
hl.layer_rule({ match = { namespace = "border" }, ignore_alpha = 0.3 })

-- ── Ambxst ────────────────────────────────────────────────────────────────────
hl.layer_rule({ match = { namespace = "^(ambxst)$" }, blur = true })
hl.layer_rule({ match = { namespace = "^(ambxst)$" }, ignore_alpha = 0.5 })
