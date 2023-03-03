import {Game} from './game.js'

describe("Game", () => {
  
  test("construct from scratch", () => { 
    const game = new Game({players: ["amy", "jackson"]});
    expect(game.score).toStrictEqual({"amy": 0, "jackson": 0})
    expect(game.version).toBe(0)
  });
 
  test("construct with prompting state", () => { 
    const game = new Game({
      players: ["amy", "jackson"],
      score: {"amy": 1, "jackson": 1},
      version: 10,
      state: { name: "prompting", questionIndex: 1, answers: {}}
    });
    expect(game.score).toStrictEqual({"amy": 1, "jackson": 1})
    expect(game.state.name).toBe("prompting")
  });

  test("construct with invalid state name", () => { 
    const game = new Game({
      players: ["amy", "jackson"],
      state: { name: "somethinglese", questionIndex: 1, answers: {}}
    });

    const result = game.render({player_id: "amy"})
    // console.dir(result)
    // expect(result).toThrow()
  });
  
  test("render for user who has already answered", () => { 
    const game = new Game({players: ["amy", "jackson"]});
    game.state.answers["amy"] = 0
    const result = game.render({player_id: "amy"})
    expect(result).toMatch(/Answered. Waiting on other players/)
  });

  test("render for user who has not answered", () => { 
    const game = new Game({players: ["amy", "jackson"]});
    const result = game.render({player_id: "amy"})
    expect(result).toMatch(/button/)
  });
  
  test("render scoreboard for a done game", () => { 
    const game = new Game({
      players: ["amy", "jackson"],
      score: {"amy": 1, "jackson": 1},
      version: 10,
      state: { name: "done", questionIndex: 9, answers: {}}
    });
    const result = game.render({player_id: "amy"})
    expect(result).toMatch(/Scoreboard/)
  })

  test("render answer prompt", () => { 
    const game = new Game({
      players: ["amy", "jackson"],
      score: {"amy": 1, "jackson": 1},
      version: 10,
      state: { name: "prompting", questionIndex: 2, answers: {}}
    });
    
    const event = game.handleEvent({player_id: "amy", event_name: "answer-prompt", value: 2})
     expect(event.player_id).toMatch(/amy/)
  })


});
