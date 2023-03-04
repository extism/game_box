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
      score: {"amy": 5, "jackson": 3},
      version: 10,
      state: { name: "done", questionIndex: 9, answers: {}}
    });
    const result = game.render({player_id: "amy"})
    expect(result).toMatch(/Scoreboard/)
    expect(result).toMatch(/>5 amy/)
    expect(result).toMatch(/>5 amy/)
  })

  test("play a 2-player game start-to-finish", () => { 
    const game = new Game({
      players: ["amy", "jackson"],
      score: {"amy": 0, "jackson": 0},
      state: { name: "prompting", questionIndex: 0, answers: {}}
    });

    const questions = 
    [
      {
        "prompt": "Which of these is NOT a Disney cartoon character?",
        "options": [
        "Donald Duck",
        "Daisy Duck",
        "Scrooge McDuck",
        "Daffy Duck"
        ],
        "answerIndex": 3
      },
      {
        "prompt": "What album did The Lumineers release in 2016?",
        "options": [
        "The Lumineers",
        "Cleopatra",
        "Tracks From The Attic",
        "Winter"
        ],
        "answerIndex": 1
      },
      {
        "prompt": "In the movie Gremlins, after what time of day should you not feed Mogwai?",
        "options": [
        "Morning",
        "Midnight",
        "Evening",
        "Afternoon"
        ],
        "answerIndex": 1
      },
      {
        "prompt": "When was the top-down online RPG &quot;Space Station 13&quot; released?",
        "options": [
        "2006",
        "2010",
        "2000",
        "2003"
        ],
        "answerIndex": 3
      },
      {
        "prompt": "These two countries held a commonwealth from the 16th to 18th century.",
        "options": [
        "Bangladesh and Bhutan",
        "North Korea and South Korea",
        "Poland and Lithuania",
        "Hutu and Rwanda"
        ],
        "answerIndex": 2
      }
    ]

    const event = game.handleEvent({player_id: "amy", event_name: "answer-prompt", value: 3})
    expect(event.player_id).toMatch(/amy/)

    // Question 0
    let qObj = questions[game.state.questionIndex]
    expect(qObj.prompt).toMatch("Disney")
    expect(qObj.options).toContain("Scrooge McDuck")
    expect(qObj.answerIndex).toBe(3)

    const player_1_answered = game.handleEvent({player_id: "amy", event_name: "answer-prompt", value: { "idx": 3 }})
    expect(player_1_answered.player_id).toMatch(/amy/)

    const player_2_answered = game.handleEvent({player_id: "jackson", event_name: "answer-prompt", value: { "idx": 2 }})
    expect(player_2_answered.player_id).toMatch(/jackson/)
    
    expect(game.score["amy"]).toBe(1)
    expect(game.score["jackson"]).toBe(0)

    // Question 1
    let q1Obj = questions[game.state.questionIndex]
    expect(q1Obj.prompt).toMatch("Lumineers")
    expect(q1Obj.options).toContain("Cleopatra")
    expect(q1Obj.answerIndex).toBe(1)

    const player_1_answered1 = game.handleEvent({player_id: "amy", event_name: "answer-prompt", value: { "idx": 1 }})
    expect(player_1_answered1.player_id).toMatch(/amy/) 
    
    const player_2_answered1 = game.handleEvent({player_id: "jackson", event_name: "answer-prompt", value: { "idx": 2 }})
    expect(player_2_answered1.player_id).toMatch(/jackson/)

    expect(game.score["amy"]).toBe(2)
    expect(game.score["jackson"]).toBe(0)

    // // Question 2
    let q2Obj = questions[game.state.questionIndex]
    expect(q2Obj.prompt).toMatch("Gremlins")
    expect(q2Obj.options).toContain("Midnight")
    expect(q2Obj.answerIndex).toBe(1)

    const player_1_answered2 = game.handleEvent({player_id: "amy", event_name: "answer-prompt", value: { "idx": 3 }})
    expect(player_1_answered2.player_id).toMatch(/amy/)

    const player_2_answered2 = game.handleEvent({player_id: "jackson", event_name: "answer-prompt", value: { "idx": 1 }})
    expect(player_2_answered2.player_id).toMatch(/jackson/)

    expect(game.score["amy"]).toBe(2)
    expect(game.score["jackson"]).toBe(1)

     // // Question 3
     let q3Obj = questions[game.state.questionIndex]
     const player_1_answered3 = game.handleEvent({player_id: "amy", event_name: "answer-prompt", value: { "idx": 3 }})
     game.handleEvent({player_id: "jackson", event_name: "answer-prompt", value: { "idx": 1 }})
    
     expect(game.score["amy"]).toBe(3)
     expect(game.score["jackson"]).toBe(1)

      // // Question 4
    let q4Obj = questions[game.state.questionIndex]
    const player_1_answered4 = game.handleEvent({player_id: "amy", event_name: "answer-prompt", value: { "idx": 3 }})
    expect(player_1_answered4.player_id).toMatch(/amy/)
    game.handleEvent({player_id: "jackson", event_name: "answer-prompt", value: { "idx": 1 }})
    
    expect(game.score["amy"]).toBe(3)
    expect(game.score["jackson"]).toBe(1)

    expect(game.state.name).toMatch(/done/)    

  })

  test("throw error if event name is not answer-prompt", () => { 
    const game = new Game({
      players: ["amy", "jackson"],
      score: {"amy": 0, "jackson": 0},
      state: { name: "prompting", questionIndex: 0, answers: {}}
    });

    function badEventName() { 
       const event = game.handleEvent({player_id: "amy", event_name: "not-an-answer-prompt", value: 3})
    } 
    
    expect(badEventName).toThrow()

  })

  test("throw error if state name is not prompting", () => { 
    function badEventName() { 
      const game = new Game({
        players: ["amy", "jackson"],
        score: {"amy": 0, "jackson": 0},
        state: { name: "not-prompting", questionIndex: 0, answers: {}}
      });
       const event = game.recordScore({player_id: "amy"})
    } 
    expect(badEventName).toThrow()
  })

  test("throw error if state name is not prompting in handleAnswerPrompt", () => { 
      const game = new Game({
        players: ["amy", "jackson"],
        score: {"amy": 0, "jackson": 0},
        state: { name: "not-prompting", questionIndex: 0, answers: {}}
      });
    
      const event = game.handleEvent({player_id: "amy", event_name: "answer-prompt", value: 3})
      expect(event.player_id).toMatch(/amy/)
  })
});
