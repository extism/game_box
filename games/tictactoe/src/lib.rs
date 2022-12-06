use extism_pdk::*;
use serde::{Serialize, Deserialize};
use tera::Tera;

#[derive(Serialize, Deserialize)]
enum State {
    StartedGame,
    EndedGame,
}

#[derive(Serialize, Deserialize)]
struct GameState {
    pub current_player: String,
    pub player_ids: Vec<String>,
    pub board: Vec<String>,
    pub state: State,
    pub version: i32,
}

static APP_CSS: &[u8] = include_bytes!("templates/app.css");
static APP_HTML: &[u8] = include_bytes!("templates/app.html");

impl GameState {
    pub fn new() -> Self {
        let board: Vec<String> = vec![
            "".into(), "".into(), "".into(),
            "".into(), "".into(), "".into(),
            "".into(), "".into(), "".into(),
        ];
        return GameState {
           player_ids: vec!["player1".into(), "player2".into()],
           board: board,
           current_player: "".into(),
           state: State::StartedGame,
           version: 0,
        }
    }

    pub fn load() -> Result<Self, Error> {
        let state = var::get("game_state")?.expect("variable 'game_state' set");
        let serialized = String::from_utf8(state).expect("string from varible value");
        let game: GameState = serde_json::from_str(serialized.as_str())?;
        Ok(game)
    }

    pub fn save(&self) -> Result<(), Error> {
        let serialized = serde_json::to_string(self)?;
        set_var!("game_state", "{}", serialized)?;
        Ok(())
    }

    pub fn render(&self, assigns: Assigns) -> String {
        match self.state {
            State::StartedGame => self.render_board(assigns),
            State::EndedGame => self.render_board(assigns),
        }
    }

    pub fn render_board(&self, assigns: Assigns) -> String {
        let mut context = tera::Context::new();
        context.insert("css", std::str::from_utf8(APP_CSS).unwrap());
        context.insert("current_player", self.current_player.as_str());
        context.insert("player_id", assigns.player_id.as_str());
        context.insert("board", &self.board);
        Tera::one_off(std::str::from_utf8(APP_HTML).unwrap(), &context, false).unwrap()
    }

    pub fn current_player_character(&self) -> String {
        if self.player_ids[0] == self.current_player {
            return "X".into()
        }
        return "O".into()
    }

    pub fn moved(&mut self) {
        if self.player_ids[0] == self.current_player {
            self.current_player = self.player_ids[1].clone();
        } else {
            self.current_player = self.player_ids[0].clone();
        }
    }
}

#[plugin_fn]
pub fn init_game(_: ()) -> FnResult<String> {
    let game_state = GameState::new();
    game_state.save()?;
    Ok(game_state.render(Assigns { player_id: "".to_string()}))
}

#[derive(Deserialize)]
struct CellValue {
    cell: String
}

#[derive(Deserialize)]
struct LiveEvent {
    player_id: String,
    event_name: String,
    code: String,
    value: CellValue,
}

#[plugin_fn]
pub fn handle_event(Json(event): Json<LiveEvent>) -> FnResult<String> {
    let mut game_state = GameState::load()?;
    // if game_state.current_player != event.player_id {
    //     return Ok(game_state.render())
    // }

    if event.event_name == "cell-clicked" {
        let id = event.value.cell.parse::<usize>().unwrap();
        game_state.board[id] = game_state.current_player_character();
        game_state.moved();
    }

    game_state.version = game_state.version + 1;
    game_state.save()?;
    Ok(game_state.version.to_string())
}

#[derive(Deserialize)]
struct Assigns {
    player_id: String,
}

#[plugin_fn]
pub fn render(Json(assigns): Json<Assigns>) -> FnResult<String> {
    let game_state = GameState::load()?;
    Ok(game_state.render(assigns))
}