# Punderplay

### build

Install [`zigmod`](https://github.com/nektro/zigmod#download) and run:

```sh
# from the `punderplay` directory
zigmod fetch
zig build
# use ./zig-out/bin/punderplay.wasm
```

### Testing

Run unit tests via: 
```sh
zig build test-game
zig build test-store
```

Execute functions in the game:

```sh
# currently this just echoes out the input after deserializing & reserializing
extism call zig-out/bin/punderplay.wasm init_game --input '{"player_ids": ["steve", "ben"]}' | jq .
```