{fetchFromGitHub, stdenv, cmake, boost, zlib, curl, git, openzwave, libudev, pkgconfig}:

stdenv.mkDerivation {
  name = "domoticz-3.5837";

  src = fetchFromGitHub {
    owner = "domoticz";
    repo = "domoticz";
    rev = "591a66972a7154044f0e030e1da84d5f1952cb01";
    sha256 = "0h6lc3hg5ha0g4q91v1q23hsa67kyr3r0x2ag5k0rdxkv8k9fdf8";
  };

  buildInputs = [ cmake boost zlib curl git openzwave libudev pkgconfig ];

  cmakeFlags = [ "-DUSE_STATIC_BOOST=NO" "-DUSE_STATIC_OPENZWAVE=NO" ];
}
