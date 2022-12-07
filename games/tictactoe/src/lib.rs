use derive_builder::Builder;
use extism_pdk::*;
use serde::{Deserialize, Serialize};
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
    pub fn new(player_ids: Vec<String>) -> Self {
        let mut board: Vec<String> = vec![];
        board.resize(9, "".into());
        return GameState {
            board: board,
            current_player: player_ids[0].to_string(),
            state: State::StartedGame,
            version: 0,
            player_ids,
        };
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
            return "X".into();
        }
        return "O".into();
    }

    pub fn moved(&mut self) {
        if self.player_ids[0] == self.current_player {
            self.current_player = self.player_ids[1].clone();
        } else {
            self.current_player = self.player_ids[0].clone();
        }
    }

    pub fn inc_version(&mut self) {
        self.version += 1;
    }

    pub fn error(&mut self, msg: String) -> Assigns {
        self.version += 1;
        self.save();
        //return AssignsBuilder::default().error(Some(msg)).build().unwrap();
        return Assigns {
            player_id: "".into(),
            error: Some(msg),
            version: self.version,
        };
    }
}

#[derive(Deserialize)]
struct GameConfig {
    player_ids: Vec<String>,
}

#[plugin_fn]
pub fn init_game(Json(conf): Json<GameConfig>) -> FnResult<()> {
    let game_state = GameState::new(conf.player_ids);
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

#[derive(Builder, Serialize, Deserialize)]
struct Assigns {
    #[serde(skip_serializing)]
    player_id: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    error: Option<String>,
    #[serde(skip_deserializing)]
    version: i32,
}

#[plugin_fn]
pub fn handle_event(Json(event): Json<LiveEvent>) -> FnResult<Json<Assigns>> {
    let mut game_state = GameState::load()?;
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
    let game_state = GameState::load()?;
    Ok(game_state.render(assigns))
}
