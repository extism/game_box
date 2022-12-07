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

## Running

Run with iex so you can manipulate the game state in repl:

```
iex -S mix phx.server
```

To load and initialize a game at a specific 4 letter room code, run this in the iex repl:

```
# registers code name and starts process
GameBox.Arena.Server.start_link("ABCD") 

# loads the game process
GameBox.Arena.load_game("ABCD", "/Users/ben/d/game_box/games/tictactoe/target/wasm32-unknown-unknown/debug/tictactoe_rs.wasm")

# Calls the init_game function on the arena initializing the game and memory
GameBox.Arena.Server.call("ABCD", {:call, "init_game", JSON.encode!(%{player_ids: ["benjamin", "brian"]})})
```

Open game at: http://localhost:4000/arena?code=ABCD
