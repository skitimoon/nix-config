{
  pkgs,
  inputs,
  ...
}: {
  programs.opencode = {
    enable = true;
    package = inputs.llm-agents.packages.${pkgs.system}.opencode;
    settings.plugin = ["@dietrichgebert/ponytail"];
  };
}
