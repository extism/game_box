import {Game} from './game.js'

describe("Game", () => {
  
  test("construct with new deck", () => { 
    const game = new Game({
      players: ["amy", "jackson"],
      score: {"amy": 0, "jackson": 0},
      version: 0, 
      winner: "", 
      state: { phase: "playRound", round: 0, playerDecks: [], answers: {}}
    });

    const result = game.render({player_id: "amy"})
    // console.log(result) 

    expect(game.score).toStrictEqual({"amy": 0, "jackson": 0})
    expect(game.state.phase).toBe("playRound")
    expect(typeof game.deck).toBe('object')
    expect(game.deck).toHaveLength(52)

    game.handleEvent({player_id: "amy", event_name: "flip-card", value: { "player": "amy" }})
    
    const rendered1 = game.render({player_id: "amy"})
    // console.log("Rendered for Amy after Amy flips first card \n" + rendered1)

    game.handleEvent({player_id: "jackson", event_name: "flip-card", value: { "player": "jackson" }})
    
    // expect(game.state.phase).toBe("playRound")

    const rendered2 = game.render({player_id: "amy"})
    // console.log("Rendered for Amy after Jackson Flips First Card \n" + rendered2)

    game.handleEvent({player_id: "amy", event_name: "next-round"})
    
    const rendered3 = game.render({player_id: "amy"})
    // console.log("Rendered for Amy after clicking 'next round' \n'" + rendered3)

    // console.log(`${}`)


  });

  
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