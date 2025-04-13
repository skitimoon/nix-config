{
  lib,
  stdenvNoCC,
  fetchzip,
}:
stdenvNoCC.mkDerivation rec {
  pname = "popcorn-time";
  version = "0.5.1";

  src = fetchzip {
    url = "https://github.com/popcorn-official/popcorn-desktop/releases/download/v${version}/Popcorn-Time-${version}-osxarm64.zip";
    sha256 = "sha256-0AUSfXE3/lmK9wRgz5mrMg9YVqngqHjvS3AniapJCQY=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications/Popcorn-Time.app
    cp -R . $out/Applications/Popcorn-Time.app

    runHook postInstall
  '';

  meta = {
    description = "Popcorn Time";
    homepage = "https://github.com/popcorn-official/popcorn-desktop";
    sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    platforms = lib.platforms.darwin;
    license = lib.licenses.mit;
  };
}
