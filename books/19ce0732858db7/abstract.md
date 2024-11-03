---
title: "概要"
---

## ビルダー関数とHook

`nixpkgs`では、各言語ごとにDerivationを作るための関数が存在する。Dart言語だと`buildDartApplication`、Nim言語だと`buildNimPackage`が挙げられる。これらをこの本ではビルダー関数と呼ぶ。[^1] これらビルダー関数は、`stdenv.mkDerivation`などの`Derivation`を作成する関数のラッパーとなっていて、プログラミング言語ごとに、Nix式を短く書くために用意されている。

```nix
{
  # Import nixpkgs to bind `pkgs` variables
  pkgs = import <nixpkgs> { },
}:

# Call builder function!!
pkgs.rustPlatform.buildRustPackage {
  pname = "test-rust";
  version = "0.1.0";
  src = ./.;

  cargoLock.lockFile = ./Cargo.lock;
}
```

> Nix式を見ていると、稀に以下のように、引数のアトリビュートセット内で値が定義されないまま式が書かれている時があると思う。
> ```nix
> # File name: default.nix
> {
>   buildDartApplication,
> }:
>
> rustPlatform.buildRustPackage {
>   pname = "foofoo";
>   version = "0.1.0";
>   src = ./.;
>   cargoLock.lockFile = ./Cargo.lock;
> }
> ```
> このように書かれていた場合、`nix-build -E 'with import <nixpkgs> { }; callPackage ./default.nix { }'`というようなコマンドを実行すると良い。
> 1. `nix-build -E` -> コマンドライン引数を、Nix式のファイル名のリストとしてではなく、評価されるNix式のリストとして解釈する。
> 1. `'with import <nixpkgs> { }; callPackage ./default.nix { }'` -> nixpkgsを`import関数`によって評価して、その中の`callPackage関数`を使用する。`callPackage ./default.nix { }`の第一引数として与えられている`./default.nix`を変更して、評価するNixファイルを変更する。

[^1]: https://nixos.org/manual/nixpkgs/stable/#chap-language-support

---

一方、`nixpkgs`には`Hook`と呼ばれるセットアップ作業を簡便にするツールがある。Hookは、一般的なタスクを一つのシェルスクリプトにまとめる目的で作られた。Hookの場合、別の関数を使用するようなことは無いが、`stdenv.mkDerivation`内の`nativeBuildInputs`アトリビュートの値を、使用するHookをまとめたリスト形式にする必要がある。
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
