{fetchFromGitHub, stdenv, cmake, boost, zlib, curl, git, openzwave, libudev, pkgconfig}:

stdenv.mkDerivation {
  name = "domoticz-3.5877";

  src = fetchFromGitHub {
    owner = "domoticz";
    repo = "domoticz";
    rev = "6fdf902ea89c835a338c9aadcf8dd26c4b7a6242";
    sha256 = "0k27qq5vibyjm323kggy7zl4wkqby3w5b6zi5sip1mk7fnknmjjs";
  };

  buildInputs = [ cmake boost zlib curl git openzwave libudev pkgconfig ];

  cmakeFlags = [ "-DUSE_STATIC_BOOST=NO" "-DUSE_STATIC_OPENZWAVE=NO" ];
}
