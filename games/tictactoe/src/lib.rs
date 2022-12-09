mod game;

use crate::game::*;
use extism_pdk::*;
use serde::{Deserialize};

#[derive(Deserialize)]
struct GameConfig {
    player_ids: Vec<String>,
}

#[plugin_fn]
pub fn init_game(Json(conf): Json<GameConfig>) -> FnResult<()> {
    let game_state = Game::new(conf.player_ids);
    game_state.save()?;
    Ok(())
}

#[derive(Deserialize)]
struct CellValue {
    cell: String,
    value: String,
}

#[derive(Deserialize)]
struct LiveEvent {
    player_id: String,
    event_name: String,
    code: String,
    value: CellValue,
}

#[plugin_fn]
pub fn handle_event(Json(event): Json<LiveEvent>) -> FnResult<Json<Assigns>> {
    let mut game_state = Game::load()?;
    if game_state.current_player != event.player_id {
        game_state.inc_version();
        return Ok(Json(game_state.error("It's not your turn".into())));
    }

    if event.event_name == "cell-clicked" {
        let id = event.value.cell.parse::<usize>().unwrap();
        game_state.board[id] = game_state.current_player_character();
        game_state.moved();
    }

    game_state.inc_version();
    game_state.save()?;

    let new_assigns = Assigns {
        version: game_state.version,
        error: None,
        player_id: event.player_id,
    };

    Ok(Json(new_assigns))
}

#[plugin_fn]
pub fn render(Json(assigns): Json<Assigns>) -> FnResult<String> {
    let game_state = Game::load()?;
    Ok(game_state.render(assigns))
}