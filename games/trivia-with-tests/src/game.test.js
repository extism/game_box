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

  test("render game with second 2 questinos", () => { 
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
    ]

    const event = game.handleEvent({player_id: "amy", event_name: "answer-prompt", value: 2})
    expect(event.player_id).toMatch(/amy/)

    // Question 0
    let qObj = questions[game.state.questionIndex]
    expect(qObj.prompt).toMatch("Disney")
    expect(qObj.options).toContain("Scrooge McDuck")
    expect(qObj.answerIndex).toBe(3)

    const player_1_answered = game.handleEvent({player_id: "amy", event_name: "answer-prompt", value: 3})
    expect(player_1_answered.player_id).toMatch(/amy/)

    const player_2_answered = game.handleEvent({player_id: "jackson", event_name: "answer-prompt", value: 2})
    expect(player_2_answered.player_id).toMatch(/jackson/)

    // Question 1
    let q1Obj = questions[game.state.questionIndex]
    expect(q1Obj.prompt).toMatch("Lumineers")
    expect(q1Obj.options).toContain("Cleopatra")
    expect(q1Obj.answerIndex).toBe(1)

    const player_1_answered1 = game.handleEvent({player_id: "amy", event_name: "answer-prompt", value: 1})
    expect(player_1_answered1.player_id).toMatch(/amy/)

    const player_2_answered1 = game.handleEvent({player_id: "jackson", event_name: "answer-prompt", value: 2})
    expect(player_2_answered1.player_id).toMatch(/jackson/)

    // Question 2
    let q2Obj = questions[game.state.questionIndex]
    expect(q2Obj.prompt).toMatch("Gremlins")
    expect(q2Obj.options).toContain("Midnight")
    expect(q2Obj.answerIndex).toBe(1)

    const player_1_answered2 = game.handleEvent({player_id: "amy", event_name: "answer-prompt", value: 3})
    expect(player_1_answered2.player_id).toMatch(/amy/)

    const player_2_answered2 = game.handleEvent({player_id: "jackson", event_name: "answer-prompt", value: 1})
    expect(player_2_answered2.player_id).toMatch(/jackson/)

    console.log("::ANSWERS::")
    console.log(game.state.answers)

    // /expect(game.state.name).toBe("done")

  })
});
