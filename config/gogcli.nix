{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "gogcli";
  version = "0.12.0";

  src =
    if stdenvNoCC.hostPlatform.system == "x86_64-linux"
    then
      fetchurl {
        url = "https://github.com/steipete/gogcli/releases/download/v${finalAttrs.version}/gogcli_${finalAttrs.version}_linux_amd64.tar.gz";
        sha256 = "sha256-oD/MvWfqLlmialbpLeiRhXf0vr5LL5RoI0GXd4J82rI=";
      }
    else if stdenvNoCC.hostPlatform.system == "aarch64-linux"
    then
      fetchurl {
        url = "https://github.com/steipete/gogcli/releases/download/v${finalAttrs.version}/gogcli_${finalAttrs.version}_linux_arm64.tar.gz";
        sha256 = "sha256-1/IElNfrDocWYxhT0FXMuzaMe4HLgWX1W0WIS8y2e0s=";
      }
    else throw "Unsupported system for gogcli: ${stdenvNoCC.hostPlatform.system}";

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm755 gog $out/bin/gog
    ln -s $out/bin/gog $out/bin/gogcli

    install -Dm644 README.md $out/share/doc/gogcli/README.md
    install -Dm644 CHANGELOG.md $out/share/doc/gogcli/CHANGELOG.md
    install -Dm644 LICENSE $out/share/licenses/gogcli/LICENSE

    runHook postInstall
  '';

  meta = {
    description = "Google in your terminal";
    homepage = "https://github.com/steipete/gogcli";
    changelog = "https://github.com/steipete/gogcli/releases/tag/v${finalAttrs.version}";
    sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    platforms = lib.platforms.linux;
    license = lib.licenses.mit;
    mainProgram = "gog";
  };
})
