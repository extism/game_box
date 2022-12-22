mod game;

use crate::game::*;
use extism_pdk::*;
use serde::Deserialize;

#[derive(Deserialize)]
struct GameConfig {
    player_id: String,
    player_ids: Vec<String>
}

#[plugin_fn]
pub fn init_game(Json(conf): Json<GameConfig>) -> FnResult<Json<Assigns>> {
    let mut storage = PluginStorage::new();
    let game = Game::new(conf.player_id, conf.player_ids);
    storage.save(&game)?;
    let new_assigns = Assigns{player_id: game.current_player};
    Ok(Json(new_assigns))
}

#[derive(Deserialize)]
struct CellValue {
    cell: String,
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
        let cell_idx = event.value.cell.parse::<usize>().unwrap();
        game.make_move(&mut storage, event.player_id.clone(), cell_idx)?;
    } else if event.event_name == "reset-game" {
        game.reset();
        storage.save(&game)?;
    }

    let new_assigns = Assigns {
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

#[plugin_fn]
pub fn game_state(player_id: String) -> FnResult<Json<Assigns>> {
    let assigns = Assigns {
        player_id: player_id,
    };
    Ok(Json(assigns))
}
