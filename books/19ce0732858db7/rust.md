---
title: "Rust言語とビルダー関数"
---

# Rust言語とビルダー関数

## ビルダー関数

`nixpkgs`では、各言語ごとにDerivationを作るための関数が存在する。Dart言語だと`buildDartApplication`、Nim言語だと`buildNimPackage`が挙げられる。これらビルダー関数は、`stdenv.mkDerivation`などの`Derivation`を作成する関数のラッパーとなっていて、プログラミング言語ごとに、Nix式を短く書くために用意されている。

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

## ビルダー関数の実態

ビルダー関数は`stdenv.mkDerivation`等の関数のラッパーだとは話したが、具体的にどのようにそれを実現しているのだろうか。nixpkgs内の[/pkgs/build-support/rust/build-rust-package/default.nix](https://github.com/NixOS/nixpkgs/blob/8c4dc69b9732f6bbe826b5fbb32184987520ff26/pkgs/build-support/rust/build-rust-package/default.nix)に、Rust言語用のビルダー関数、`buildRustPackage`が書かれていたが、私が読んでみたところかなり複雑であった。そこで、私が作った[Janet-lang](https://janet-lang.org)用のビルダー関数、[buildJanetPackage](https://github.com/haruki7049/buildJanetPackage/tree/0.1.0)を見てみよう。

## buildJanetPackage

[buildJanetPackage](https://github.com/haruki7049/buildJanetPackage/tree/0.1.0)での`buildJanetPackage`関数の実態は、[/lib/buildJanetPackage.nix](https://github.com/haruki7049/buildJanetPackage/blob/0.1.0/lib/buildJanetPackage.nix)に書かれている。以下に記載。

```nix
# /lib/buildJanetPackage.nix

{ pkgs }:

let
  stdenv = pkgs.stdenv;
in
{
  buildJanetPackage =
    { pname
    , version
    , src
    }:
    stdenv.mkDerivation {
      inherit pname version src;

      buildInputs = [
        pkgs.janet
        pkgs.jpm
      ];

      JANET_LIBPATH = "${pkgs.janet}/lib";

      buildPhase = ''
        jpm build
      '';

      installPhase = ''
        mkdir -p $out/bin
        install -m755 build/${pname} $out/bin/${pname}-${version}
      '';
    };
}
```

これを見ていただけるとわかる通り、buildJanetPackage関数は「pnameとversionとsrcを引数に取り`stdenv.mkDerivation`を使用してDerivationを返す関数」である。

> ちなみに、この`/lib/buildJanetPackage.nix`自体は`/default.nix`内の記述、`pkgs.callPackage ./lib/buildJanetPackage.nix { inherit pkgs; }`によって呼び出されている。
>> 今この文章を書いていて思ったことが二点ある。なぜこやつは`pkgs.callPackage`を使用しているのに、引数に`pkgs`を渡しているのかと、それに`pkgs.callPackage`を使用するならば、`/lib/buildJanetPackage.nix`で受け取るものも、`stdenv`を直接受けとれば良いのにということだ。

