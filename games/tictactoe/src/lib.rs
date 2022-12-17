mod game;

use crate::game::*;
use extism_pdk::*;
use serde::Deserialize;

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
    cell: String,
    value: String,
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
    let mut game_state = storage.load()?;

    if game_state.current_player != event.player_id {
        game_state.inc_version();
        let err = game_state.error("It's not your turn".into());
        storage.save(&game_state)?;
        return Ok(Json(err));
    }

    if event.event_name == "cell-clicked" {
        let id = event.value.cell.parse::<usize>().unwrap();
        game_state.board[id] = game_state.current_player_character();
        game_state.moved();
    } else if event.event_name == "reset-game" {
        let game_state_d = Game::new(game_state.player_ids);
        storage.save(&game_state_d)?;
        let new_assigns = Assigns {
            version: 0,
            error: None,
            player_id: event.player_id,
        };
        return Ok(Json(new_assigns))
    }

    game_state.set_winning_cells();

    game_state.inc_version();
    storage.save(&game_state)?;

    let new_assigns = Assigns {
        version: game_state.version,
        error: None,
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
