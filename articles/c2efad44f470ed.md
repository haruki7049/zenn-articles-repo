---
title: "deno-overlayとかいうやつを作った"
emoji: "💨"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["nix"]
published: false
---

# TL;DR
Deno用のNixオーバーレイを書いた。Nixオーバーレイはいいぞ…！！

# 使いかた
```nix:shell.nix
{
  pkgs ? import <nixpkgs> {
    overlays = [
      (import (builtins.fetchTarball "https://github.com/haruki7049/deno-overlay/archive/11bd3664378343fe6a85e565f8f9b87bd6f2e141.tar.gz"))
    ];
  }
}:

let
  mkShell = pkgs.mkShell;
in

mkShell {
  packages = [
    pkgs.deno."1.44.4"
  ];
}
```
こう書いた後に`shell.nix`があるディレクトリで`nix-shell`コマンドを使用すると、`Deno v1.44.4`がインストールされる。

---

# deno-overlayのソースコードの解説
ここからは、deno-overlayのようなNixオーバーレイを実際に書きたい人向けに、ソースコードの解説をする。以下の順番で解説していく。

1. Nixオーバーレイの基本的な書きかた
2. NixオーバーレイにDerivationを追加する
3. deno-overlayを読み解く

## Nixオーバーレイの基本的な書きかた
> Overlays are Nix functions which accept two arguments, conventionally called final and prev (formerly also self and super), and return a set of packages. ... Overlays are similar to other methods for customizing Nixpkgs, in particular the packageOverrides ... Indeed, packageOverrides acts as an overlay with only the prev (super) argument. It is therefore appropriate for basic use, but overlays are more powerful and easier to distribute.
>> [Nixpkgs manual](https://nixos.org/manual/nixpkgs/stable/#sec-overlays-definition)より

Nixオーバーレイ(オーバーレイと省略する)の実態は、便宜上、`self`と`super`と呼ばれている、二つの引数を必要とし、一つのアトリビュートセットを戻す一つの関数である。

:::details 関数の書きかた
Nixでは関数は以下のように書く。
```nix:足し算関数
first: second: first + second
```
この例だと、この関数の第一引数と第二引数に`2`という整数を与えると、`4`という数字が戻ってくる。
:::

オーバーレイは、二つの引数を必要とし、一つのアトリビュートセットを戻す関数であるから、以下のように書くと、最小のオーバーレイを作成することが可能だ。
```nix:最小のオーバーレイ
self: super: { }
```

## NixオーバーレイにDerivationを追加する
オーバーレイは一つ又は複数のDerivationを戻す関数である事が殆どだ。Derivation自体の解説は本筋から離れるため省略する[^1]。

オーバーレイ内でのDerivationの作成の仕方は、勿論通常のDerivationの作成方法とは違う。というのも、引数にNixpkgsを受け取れないからだ。オーバーレイでのDerivation追加は、`self`と`super`、これら二つの引数を元に作成する。この二つの引数は[公式ドキュメント](https://nixos.org/manual/nixpkgs/stable/#sec-overlays-definition)でも解説されているため、英語が読めるなら是非読んで欲しい。~~そしてNixのプロになって、私の記事の粗探しをしてほしい…~~

```nix:example
self: super:

{
  hello = super.stdenv.mkDerivation rec {
    pname = "hello";
    version = "2.12.1";

    src = super.fetchurl {
      url = "mirror://gnu/hello/hello-${version}.tar.gz";
      sha256 = "sha256-jZkUKv2SV28wsM18tCqNxoCZmLxdYH2Idh9RLibH2yA=";
    };
  };
}
```

[^1]: https://github.com/justinwoo/nix-shorts/blob/master/posts/your-first-derivation.md を参考にすると良いかもしれない。要はDerivationとはビルドの定義をまとめたものである。
