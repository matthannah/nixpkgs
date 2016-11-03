{fetchurl, stdenv, libudev, which, makeWrapper}:

stdenv.mkDerivation {
  name = "openzwave-1.4.164";

  src = fetchurl {
    url = http://old.openzwave.com/downloads/openzwave-1.4.164.tar.gz;
    sha256 = "0sdcq3915w61l2sfmbvwwm60j9mw3mc9n1k46wh8q9xgg9w3kksf";
  };

  buildInputs = [ libudev which makeWrapper ];

  installPhase = ''
    export pkgconfigdir=$prefix/lib/pkgconfig
    mkdir -p $pkgconfigdir
    PREFIX=$prefix make install
    # Docs are broken, remove them
    rm -r $out/share/doc
    rmdir $out/share
    wrapProgram $out/bin/ozw_config --add-flags "--with-pc $pkgconfigdir/libopenzwave.pc"
  '';
}
