import { inputJson, outputJson, outputString, getState, setState } from './extism'
import { Game, Assigns, LiveEvent } from './game'

interface GameConfig {
  player_ids: Array<string>,
}

export function init_game(): number {
  const config: GameConfig = inputJson()
  const state = new Game({players: config.player_ids})
  setState(state)
  return 0
}

interface GameConstraints {
  max_players: number,
  min_players: number,
}

export function get_constraints(): number {
  const constraints: GameConstraints = { min_players: 2, max_players: 8 }
  console.log("get constraints")
  console.log(JSON.stringify(constraints))
  outputJson(constraints)
  return 0
}

export function render(): number {
  const assigns: Assigns = inputJson()
  console.log("Render: ")
  console.log(JSON.stringify(assigns))
  const game = new Game(getState())
  //const game = new Game({players: ["ben", "steve"], state: {name: "prompting", questionIndex: 0, answers: {"steve": 0}}})
  console.log(JSON.stringify(game))
  //const game = new Game(["steve", "ben"])
  outputString(game.render(assigns))
  return 0
}

export function handle_event(): number {
  const event: LiveEvent = inputJson()
  const game = new Game(getState())
  //const game = new Game({players: ["ben", "steve"]})
  console.log("event: ")
  console.log(JSON.stringify(event))
  console.log(JSON.stringify(game))

  const assigns = game.handleEvent(event)
  assigns.version = game.version
  console.log(JSON.stringify(assigns))

  console.log(JSON.stringify(game))
  outputJson(assigns)
  setState(game)

  return 0
}
