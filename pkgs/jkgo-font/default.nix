{
  lib,
  stdenv,
  fetchurl,
  unzip,
}:
stdenv.mkDerivation rec {
  pname = "jk-go";
  version = "1.00";

  src = fetchurl {
    url = "https://font.cutegirl.jp/wp-content/uploads/2015/08/jk-go-l-1.zip";
    sha256 = "sha256-oLqa8Xdu6lS2E9KmX0pDOt2RIur1jMYJr2Qz7Lbw8Xg=";
  };

  nativeBuildInputs = [unzip];

  installPhase = ''
    mkdir -p $out/share/fonts/truetype/jk-go-l-1
    unzip $src -d jk-go
    cp jk-go/jk-go-l-1.00/JKG-L_3.ttf $out/share/fonts/truetype/
  '';

  meta = {
    description = "JK Gothic L, a Japanese font with cute original kana on top of M+ FONTS";
    homepage = "https://font.cutegirl.jp/jk-font-light.html";
    license = [
      lib.licenses.mplus
      # The kana carry only a usage grant, with no permission to redistribute
      {
        fullName = "JK FONTS terms of use";
        url = "https://font.cutegirl.jp/jk-font-light.html";
        free = false;
        redistributable = false;
      }
    ];
    platforms = lib.platforms.all;
  };
}
