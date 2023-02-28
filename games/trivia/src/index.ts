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
  outputJson(constraints)
  return 0
}

export function render(): number {
  const assigns: Assigns = inputJson()
  const game = new Game(getState())
  outputString(game.render(assigns))
  return 0
}

export function handle_event(): number {
  const event: LiveEvent = inputJson()
  const game = new Game(getState())

  const assigns = game.handleEvent(event)
  assigns.version = game.version

  outputJson(assigns)
  setState(game)

  return 0
}
