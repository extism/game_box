use derive_builder::Builder;
use extism_pdk::*;
use serde::{Deserialize, Serialize};
use tera::Tera;

static APP_CSS: &[u8] = include_bytes!("templates/app.css");
static APP_HTML: &[u8] = include_bytes!("templates/app.html");


// Assigns are attached to the user's socket
// They are passed to the render() function to render the screen
// Assigns are also returned from the handle_event() function.
// When returned, those values are assigned to the user's socket
#[derive(Builder, Serialize, Deserialize)]
pub struct Assigns {
    #[serde(skip_serializing)]
    pub player_id: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub error: Option<String>,
    #[serde(skip_deserializing)]
    pub version: i32,
}

#[derive(Serialize, Deserialize)]
pub enum GameState {
    Playing,
    Ended,
}

// Stores the state of the game
#[derive(Serialize, Deserialize)]
pub struct Game {
    pub current_player: String,
    pub player_ids: Vec<String>,
    pub board: Vec<String>,
    pub state: GameState,
    pub version: i32,
}

pub trait Persistence {
    fn load() -> Result<Game, Error>;
    fn save(&self) -> Result<(), Error>;
}

impl Persistence for Game {
    fn load() -> Result<Self, Error> {
        let state = var::get("game_state")?.expect("variable 'game_state' set");
        let serialized = String::from_utf8(state).expect("string from varible value");
        let game: Game = serde_json::from_str(serialized.as_str())?;
        Ok(game)
    }

    fn save(&self) -> Result<(), Error> {
        let serialized = serde_json::to_string(self)?;
        set_var!("game_state", "{}", serialized)?;
        Ok(())
    }
}

impl Game {
    pub fn new(player_ids: Vec<String>) -> Self {
        let mut board: Vec<String> = vec![];
        board.resize(9, "".into());
        return Game {
            board: board,
            current_player: player_ids[0].to_string(),
            state:GameState::Playing,
            version: 0,
            player_ids,
        };
    }

    pub fn render(&self, assigns: Assigns) -> String {
        match self.state {
            GameState::Playing => self.render_board(assigns),
            GameState::Ended => self.render_board(assigns),
        }
    }

    fn render_board(&self, assigns: Assigns) -> String {
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