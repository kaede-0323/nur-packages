{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  formats,
  kdePackages,
  themeConfig ? null,
}: let
  userConfig = (formats.ini {}).generate "vitreous.conf.user" {General = themeConfig;};
  themeDir = "$out/share/sddm/themes/vitreous";
in
  stdenvNoCC.mkDerivation {
    pname = "sddm-vitreous";
    version = "0-unstable-2025-09-03";

    # 作者は sane1090x から saneaspect に改名済み。旧 URL はリダイレクトされる
    src = fetchFromGitHub {
      owner = "saneaspect";
      repo = "vitreous";
      rev = "972728cdb71b5782c384c80611d339736f8d1c27";
      hash = "sha256-eUTa05U0A6ukRRH0BFoDfNgD2/YVQxJR+kPQ9IrL8/Y=";
    };

    patches = [
      # 天気表示は外部スクリプトが書く /run/sddm-weather.txt を前提とするため削除する
      ./no-weather.patch
      # 時刻・日付のフォントは QML 直書きなのでテーマ設定から差し替えられるようにする
      ./themable-fonts.patch
      # 上流の Screen.ScreenWidth は存在しないプロパティ
      ./fix-screen-width.patch
    ];

    dontWrapQtApps = true;

    # greeter の QML import path に載せる。.dev の伝播を避けるため .out を指定する
    propagatedBuildInputs = with kdePackages; [
      qtsvg.out
      qtmultimedia.out
    ];

    installPhase =
      ''
        runHook preInstall

        mkdir -p ${themeDir}
        cp -r ./* ${themeDir}
        chmod -R u+w ${themeDir}
      ''
      + lib.optionalString (themeConfig != null) ''
        ln -sf ${userConfig} ${themeDir}/Configs/vitreous.conf.user
      ''
      + ''
        runHook postInstall
      '';

    meta = {
      description = "Material Design-inspired SDDM theme";
      homepage = "https://github.com/saneaspect/vitreous";
      license = lib.licenses.gpl3Plus;
      platforms = lib.platforms.linux;
    };
  }
