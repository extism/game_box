# Trivia

A trivia game written in TypeScript

Compile:

```
npm install
npm run build
```

Extism plugin will compile to dist/plugin.wasm 

To query for questions use the opentriviadb api: https://opentdb.com/api_config.php

Pass the querystring to the trivia.rb program and pipe it to data.json:

```
ruby trivia.rb "amount=10&difficulty=medium&type=multiple" > src/data.json
```

