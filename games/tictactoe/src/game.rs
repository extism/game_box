use anyhow::bail;
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

// Stores the state of the game
#[derive(Serialize, Deserialize, Debug)]
pub struct Game {
    pub current_player: String,
    pub player_ids: Vec<String>,
    pub board: Vec<String>,
    pub version: i32,
    pub winning_cells: Option<Vec<usize>>,
    pub winner: Option<usize> 
}

pub trait Persister {
    fn load(&self) -> Result<Game, Error>;
    fn save(&mut self, game: &Game) -> Result<(), Error>;
}

pub struct PluginStorage;

impl PluginStorage {
    pub fn new() -> Self {
        PluginStorage {}
    }
}

impl Persister for PluginStorage {
    fn load(&self) -> Result<Game, Error> {
        let state = var::get("game_state")?.expect("variable 'game_state' set");
        let serialized = String::from_utf8(state).expect("string from varible value");
        let game: Game = serde_json::from_str(serialized.as_str())?;
        Ok(game)
    }

    fn save(&mut self, game: &Game) -> Result<(), Error> {
        let serialized = serde_json::to_string(game)?;
        set_var!("game_state", "{}", serialized)?;
        Ok(())
    }
}

impl Game {
    pub fn new(player_ids: Vec<String>) -> Self {
        let mut board: Vec<String> = vec![];
        board.resize(9, "".into());
        Game {
            current_player: player_ids[0].to_string(),
            winning_cells: None,
            winner: None,
            version: 0,
            player_ids,
            board,
        }
    }

    pub fn render(&self, assigns: Assigns) -> String {
        let mut context = tera::Context::new();
        context.insert("css", std::str::from_utf8(APP_CSS).unwrap());
        context.insert("game", self);
        context.insert("assigns", &assigns);
        Tera::one_off(std::str::from_utf8(APP_HTML).unwrap(), &context, false).unwrap()
    }

    // pub fn make_move(&mut self, player_id: String) -> Result<(), Error> {
    //     if self.current_player != player_id {
    //         bail!("It's not your turn");
    //     }



    //     Ok(())
    // }

    pub fn current_player_character(&self) -> String {
        if self.player_ids[0] == self.current_player {
            return "X".into();
        }
        "O".into()
    }

    pub fn moved(&mut self) {
        if self.player_ids[0] == self.current_player {
            self.current_player = self.player_ids[1].clone();
        } else {
            self.current_player = self.player_ids[0].clone();
        }
    }

    pub fn set_winning_cells(&mut self) {
        // check cols
        let col_candidates: Vec<Vec<usize>> =
            (0..3).into_iter().map(|i| vec![i, i + 3, i + 6]).collect();

        // check rows
        let row_candidates: Vec<Vec<usize>> = (0..3)
            .into_iter()
            .map(|i| {
                let x = i * 3;
                vec![x, x + 1, x + 2]
            })
            .collect();

        // check diagonals
        let mut candidates = vec![vec![0, 4, 8], vec![2, 4, 6]];

        candidates.extend(col_candidates);
        candidates.extend(row_candidates);

        for cand in candidates {
            let vals: Vec<String> = cand.iter().map(|c| self.board[*c].clone()).collect();
            if vals.iter().all(|c| c == "X") {
                self.winning_cells = Some(cand);
                self.winner = Some(0);
                break;
            } else if vals.iter().all(|c| c == "O") {
                self.winning_cells = Some(cand);
                self.winner = Some(1);
                break;
            }
        }
    }

    pub fn inc_version(&mut self) {
        self.version += 1;
    }

    pub fn error(&mut self, msg: String) -> Assigns {
        self.version += 1;
        //return AssignsBuilder::default().error(Some(msg)).build().unwrap();
        Assigns {
            player_id: "".into(),
            error: Some(msg),
            version: self.version,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    pub struct FakeStorage {
        pub state: String,
    }

    impl FakeStorage {
        pub fn new() -> Self {
            FakeStorage { state: "".into() }
        }
    }

    impl Persister for FakeStorage {
        fn load(&self) -> Result<Game, Error> {
            let game: Game = serde_json::from_str(self.state.as_str())?;
            Ok(game)
        }

        fn save(&mut self, game: &Game) -> Result<(), Error> {
            let serialized = serde_json::to_string(game)?;
            self.state = serialized;
            Ok(())
        }
    }

    #[test]
    fn run_simulation() -> Result<(), Error> {
        let mut storage = FakeStorage::new();
        let game = Game::new(vec!["benjamin".into(), "brian".into()]);
        storage.save(&game)?;
        let mut game = storage.load()?;
        println!("{:#?}", game);

        let assigns = Assigns {
            player_id: "benjamin".into(),
            error: None,
            version: 0,
        };

        println!("{}", game.render(assigns));

        game.board[0] = "O".into();
        game.board[1] = "O".into();
        game.board[2] = "X".into();
        game.set_winning_cells();

        println!("{:#?}", game.winning_cells);
        println!("{:#?}", game.winner);

        let assigns = Assigns {
            player_id: "benjamin".into(),
            error: None,
            version: 0,
        };
        println!("{}", game.render(assigns));

        Ok(())
    }
}
