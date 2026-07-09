{
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    packages.siggy = pkgs.rustPlatform.buildRustPackage rec {
      pname = "siggy";
      version = "1.14.0";

      src = pkgs.fetchFromGitHub {
        owner = "johnsideserf";
        repo = "siggy";
        rev = "v${version}";
        hash = "sha256-CWmkXMWUma1Q2fRewrkvKhiYuvJQyetZsVG5rD/xrfM=";
      };

      cargoHash = "sha256-Q6BVFK2Y0CKL+ZQXmBagRURvnEP3sG4ZoVfLzVB+Wb4=";

      meta = {
        description = "Terminal-based Signal messenger client with vim keybindings";
        homepage = "https://github.com/johnsideserf/siggy";
        license = pkgs.lib.licenses.gpl3Only;
        mainProgram = "siggy";
        maintainers = with pkgs.lib.maintainers; [];
      };
    };
  };
}
