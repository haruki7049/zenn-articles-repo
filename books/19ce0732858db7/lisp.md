---
title: "CommonLispとNix"
---

# CommonLispのパッケージシステム

CommonLispではASDF(Another System Definition Facility)がデファクトスタンダードで使用されており、Nixでパッケージングする際にもASDFを使用する。

```nix
{
  sbcl,
  sbclPackages,
}:

sbcl.buildASDFSystem {
  pname = "example";
  version = "0.1.0";
  src = lib.cleanSource ./.;
  lispLibs = with sbclPackages; [
    woo
  ];
}
```
