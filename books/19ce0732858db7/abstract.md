---
title: "概要"
---

# 概要

## 始めに

Nixを使用してDerivationを作成するときには、大抵`stdenv.mkDerivation`関数を使用する場合が多いと思う。そうして`stdenv.mkDerivation`関数を使用する時、よく分からないままに、`nativeBuildInputs`アトリビュートに`pkgs.pkg-config`や`pkgs.cmake`などのDerivationを加えた経験がある人もいるのではないだろうか。

簡単に言うと、この`pkgs.cmake`や`pkgs.pkg-config`を`nativeBuildInputs`アトリビュートに加えると、それらは`Hook`として働くようになる。この`Hook`が動作することによって、Nix式の中でCmakeのコマンドライン引数を指定せずとも、デフォルトの設定で良い感じに動かすことができるのだ。

それとは別に、`pkgs.rustPlatform.buildRustPackage`や`pkgs.perlPackages.buildPerlPackage`などの関数でDerivationを作成した経験がある人もいるのではないだろうか。これらは、[Nixpkgs manual stable](https://nixos.org/manual/nixpkgs/stable/)にて、`Language- or framework-specific build helpers`、和訳すると`言語またはフレームワーク固有のビルドヘルパー`という風に、ビルドヘルパーの一種であると書かれている。
今回、この本では`言語またはフレームワーク固有のビルドヘルパー`は簡単のため、`ビルダー関数`と呼ぶ。

この本では、ここまでで話した`Hook`と`ビルダー関数`について深掘りしていく。`Hook`を使用する言語として`Zig言語`、ビルダー関数を使用する言語として`Rust言語`をこの本では使用していく。よくある話として、`Zig言語 vs Rust言語`という話があるが、この本は`Zig言語`と`Rust言語`のどちらが優秀かを議論する本ではなく、単にNixでのDerivationの作り方の違いを挙げる本であることをご留意いただきたい。

それらとは別に、それぞれのチャプターの最後に、簡単な`Hook`や`ビルダー関数`の作り方を書いておくので、参考にしてほしい。

検証環境を以下に書く。この本で参照している`nixpkgs`のコミットハッシュは、`nixpkgs-unstable`ブランチの[8c4dc69](https://github.com/NixOS/nixpkgs/commit/8c4dc69b9732f6bbe826b5fbb32184987520ff26)を使用している。
```txt
 - system: `"aarch64-darwin"`
 - host os: `Darwin 24.1.0, macOS 15.1`
 - multi-user?: `yes`
 - sandbox: `no`
 - version: `nix-env (Nix) 2.18.2`
 - channels(root): `"nixpkgs"`
 - nixpkgs: `/nix/store/63lvc59rjz075kb1f11xww2x2xqpw1pn-source`
```

この本の内容で、間違っている点や誤字脱字などがあったら、GitHubにあるリポジトリ、[haruki7049/zenn-articles-repo](https://github.com/haruki7049/zenn-articles-repo)にイシューかプルリクエストを立てていただくか、私のメールアドレスにその旨の電子メールを送ってくれると幸いだ。私のメールアドレスは、[github.com/haruki7049](https://github.com/haruki7049)に載っているので確認いただきたい。
