let
  me = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzxqVZzqKSoeTpCUb8L3qUjtLIi5GCwWjP1qixH/2hW";
in {
  "ssh-host-1.age".publicKeys = [me];
}
