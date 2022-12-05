use extism_pdk::*;
use serde::{Serialize, Deserialize};

const BOARD_CSS: &str = "
  .board {
    display: flex;
    flex-direction: column;
  }
  .row {
    display: flex;
    flex-direction: row;
    gap: 10px;
  }
  .cell {
    padding: 60px;
    margin: 5px;
    border: dotted;
    width: 200px;
    height: 200px;
    font-size: 45px;
  }
";

#[derive(Serialize, Deserialize)]
enum State {
    WAITING_FOR_PLAYERS,
    STARTED_GAME,
    ENDED_GAME,
}

#[derive(Serialize, Deserialize)]
struct GameState {
    pub current_player: String,
    pub player_ids: Vec<String>,
    pub board: Vec<String>,
    pub state: State,
}

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
           current_player: "player1".into(),
           state: State::STARTED_GAME,
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

    pub fn render(&self) -> String {
        match self.state {
            State::WAITING_FOR_PLAYERS => self.render_join(),
            State::STARTED_GAME => self.render_board(),
            State::ENDED_GAME => self.render_board(),
        }
    }

    pub fn render_join(&self) -> String {
        let items: Vec<String> = vec![
            // "<style>".into(),
            // BOARD_CSS.into(),
            // "</style>".into(),
            "<form>".into(),
            "<p>Name</p>".into(),
            "<input type=\"text\" />".into(),
            "<input id=\"join-submit\" type=\"submit\" value=\"Join\"/>".into(),
            "</form>".into(),
        ];
        items.join("")
    }

    pub fn render_board(&self) -> String {
        let mut items: Vec<String> = vec![
            "<style>".into(),
            BOARD_CSS.into(),
            "</style>".into(),
            "<div class=\"board\">".into(),
        ];
        for row in 0..3 {
            items.push("<div class=\"row\">".into());
            for col in 0..3 {
                let idx = col + (row * 3);
                let char = self.board[idx].clone();
                let button = format!("<button phx-click=\"cell-clicked\" phx-value-cell=\"{}\" class=\"cell\">{}</button>", idx, char);
                items.push(button);
            }
            items.push("</div>".into());
        }
        items.push("</div>".into());
        items.join("")
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
    Ok(game_state.render())
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

    game_state.save()?;

    Ok(game_state.render())
}

#[plugin_fn]
pub fn render(_: ()) -> FnResult<String> {
    let game_state = GameState::load()?;
    Ok(game_state.render())
}
