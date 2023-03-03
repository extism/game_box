import { inputJson, outputJson, outputString, getState, setState } from './extism'
 import { Game } from './game'


export function init_game() {
  const config = inputJson()
  const state = new Game({players: config.player_ids})
  setState(state)
  return 0
}

export function get_constraints() {
  const constraints = { min_players: 2, max_players: 8 }
  outputJson(constraints)
  return 0
}

export function render() {
  const assigns = inputJson()
  const game = new Game(getState())
  outputString(game.render(assigns))
  return 0
}

export function handle_event() {
  const event = inputJson()
  const game = new Game(getState())

  const assigns = game.handleEvent(event)
  assigns.version = game.version

  outputJson(assigns)
  setState(game)

  return 0
}
