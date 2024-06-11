---
title: "{Any-Languages} & Nix"
emoji: "👌"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["nix", "rust", "commonlisp", "bun"]
published: false
---

# この記事での目的

- 「Nixはいいぞ」
- 「実は色んな開発に流用出来るパッケージマネージャーなんだという事を言いたい」
- 「Nix×Rust尊い」
- 「みんなもプログラミング言語カップリングを好これ」

# Nix×Rust

NixとRust言語で簡単なウェブサーバーを、**継続的CIと共に**簡単に実装してみよう。ひとまず、Nix側ではOld-Nix(Nix-Flakesでない、レガシーなNixの事)を使用し、Rust側ではAxumを使用して書く。

まずは簡単に[axum](https://github.com/tokio-rs/axum)を使用してウェブサーバーを書く。この部分の解説は他の書物に譲る。

```rust:src/main.rs
use axum::{routing::get, Router};

const IP_ADDRESS: &str = "127.0.0.1:8888";

#[tokio::main]
async fn main() {
    let app = Router::new().route("/", get(hello));

    let listener = tokio::net::TcpListener::bind(IP_ADDRESS).await.unwrap();

    println!("Server is up on {}...", IP_ADDRESS);
    axum::serve(listener, app).await.unwrap();
}

async fn hello() -> &'static str {
    "Hello, with Nix!!"
}
```

そしてNixを書く。今回はNixを用いてRustのバージョン管理とフォーマッタの作成、勿論Nixでのパッケージングもする。今回用意するファイルは、`default.nix`と`treefmt.nix`、そして`rust-toolchain.toml`だ。

最後に挙げたファイルはNixでは無いが、このファイルはNixからも勿論読む事が出来る。そのために、非Nixユーザーからもこのプロジェクトにアクセスが容易になる。

ファイルを用意したら書いていこう。まずは`default.nix`だ。

```nix:default.nix
{ rust_overlay ? import (builtins.fetchTarball https://github.com/oxalica/rust-overlay/archive/8ef3f6a8f5af867ab5f75fc86fbd934a6351820b.tar.gz)
, crane ? import (builtins.fetchTarball https://github.com/ipetkov/crane/archive/19ca94ec2d288de334ae932107816b4a97736cd8.tar.gz) { }
, pkgs ? import (builtins.fetchTarball https://github.com/NixOS/nixpkgs/archive/057f9aecfb71c4437d2b27d3323df7f93c010b7e.tar.gz) {
    overlays = [
      rust_overlay
    ];
  }
, rust ? pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml
}:

crane.buildPackage rec {
  src = ./.;
  doCheck = true;
}
```
