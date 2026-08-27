{
  config,
  inputs,
  mkExtras,
  ...
}:
import ../../lib/mk-darwin.nix {
  inherit config inputs mkExtras;
  machine = "work";
  hostname = "tm-macbook-pro";
}
