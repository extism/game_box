 import { getQuestions } from './questions'


const questions = getQuestions()

export class Game {
  constructor(state) {
    
    // this.version = state.version || 0
    this.players = state.players
    this.state = state.state || { name: "prompting", questionIndex: 0, answers: {} }
    if (state.score) {
      this.score = state.score
    } else {
      this.score = {}
      this.players.forEach(p => this.score[p] = 0)
    }
  }


  render(assigns) {
    switch (this.state.name) {
      case "prompting": {
        return this.renderPrompt(assigns)
      }
      case "done": {
        return this.renderScoreboard(assigns)
      }
    }
  }

  renderPrompt(assigns) {
    if (this.state.answers[assigns.player_id] !== undefined)
      return "<p>Answered. Waiting on other players</p>"

    let qObj = questions[this.state.questionIndex]
    const question = `<h1>${qObj.prompt}</h1>`
    const answers = qObj.options.map((opt, idx) => {
      return `<li><button phx-click="answer-prompt" phx-value-idx=${idx}>${opt}</button></li>`
    }).join("\n")

    return [question, `<ul>${answers}</ul>`].join("\n")
  }

  renderScoreboard(_assigns) {
    const scores = Object.keys(this.score).map(player => {
      return `<li>${this.score[player]} ${player}</li>`
    }).join("\n")
    return `<h1>Scoreboard</h1><ul>${scores}</ul>`
  }

  handleEvent(event) {
    if (event.event_name !== "answer-prompt") throw Error("unknown event")
    const assigns = this.handleAnswerPrompt(event)
    this.nextState()
    return assigns
  }

  handleAnswerPrompt(event) {
    const assigns = { player_id: event.player_id }
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
        break
      }
      case "done": {
        break
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
