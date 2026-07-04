--  ██╗    ██╗██╗███╗   ██╗██████╗  ██████╗ ██╗    ██╗    ██████╗ ██╗   ██╗██╗     ███████╗███████╗
--  ██║    ██║██║████╗  ██║██╔══██╗██╔═══██╗██║    ██║    ██╔══██╗██║   ██║██║     ██╔════╝██╔════╝
--  ██║ █╗ ██║██║██╔██╗ ██║██║  ██║██║   ██║██║ █╗ ██║    ██████╔╝██║   ██║██║     █████╗  ███████╗
-- ╚██╗ ████╔╝██║██║╚██╗██║██║  ██║██║   ██║██║███╗██║    ██╔══██╗██║   ██║██║     ██╔══╝  ╚════██║
-- ╚███╔███╔╝ ██║██║ ╚████║██████╔╝╚██████╔╝╚███╔███╔╝    ██║  ██║╚██████╔╝███████╗███████╗███████║
--  ╚══╝╚══╝  ╚═╝╚═╝  ╚═══╝╚═════╝  ╚═════╝  ╚══╝╚══╝     ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝╚══════╝
--
-- Hyprland 0.55 Lua window rules
-- opacity = "active inactive" (use "override" to set absolute values instead of multipliers)

-----------------------------
-- Core apps
-----------------------------

hl.window_rule({ match = { class = "io.bassi.Amberol" },       opacity = "0.60 override 0.30 override" })
hl.window_rule({ match = { class = "Thunar" },                 opacity = "1.0 override 0.92 override" })

-- hl.window_rule({ match = { class = "firefox" },             opacity = "0.99 override 0.88 override" })
hl.window_rule({ match = { class = "Google-chrome" },          opacity = "0.90 override 0.90 override" })
--hl.window_rule({ match = { class = "zen" },                    opacity = "0.90 override 0.80 override" })
hl.window_rule({ match = { class = "Brave-browser" },          opacity = "0.90 override 0.90 override" })

-----------------------------
-- Code / IDEs
-----------------------------

hl.window_rule({ match = { class = "code-oss" },                    opacity = "0.80 override 0.80 override" })
hl.window_rule({ match = { class = "[Cc]ode" },                     opacity = "0.80 override 0.80 override" })
hl.window_rule({ match = { class = "code-url-handler" },            opacity = "0.80 override 0.80 override" })
hl.window_rule({ match = { class = "code-insiders-url-handler" },   opacity = "0.80 override 0.80 override" })

-----------------------------
-- Terminals & file managers
-----------------------------

-- hl.window_rule({ match = { class = "kitty" },              opacity = "0.80 override 0.70 override" })
-- hl.window_rule({ match = { class = "org.kde.dolphin" },    opacity = "0.90 override 0.80 override" })
hl.window_rule({ match = { class = "org.kde.ark" },           opacity = "0.80 override 0.80 override" })
-- hl.window_rule({ match = { class = "thunar" },             opacity = "0.80 override 0.70 override" })
hl.window_rule({ match = { class = "org.gnome.Nautilus" },    opacity = "1.0 override 0.92 override" })

-----------------------------
-- Config / appearance tools
-----------------------------

hl.window_rule({ match = { class = "nwg-look" },        opacity = "0.80 override 0.80 override" })
hl.window_rule({ match = { class = "qt5ct" },           opacity = "0.80 override 0.80 override" })
hl.window_rule({ match = { class = "qt6ct" },           opacity = "0.80 override 0.80 override" })
hl.window_rule({ match = { class = "kvantummanager" },  opacity = "0.80 override 0.80 override" })

-- hl.window_rule({ match = { title = "Uchiha Settings" }, opacity = "0.80 override 0.80 override" })

-----------------------------
-- Audio / network / auth
-----------------------------

hl.window_rule({ match = { class = "org.pulseaudio.pavucontrol" },              opacity = "0.80 override 0.70 override" })
hl.window_rule({ match = { class = "blueman-manager" },                         opacity = "0.80 override 0.70 override" })
hl.window_rule({ match = { class = "nm-applet" },                               opacity = "0.80 override 0.70 override" })
hl.window_rule({ match = { class = "nm-connection-editor" },                    opacity = "0.80 override 0.70 override" })
hl.window_rule({ match = { class = "org.kde.polkit-kde-authentication-agent-1" }, opacity = "0.80 override 0.70 override" })
hl.window_rule({ match = { class = "polkit-gnome-authentication-agent-1" },     opacity = "0.80 override 0.70 override" })

