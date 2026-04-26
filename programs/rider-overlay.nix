final: prev: {
  jetbrains =
    prev.jetbrains
    // {
      rider = prev.jetbrains.rider.overrideAttrs (oldAttrs: rec {
        version = "2023.2.2";
        src = prev.fetchurl {
          url = "https://download.jetbrains.com/rider/JetBrains.Rider-2023.2.2.tar.gz";
          sha256 = "oystBoJhPzr6zRHqwaefAiyZ4X75qyP+JsXY00sJOtg=";
        };
      });
    };
}
