function setstate(state) {
  Var.set('state', JSON.stringify(state))
}

function getstate() {
  return JSON.parse(Var.getString('state'))
}

function init_game() {
  const game_config = JSON.parse(Host.inputString())
  const state = {
    player_ids: game_config.player_ids,
    events: [],
    version: 0,
  }
  setstate(state)
  return 0
}

function handle_event() {
  const event = JSON.parse(Host.inputString())
  const state = getstate()
  state.events.push(event)
  state.version += 1
  setstate(state)
  Host.outputString(JSON.stringify(state))
  return 0
}

function ui(state, assigns) {
  const version = `<h1>Version: ${state.version}</h1>`
  const youare = `<h1>You are ${assigns.player_id}`
  const button = `<button phx-click="cell-clicked" phx-value-cell="0">Click me</button>`
  const events = state.events.map(e => `<li>${JSON.stringify(e)}</li>`)

  return `${version} ${youare} ${button} ${events}`
}

function render() {
  const assigns = JSON.parse(Host.inputString())
  Host.outputString(ui(getstate(), assigns))
  return 0
}

function get_constraints() {
  const constraints ={
    min_players: 2,
    max_players: 2,
  }
  Host.outputString(JSON.stringify(constraints))
}

module.exports = {
  init_game,
  handle_event,
  render,
  get_constraints,
}
