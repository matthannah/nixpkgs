{ stdenv, fetchurl, pkgconfig, glib, itstool, libxml2, xorg, dbus
, intltool, accountsservice, libX11, gnome3, systemd, autoreconfHook
, gtk, libcanberra-gtk3, pam, libtool, gobjectIntrospection, plymouth
, librsvg, coreutils, fetchpatch }:

stdenv.mkDerivation rec {
  name = "gdm-${version}";
  version = "3.26.2.1";

  src = fetchurl {
    url = "mirror://gnome/sources/gdm/${gnome3.versionBranch version}/${name}.tar.xz";
    sha256 = "17ddcb00602c2b426de58bb4b0d99af9de27450a8557dcc5ec850c080d55ad57";
  };

  passthru = {
    updateScript = gnome3.updateScript { packageName = "gdm"; attrPath = "gnome3.gdm"; };
  };

  # Only needed to make it build
  preConfigure = ''
    substituteInPlace ./configure --replace "/usr/bin/X" "${xorg.xorgserver.out}/bin/X"
  '';

  postPatch = ''
    substituteInPlace daemon/gdm-manager.c --replace "/bin/plymouth" "${plymouth}/bin/plymouth"
    substituteInPlace data/gdm.service.in  --replace "/bin/kill" "${coreutils}/bin/kill"
  '';

  configureFlags = [ "--sysconfdir=/etc"
                     "--localstatedir=/var"
                     "--with-plymouth=yes"
                     "--with-initial-vt=7"
                     "--with-systemdsystemunitdir=$(out)/etc/systemd/system" ];

  nativeBuildInputs = [ pkgconfig libxml2 itstool intltool autoreconfHook libtool gnome3.dconf ];
  buildInputs = [ glib accountsservice systemd
                  gobjectIntrospection libX11 gtk
                  libcanberra-gtk3 pam plymouth librsvg ];

  enableParallelBuilding = true;

  # Disable Access Control because our X does not support FamilyServerInterpreted yet
  patches = [
    # Change hardcoded paths to nix store paths.
    (substituteAll {
      src = ./fix-paths.patch;
      inherit coreutils plymouth xwayland;
    })

    # The following patches implement certain environment variables in GDM which are set by
    # the gdm configuration module (nixos/modules/services/x11/display-managers/gdm.nix).

    # Look for session definition files in the directory specified by GDM_SESSIONS_DIR.
    ./sessions_dir.patch

    # Allow specifying X server arguments with GDM_X_SERVER_EXTRA_ARGS.
    ./gdm-x-session_extra_args.patch

    # Allow specifying a wrapper for running the session command.
    ./gdm-x-session_session-wrapper.patch

    # Forwards certain environment variables to the gdm-x-session child process
    # to ensure that the above two patches actually work.
    ./gdm-session-worker_forward-vars.patch
  ];

  postInstall = ''
    # Prevent “Could not parse desktop file orca-autostart.desktop or it references a not found TryExec binary”
    rm $out/share/gdm/greeter/autostart/orca-autostart.desktop
  '';

  installFlags = [ "sysconfdir=$(out)/etc" "dbusconfdir=$(out)/etc/dbus-1/system.d" ];

  meta = with stdenv.lib; {
    homepage = https://wiki.gnome.org/Projects/GDM;
    description = "A program that manages graphical display servers and handles graphical user logins";
    platforms = platforms.linux;
    maintainers = gnome3.maintainers;
  };
}
