{
  lib,
  stdenvNoCC,
  fetchzip,
}:
stdenvNoCC.mkDerivation rec {
  pname = "open-stage-control";
  version = "1.29.2";

  src = fetchzip {
    url = "https://github.com/jean-emmanuel/open-stage-control/releases/download/v${version}/open-stage-control_${version}_osx-x64.zip";
    sha256 = "sha256-VWv8lw+xnVSIYbzAEioN518lhTacF7GbQ7d2oTSJ0C4=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications/open-stage-control.app
    cd open-stage-control.app
    cp -R . $out/Applications/open-stage-control.app

    runHook postInstall
  '';

  meta = {
    description = "Open Stage Control";
    homepage = "https://github.com/jean-emmanuel/open-stage-control";
    sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    platforms = lib.platforms.darwin;
    license = lib.licenses.mit;
  };
}
