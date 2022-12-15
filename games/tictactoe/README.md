# GamePlugin

### There are 3 functions that the game engine expects to be exported

* `init_game(Json<GameConfig>) -> void` 
* `render(Json<Assigns>) -> String` 
* `handle_event(Json<LiveEvent>) -> Json<Assigns>` 
