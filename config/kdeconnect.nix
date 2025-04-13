{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
}:
stdenvNoCC.mkDerivation rec {
  pname = "kdeconnect";
  version = "4921";

  src = fetchurl {
    url = "https://cdn.kde.org/ci-builds/network/kdeconnect-kde/master/macos-arm64/kdeconnect-kde-master-${version}-macos-clang-arm64.dmg";
    sha256 = "sha256-jMC3ApFuVppOfWmdJxAl60MrzOoBHggDP5MzNwIKqYs=";
  };

  sourceRoot = "kdeconnect-indicator.app";

  nativeBuildInputs = [undmg];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications/kdeconnect-indicator.app
    cp -R . $out/Applications/kdeconnect-indicator.app

    runHook postInstall
  '';

  meta = {
    description = "KDE connect";
    homepage = "https://kdeconnect.kde.org/";
    sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    platforms = lib.platforms.darwin;
    license = lib.licenses.mit;
  };
}
