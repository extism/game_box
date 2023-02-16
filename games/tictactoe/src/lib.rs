mod game;

use crate::game::*;
use extism_pdk::*;
use serde::{Deserialize, Serialize};

#[derive(Deserialize)]
struct GameConfig {
    player_ids: Vec<String>,
}

#[plugin_fn]
pub fn init_game(Json(conf): Json<GameConfig>) -> FnResult<()> {
    let mut storage = PluginStorage::new();
    let game = Game::new(conf.player_ids);
    storage.save(&game)?;
    Ok(())
}

#[derive(Deserialize)]
struct CellValue {
    #[serde(skip_serializing_if = "Option::is_none")]
    cell: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    value: Option<String>,
}

#[derive(Deserialize)]
struct LiveEvent {
    player_id: String,
    event_name: String,
    value: CellValue,
}

#[plugin_fn]
pub fn handle_event(Json(event): Json<LiveEvent>) -> FnResult<Json<Assigns>> {
    let mut storage = PluginStorage::new();
    let mut game = storage.load()?;

    if event.event_name == "cell-clicked" {
        let cell_idx = event.value.cell.unwrap().parse::<usize>().unwrap();
        game.make_move(&mut storage, event.player_id.clone(), cell_idx)?;
    } else if event.event_name == "reset-game" {
        game.reset();
        storage.save(&game)?;
    }

    let new_assigns = Assigns {
        version: game.version,
        player_id: event.player_id,
    };

    Ok(Json(new_assigns))
}

#[plugin_fn]
pub fn render(Json(assigns): Json<Assigns>) -> FnResult<String> {
    let storage = PluginStorage::new();
    let game_state = storage.load()?;
    Ok(game_state.render(assigns))
}

#[derive(Serialize)]
struct GameConstraints {
    min_players: u32,
    max_players: u32,
}

#[plugin_fn]
pub fn get_constraints(_: ()) -> FnResult<Json<GameConstraints>> {
    Ok(Json(GameConstraints { max_players: 2, min_players: 2}))
}
