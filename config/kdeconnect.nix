{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
}:
stdenvNoCC.mkDerivation rec {
  pname = "kdeconnect";
  version = "4991";

  src = fetchurl {
    url = "https://cdn.kde.org/ci-builds/network/kdeconnect-kde/master/macos-arm64/kdeconnect-kde-master-${version}-macos-clang-arm64.dmg";
    sha256 = "sha256-975bl9JFgCRao05vMwVTV/2EC2zLdH9LAeb6gBY6kBw=";
  };

  sourceRoot = "KDE Connect.app";

  nativeBuildInputs = [undmg];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications/KDE Connect.app"
    cp -R . "$out/Applications/KDE Connect.app"

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
