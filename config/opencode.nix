{
  pkgs,
  inputs,
  ...
}: {
  programs.opencode = {
    enable = true;
    package = inputs.llm-agents.packages.${pkgs.system}.opencode2;
    settings.plugin = ["@dietrichgebert/ponytail"];
  };
}
