# GameBox


Work in progress, do not use

## Install

> j**Note**: You need rustup installed

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
# loads the game process and registers as code ABCD
GameBox.Arena.load_game("ABCD", "/Users/ben/d/game_box/games/tictactoe/target/wasm32-unknown-unknown/debug/tictactoe_rs.wasm")

# Calls the init_game function on the arena initializing the game and memory
GameBox.Arena.Server.call("ABCD", {:call, "init_game", ""})
```

Open game at: http://localhost:4000/arena?code=ABCD