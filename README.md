# GameBox

This repo houses GameBox. Details can be found in this 2 part blog post:

https://extism.org/blog/extending-fly-io-distributed-game-system-part-1

This is currently a proof of concept and we are working on making this something we can deploy.
If you have Elixir or Phoenix knowledge, we'd love your help! Come join us in [Discord](https://discord.gg/cx3usBCWnc). Stop by the `#elixir-sdk` room.


I've been working on a [tictactoe game in rust](games/tictactoe/) to figure out what the game API will be and how to best integrate with LiveView:

<video src="https://user-images.githubusercontent.com/185919/206291522-86aed4cf-13b6-4757-a400-4e3c7dafb57f.mp4"></video>

If you're interested in writing any games, we'd love to have one in another language like Go or Assemblyscript, or Haskell.

## Install

> **Note**: You need rustup installed

```
mix do deps.get, compile
```

## Compile games:

I'll have some scripts for this soon. Right now run this:

```
cd games/tictactoe
cargo build --target wasm32-unknown-unknown
```

> **Note**: Use `--release` for a smaller build to upload to the prod gamebox site

## Running

You might need to do this first
```
cd assets
npm instal
cd ..
```

Run with iex so you can manipulate the game state in repl:


```
iex -S mix phx.server
```

Open game at: http://localhost:4000/