-----------------------------
-- Portals
-----------------------------

hl.window_rule({ match = { class = "org.freedesktop.impl.portal.desktop.gtk" },      opacity = "0.80 override 0.70 override" })
hl.window_rule({ match = { class = "org.freedesktop.impl.portal.desktop.hyprland" }, opacity = "0.80 override 0.70 override" })

-----------------------------
-- Media / music
-----------------------------

hl.window_rule({ match = { class = "steamwebhelper" },           opacity = "0.70 override 0.70 override" })
-- hl.window_rule({ match = { class = "[Ss]potify" },            opacity = "0.70 override 0.70 override" })
-- hl.window_rule({ match = { initial_title = "Spotify Free" },  opacity = "0.70 override 0.70 override" })
hl.window_rule({ match = { initial_title = "Spotify Premium" },  opacity = "0.70 override 0.70 override" })

-----------------------------
-- GTK / Qt apps
-----------------------------

hl.window_rule({ match = { class = "com.github.rafostar.Clapper" },       opacity = "0.90 override 0.90 override" })
hl.window_rule({ match = { class = "com.github.tchx84.Flatseal" },        opacity = "0.80 override 0.80 override" })
hl.window_rule({ match = { class = "hu.kramo.Cartridges" },               opacity = "0.80 override 0.80 override" })
--hl.window_rule({ match = { class = "com.obsproject.Studio" },             opacity = "0.80 override 0.80 override" })
hl.window_rule({ match = { class = "gnome-boxes" },                       opacity = "0.80 override 0.80 override" })
hl.window_rule({ match = { class = "vesktop" },                           opacity = "0.80 override 0.80 override" })
hl.window_rule({ match = { class = "discord" },                           opacity = "0.80 override 0.80 override" })
hl.window_rule({ match = { class = "WebCord" },                           opacity = "0.80 override 0.80 override" })
hl.window_rule({ match = { class = "ArmCord" },                           opacity = "0.80 override 0.80 override" })
hl.window_rule({ match = { class = "app.drey.Warp" },                     opacity = "0.80 override 0.80 override" })
hl.window_rule({ match = { class = "net.davidotek.pupgui2" },             opacity = "0.80 override 0.80 override" })
hl.window_rule({ match = { class = "yad" },                               opacity = "0.80 override 0.80 override" })
hl.window_rule({ match = { class = "Signal" },                            opacity = "0.80 override 0.80 override" })
hl.window_rule({ match = { class = "io.github.alainm23.planify" },        opacity = "0.80 override 0.80 override" })
hl.window_rule({ match = { class = "io.gitlab.theevilskeleton.Upscaler" }, opacity = "0.80 override 0.80 override" })
hl.window_rule({ match = { class = "com.github.unrud.VideoDownloader" },  opacity = "0.80 override 0.80 override" })
hl.window_rule({ match = { class = "io.gitlab.adhami3310.Impression" },   opacity = "0.80 override 0.80 override" })
hl.window_rule({ match = { class = "io.missioncenter.MissionCenter" },    opacity = "0.80 override 0.80 override" })
hl.window_rule({ match = { class = "io.github.flattool.Warehouse" },      opacity = "0.80 override 0.80 override" })

-----------------------------
-- YouTube Music PWA (Brave)
-----------------------------

hl.window_rule({ match = { title = "YouTube Music" }, opacity = "0.80 override 0.80 override" })

-----------------------------
-- Misc
-----------------------------

hl.window_rule({ match = { class = "rmpc-term" },           opacity = "0.80 override 0.70 override" })
-- hl.window_rule({ match = { class = "kitty-float" },      opacity = "0.80 override 0.70 override" })
hl.window_rule({ match = { class = "org.kde.plasmawindowed" }, opacity = "0.70 override 0.60 override" })

-----------------------------
-- Hide KDE Wayland compositor
-----------------------------

hl.window_rule({
    match          = { title = "KDE Wayland Compositor.*" },
    workspace      = "special:kwin_hidden",
    float          = true,
    size           = { 1, 1 },
    move           = { -9999, -9999 },
    no_initial_focus = true,
    no_focus       = true,
})
