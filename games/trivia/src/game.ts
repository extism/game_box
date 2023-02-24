import { Question, getQuestions } from './questions'
import { h1, li } from './dom'

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

export class Game {
  players: Array<string>;
  version: number;
  questions: Array<Question>;
  state: GameState;
  score: any;

  constructor(state: any) {
    this.version = state.version || 0
    this.players = state.players
    this.questions = state.questions || getQuestions()
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
        return this.renderPrompt(assigns)
      }
      case "done": {
        return this.renderScoreboard(assigns)
      }
    }
  }

  renderPrompt(assigns: Assigns): string {
    if (this.state.name != "prompting") throw Error("un")

    if (this.state.answers[assigns.player_id] !== undefined)
      return "<p>Answered. Waiting on other players</p>"

    let qObj = this.questions[this.state.questionIndex]
    const question = `<h1>${qObj.prompt}</h1>`
    const answers = qObj.options.map((opt, idx) => {
      return `<li><button phx-click="answer-prompt" phx-value-idx=${idx}>${opt}</button></li>`
    }).join("\n")

    return [question, `<ul>${answers}</ul>`].join("\n")
  }

  renderScoreboard(_assigns: Assigns): string {
    const scores = Object.keys(this.score).map(player => {
      return `<li>${this.score[player]} ${player}</li>`
    }).join("\n")
    return `<h1>Scoreboard</h1><ul>${scores}</ul>`
  }

  handleEvent(event: LiveEvent): Assigns {
    if (event.event_name !== "answer-prompt") throw Error("unknown event")
    const assigns = this.handleAnswerPrompt(event)
    this.nextState()
    return assigns
  }

  handleAnswerPrompt(event: LiveEvent): Assigns {
    const assigns: Assigns = { player_id: event.player_id }
    if (this.state.name !== "prompting") return assigns

    this.state.answers[event.player_id] = parseInt(event.value.idx, 10)
    this.version += 1

    return assigns
  }

  nextState() {
    switch (this.state.name) { 
      case "prompting": {
        // if everyone has answered
        if (Object.keys(this.state.answers).length === this.players.length) {
          this.recordScore()
          if (this.state.questionIndex >= this.questions.length - 1) {
            this.finish()
          } else {
            this.state = {
              name: "prompting",
              questionIndex: this.state.questionIndex + 1,
              answers: {}
            }
          }
        }
        break
      }
      case "done": {
        break
      }
    }
  }

  recordScore() {
    if (this.state.name !== "prompting") throw Error("Expected to be in prompting state")

    const answer = this.questions[this.state.questionIndex].answerIndex
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
