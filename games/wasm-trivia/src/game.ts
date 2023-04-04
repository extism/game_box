import { Question, getQuestions } from './questions'

type Prompting = {
  name: "prompting",
  questionIndex: number,
  answers: any,
}

type Done = {
  name: "done",
}

type GameState = Prompting | Done;

export interface Assigns {
  player_id: string,
  version?: number,
}

export interface LiveEvent {
  player_id: string,
  event_name: string,
  value: any
}

const questions = getQuestions()

const STYLE = `
<style>
h1.question {
  font-size: 1.5rem;
}

ul.answers {
  list-style: circle;
}

li.answer {
  line-height: 2;
}

li.answer > button {
  font-size: 1.3rem;
  text-decoration: underline;
}

p.stats {
  margin-top: 15px;
}

button.next_button {
  text-decoration: underline;
}
</style>
`

export class Game {
  players: Array<string>;
  version: number;
  questions: Array<Question>;
  state: GameState;
  score: any;

  constructor(state: any) {
    this.version = state.version || 0
    this.players = state.players
    this.state = state.state || { name: "prompting", questionIndex: 0, answers: {} }
    if (state.score) {
      this.score = state.score
    } else {
      this.score = {}
      this.players.forEach(p => this.score[p] = 0)
    }
  }

  render(assigns: Assigns): string {
    switch (this.state.name) {
      case "prompting": {
        return STYLE + this.renderPrompt(assigns)
      }
      case "done": {
        return STYLE + this.renderScoreboard(assigns)
      }
    }
  }

  renderPrompt(assigns: Assigns): string {
    if (this.state.name != "prompting") throw Error("un")

    const is_playing = this.players.includes(assigns.player_id)
    if (!is_playing) {
      return `<p>Sorry, there were too many people that joined and you were too late.</p>`
    }

    const player_count = this.players.length
    const answered_count = Object.keys(this.state.answers).length
    const answered = `<p class="stats">${answered_count} of ${player_count} Players Answered</p>`

    let next_btn = ""
    // Assume first player is host
    if (assigns.player_id == this.players[0]) {
      next_btn = `<button phx-click="next-question" class="next_button">Next Question</button>`
    }

    if (this.state.answers[assigns.player_id] !== undefined)
      return "<p>Answered. Waiting on other players</p>" + answered + next_btn

    let qObj = questions[this.state.questionIndex]
    const question = `<h1 class="question">${qObj.prompt}</h1>`
    const answers = qObj.options.map((opt, idx) => {
      return `<li class="answer"><button phx-click="answer-prompt" phx-value-idx=${idx}>${opt}</button></li>`
    }).join("\n")

    let view = [question, `<ul class="answers">${answers}</ul>`, answered, next_btn]
    return view.join("\n")
  }

  renderScoreboard(_assigns: Assigns): string {
    let sortable = []
    for (var s in this.score) {
        // @ts-ignore
        sortable.push([s, this.score[s]])
    }
    sortable.sort((a, b) => {
      return b[1] - a[1]
    })
    
    const scores = sortable.map(items => {
      let player = items[0]
      let score = items[1]
      return `<li>${score} ${player}</li>`
    }).join("\n")
    return `<h1>Scoreboard</h1><ul>${scores}</ul>`
  }

  handleEvent(event: LiveEvent): Assigns {
    //if (event.event_name !== "answer-prompt") throw Error("unknown event")
    switch (event.event_name) {
      case "answer-prompt":
        let a1 = this.handleAnswerPrompt(event)
        this.nextState()
        return a1
      case "next-question":
        let a2 = this.handleNextQuestion(event)
        return a2
      default:
        throw Error("unknown event")
    }
  }

  handleAnswerPrompt(event: LiveEvent): Assigns {
    const assigns: Assigns = { player_id: event.player_id }
    if (this.state.name !== "prompting") return assigns
    if (!this.players.includes(event.player_id)) return assigns

    this.state.answers[event.player_id] = parseInt(event.value.idx, 10)
    this.version += 1

    return assigns
  }

  handleNextQuestion(event: LiveEvent): Assigns {
    const assigns: Assigns = { player_id: event.player_id }
    if (this.state.name !== "prompting") return assigns

    this.nextQuestion()
    this.version += 1

    return assigns
  }

  nextState() {
    switch (this.state.name) { 
      case "prompting": {
        // if everyone has answered
        if (Object.keys(this.state.answers).length === this.players.length) {
          this.nextQuestion()
        }
        break
      }
      case "done": {
        break
      }
    }
  }

  nextQuestion() {
    if (this.state.name !== "prompting") return

    this.recordScore()
    if (this.state.questionIndex >= questions.length - 1) {
      this.finish()
    } else {
      this.state = {
        name: "prompting",
        questionIndex: this.state.questionIndex + 1,
        answers: {}
      }
    }
  }

  recordScore() {
    if (this.state.name !== "prompting") throw Error("Expected to be in prompting state")

    const answer = questions[this.state.questionIndex].answerIndex
    const answers = this.state.answers
    Object.keys(answers).forEach(player => {
      if (answers[player] === answer) {
        this.score[player] += 1
      }
    })

  }

  finish() {
    this.state = { name: "done" }
  }
}
