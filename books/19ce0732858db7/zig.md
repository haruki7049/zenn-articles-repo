---
title: "Zig言語とHook"
---

# Zig言語とHook

## Hook

`nixpkgs`には`Hook`と呼ばれるセットアップ作業を簡便にするツールがある。Hookは、一般的なタスクを一つのシェルスクリプトにまとめる目的で作られた。Hookの場合、別の関数を使用するようなことは無いが、`stdenv.mkDerivation`内の`nativeBuildInputs`アトリビュートの値を、使用するHookをまとめたリスト形式にする必要がある。
今回の題材にもなっている、`zig.hook`は以下のように使用する。
```nix
{
  pkgs ? import <nixpkgs> { },
}:

pkgs.stdenv.mkDerivation {
  pname = "test-zig";
  version = "0.1.0";
  src = ./.;

  nativeBuildInputs = [
    pkgs.zig.hook
  ];

  zigBuildFlags = [
    "-Dman-pages=true"
  ];

  dontUseZigCheck = true;
}
```

もしも`cmake`を使用したい場合は、この通り書けばビルドできるだろう。
```nix
# Run this command in Bash, `nix-build -E 'with import <nixpkgs> { }; callPackage ./default.nix { }'`
{
  stdenv,
  cmake,
}:

stdenv.mkDerivation {
  pname = "test-cmake";
  version = "0.1.0";
  src = ./.;

  nativeBuildInputs = [
    cmake
    # You can comment out below if you want to use ninja instead gnumake!!
    #ninja
  ];

  cmakeBuildType = "Debug";

  #cmakeFlags = [
  #  "-DFOOFOO=on"
  #];
}
```
