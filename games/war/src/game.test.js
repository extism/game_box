import {Game} from './game.js'

describe("Game", () => {
  
  test("construct with new deck", () => { 
    const game = new Game({
      players: ["amy", "jackson"],
      score: {"amy": 0, "jackson": 0},
      version: 0, 
      gamewinner: "", 
      state: { phase: "playRound", round: 0, winner: "", playerDecks: [], answers: {}}
    });

    const result = game.render({player_id: "amy"})
    console.log(result) 

    expect(game.score).toStrictEqual({"amy": 0, "jackson": 0})
    expect(game.state.phase).toBe("playRound")
    expect(typeof game.deck).toBe('object')
    // expect(game.deck).toHaveLength(52)

    console.log("ROUND" + game.state.round)
    game.handleEvent({player_id: "amy", event_name: "flip-card", value: { "player": "amy" }})
    game.handleEvent({player_id: "jackson", event_name: "flip-card", value: { "player": "jackson" }})
    game.handleEvent({player_id: "jackson", event_name: "next-round", value: { "player": "jackson" }})

    game.render({player_id: "amy"})
   

    game.handleEvent({player_id: "amy", event_name: "flip-card", value: { "player": "amy" }})
    game.handleEvent({player_id: "jackson", event_name: "flip-card", value: { "player": "jackson" }})
    game.handleEvent({player_id: "jackson", event_name: "next-round", value: { "player": "jackson" }})

    game.render({player_id: "amy"})

    game.handleEvent({player_id: "amy", event_name: "flip-card", value: { "player": "amy" }})
    game.handleEvent({player_id: "jackson", event_name: "flip-card", value: { "player": "jackson" }})
    game.handleEvent({player_id: "jackson", event_name: "next-round", value: { "player": "jackson" }})

    game.render({player_id: "amy"})

    game.handleEvent({player_id: "amy", event_name: "flip-card", value: { "player": "amy" }})
    game.handleEvent({player_id: "jackson", event_name: "flip-card", value: { "player": "jackson" }})
    game.handleEvent({player_id: "jackson", event_name: "next-round", value: { "player": "jackson" }})

    // game.render({player_id: "amy"})

    // const rendered4 = game.render({player_id: "amy"})

    // game.handleEvent({player_id: "amy", event_name: "flip-card", value: { "player": "amy" }})
    // game.handleEvent({player_id: "jackson", event_name: "flip-card", value: { "player": "jackson" }})
   
    const rendered5 = game.render({player_id: "amy"})
    console.log("-----FINAL2-----")
    console.log(rendered5)
  });

  // test("finish hand, render scoreboard", () => { 
  //   const game = new Game({
  //     players: ["amy", "jackson"],
  //     score: {"amy": 3, "jackson": 27},
  //     version: 0, 
      
  //     state: { phase: "done", winner: "JACKSON", round: 26, playerDecks: [], answers: {}}
  //   });

  //   console.log("done")
  //   const rendered3 = game.render({player_id: "amy"})
  //   console.log(rendered3)
  // })

  
    // test("construct with new deck", () => { 
    //   const game = new Game({
    //     players: ["amy", "jackson"],
    //     score: {"amy": 0, "jackson": 0},
    //     state: { phase: "playRound", playerDecks: [], answers: {}}
    //   });
  
    //   const result = game.render({player_id: "amy"})
  
    //   expect(game.score).toStrictEqual({"amy": 0, "jackson": 0})
    //   expect(game.state.phase).toBe("playRound")
    //   expect(typeof game.deck).toBe('object')
    //   expect(game.deck).toHaveLength(52)
  
    //   game.handleEvent({player_id: "amy", event_name: "flip-card", value: { "player": "amy" }})
    //   game.handleEvent({player_id: "jackson", event_name: "flip-card", value: { "player": "jackson" }})
  
    //   const rendered = game.render({player_id: "amy"})

    //   console.log(rendered)
  
    // });

  // test("construct new round", () => { 
  //   const game = new Game({
  //     players: ["amy", "jackson"],
  //     score: {"amy": 0, "jackson": 0},
  //     version: 1,
  //     deck: [],
  //     state: { phase: "playRound", questionIndex: 1, answers: {}}
  //   });

  //   const result = game.render({player_id: "amy"})
    
  //   console.log(game)
  //   console.log("RESULT:")
  //   console.log(result)
  // });

 


 

})