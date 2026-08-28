# Harlequin with the Databricks adapter. nixpkgs only wires up the Postgres and
# BigQuery adapters, and harlequin-databricks is not in nixpkgs at all, so the
# adapter is built from its PyPI sdist and injected into harlequin's Python
# environment. Adapters are entry-point plugins, so being in the same
# site-packages is all harlequin needs to discover them.
{
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    py = pkgs.python3Packages;

    harlequin-databricks = py.buildPythonPackage rec {
      pname = "harlequin-databricks";
      version = "0.6.4";
      pyproject = true;

      src = pkgs.fetchPypi {
        pname = "harlequin_databricks";
        inherit version;
        hash = "sha256-0cRaxt/6ymwzebozkAM7taoa94bVM8R8eFdN+9RYOLk=";
      };

      build-system = [py.uv-build];

      # harlequin is the host application, not a dependency of the adapter here;
      # depending on it would pull a second copy into the final environment.
      pythonRemoveDeps = ["harlequin"];

      dependencies = [
        py.databricks-sql-connector
        # `databricks-sdk` extra: needed for the OAuth / CLI-profile auth paths.
        py.databricks-sdk
      ];

      # The adapter imports `harlequin` at module load, so it cannot be
      # import-checked standalone; the wrapped harlequin below does it instead.
      dontUsePythonImportsCheck = true;
      doCheck = false;

      meta = {
        description = "Harlequin adapter for Databricks";
        homepage = "https://github.com/alexmalins/harlequin-databricks";
        license = lib.licenses.mit;
      };
    };
  in {
    packages = {
      inherit harlequin-databricks;

      harlequin = pkgs.harlequin.overridePythonAttrs (old: {
        dependencies = old.dependencies ++ [harlequin-databricks];
        pythonImportsCheck = old.pythonImportsCheck ++ ["harlequin_databricks"];
      });
    };
  };
}
