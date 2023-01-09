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


## Game API

Currently, you need to implement 3 functions to make a game. This will change if we try to add support for different types of games:

```
get_constraints(void) -> GameConstraints
init_game(GameConfig) -> void
handle_event(LiveEvent) -> Assigns 
render(Assigns) -> String
```

#### `get_constraints(void) -> GameConstraints`

Called before initializing the game. This gives GameBox some metadata about the constraints of the game. If you do not implement this function it will assume the min and max players are 2.


```rust
#[derive(Deserialize)]
struct GameConstraints {
    min_players: u32,
    max_players: u32,
}
```

#### `init_game(GameConfig) -> void`

`init_game` is called when the players wish to start the game. It should allocate the game state and memory needed.
`GameConfig` currently looks like this and just receives the players needed to start the game.

```rust
#[derive(Deserialize)]
struct GameConfig {
    player_ids: Vec<String>,
}
```

#### `handle_event(LiveEvent) -> Assigns`

`handle_event` is called each time a liveview event is triggered. The LiveView module, for the most part, proxies any
liveview events it receives to your game through this function.

The schema of LiveEvent looks like this right now but will depend on what events your frontend sends:

```rust
#[derive(Deserialize)]
struct CellValue {
    cell: Option<String>,
    value: Option<String>,
}

#[derive(Deserialize)]
struct LiveEvent {
    player_id: String,
    event_name: String,
    value: CellValue,
}
```

For example, if you have a button in your app:
```html
<button phx-click="cell-clicked" phx-value-cell="0" />
```
When someone clicks this, the incoming event will be (psuedo-code):

```rust
LiveEvent {
    player_id: "theirname",
    event_name: "cell-clicked",
    value: CellValue { value: "0"},
}
```

It's up to you to take this event and alter the game state. You should think of your game like a big state machine that receives these events and updates the state until some state transition happens and the rules change. 

From this function, you can return `Assigns`. Assigns can be whatever type you want it to be. The engine will attach this map to the user's socket and will later be passed back to you in render. Assigns should contain a `version` field which is an incrementing integer. This should be incremented when the game needs to be updated on all sockets. These properties should also only be rendered selectively when you want to change something but version is always needed. We should have a better solution for this in the future.

This function can also return an error and when it does, that error will be put on the user's socket at `flash[:error]` and render the error no their screen. this is good for validation.

#### `render(Assigns) -> String`

`render` is called each time the game board needs to be rendered. It's called for each user watching or playing the game. You can render the game depending on who is viewing it by attaching metadata to the user's socket with Assigns. The assigns for the user are passed back to you here. For example, you will render the game differently based on who's turn it is and which screen it's being rendered on. You also probably want to render game for non players without the control elements.

### Reference

Currently the [tictactoe game in rust](games/tictactoe/) is the canonical example of a game.