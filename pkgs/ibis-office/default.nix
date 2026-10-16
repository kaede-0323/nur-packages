{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  fontconfig,
  freetype,
  libxkbcommon,
  libxcb,
  libx11,
  libxcursor,
  libxi,
  wayland,
  vulkan-loader,
  libglvnd,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ibis-office";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "ibisjp";
    repo = "ibis-office";
    rev = "v${finalAttrs.version}";
    hash = "sha256-L5WJUZ8pSo2TDZzbBomempLmW5M1zzxMfi9zEe7XRhw=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-J79JMi+pehPKt6qMw0zQDGFYRQPo2ExV8l/NcGLFrSY=";

  postPatch = ''
    substituteInPlace crates/ibis-office-app/build.rs \
      --replace-fail '("macos", _) => "macOS",' '("macos", _) => "macOS", ("linux", _) => "Linux",'
    printf 'Linux\t%s\n' ${finalAttrs.version} >> version.txt
    cat >> crates/ibis-office-app/Cargo.toml <<'EOF'

    [target.'cfg(target_os = "linux")'.dependencies]
    image = { version = "0.25", default-features = false, features = ["png", "gif", "jpeg"], optional = true }
    EOF
  '';

  cargoBuildFlags = [
    "--package=ibis-office-app"
    "--bin=ibisOffice"
  ];

  # 7万件の描画比較をスキップする
  doCheck = false;

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = [
    fontconfig
    freetype
    libxkbcommon
    libxcb
    wayland
  ];

  postFixup = ''
    wrapProgram $out/bin/ibisOffice \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
      vulkan-loader
      libglvnd
      wayland
      libxkbcommon
      libx11
      libxcursor
      libxi
      libxcb
    ]}
  '';

  postInstall = ''
    install -Dm644 asset/ibisOffice_svg_logo_for_light.svg $out/share/icons/hicolor/scalable/apps/ibis-office.svg
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "ibis-office";
      desktopName = "ibisOffice";
      comment = finalAttrs.meta.description;
      exec = "ibisOffice %f";
      icon = "ibis-office";
      categories = ["Office"];
      mimeTypes = [
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        "application/vnd.ms-word.document.macroEnabled.12"
        "application/vnd.ms-excel.sheet.macroEnabled.12"
        "application/vnd.ms-powerpoint.presentation.macroEnabled.12"
      ];
    })
  ];

  meta = {
    description = "Office suite for DOCX, XLSX and PPTX built with Rust and GPUI";
    homepage = "https://github.com/ibisjp/ibis-office";
    license = lib.licenses.agpl3Only;
    mainProgram = "ibisOffice";
    platforms = lib.platforms.linux;
  };
})
