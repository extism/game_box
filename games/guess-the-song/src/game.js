import { getQuestions } from "./questions";

const questions = getQuestions();

// function setTimeoutInClass() {
//   global.setTimeout(() => {
//     console.log('hey giiiirl')
//     // window.alert("Hey girl");
//   }, 500);
// }

export class Game {
  constructor(state) {
    this.version = state.version || 0;
    this.players = state.players;

    this.timeout = state.timeout;
    this.state = state.state || {
      name: "prompting",
      questionIndex: 0,
      showAnswers: false,
      answers: {},
    };
    if (state.score) {
      this.score = state.score;
    } else {
      this.score = {};
      this.players.forEach((p) => (this.score[p] = 0));
    }
  }

  render(assigns) {
    switch (this.state.name) {
      case "prompting": {
        return this.renderPrompt(assigns);
      }
      case "done": {
        return this.renderScoreboard(assigns);
      }
    }
  }

  renderPrompt(assigns) {
    let output = "";
    output += `<div style="width: 100%; background-image: linear-gradient(to bottom, var(--tw-gradient-stops)); --tw-gradient-from: #9333ea; --tw-gradient-stops: var(--tw-gradient-from), var(--tw-gradient-to); --tw-gradient-to: #6b21a8; padding-left: 24px; padding-right: 24px; padding-top: 12px; padding-bottom: 12px; font-size: 30px">
                  Guess the Song: <b>Imagine Dragons</b>
               </div>`;
    output += `<div style="display: flex; height: 100%; min-height: 42rem; flex-direction: column; align-items: center; justify-content: flex-start; border-width: 4px; border-color: #581c87; background-image: url('http://amymurphy.tech/images/idbg.jpg'); padding: 24px; padding-top: 40px">`;

    // if (this.state.answers[assigns.player_id] !== undefined) {
    //   output += `<p>Answered. Waiting on other players</p>`
    // } else {
    let qObj = questions[this.state.questionIndex];
    const question = `<div style="width: 91%; background-color: rgb(88 28 135 / 0.5); padding: 40px; font-size: 22px; color: #fff">"${qObj.prompt}"</div>`;

    const answers = qObj.options
      .map((opt, idx) => {
        let selectedborder = "";
        let selectedtext = "";
        let disabled = "";

        if (
          qObj.answerIndex == idx &&
          Object.keys(this.state.answers).length === this.players.length &&
          this.state.showAnswers
        ) {
          selectedborder = "border-width: 2px; border-color: #86efac;";
          selectedtext = "color: #86efac;";
        } else {
          if (this.state.answers[assigns.player_id] == idx) {
            selectedborder = "border-width: 1px; border-color: #fff;";
            selectedtext = "color: #fff;";
          }
        }
        let selected_by_players = "";
        if (this.state.answers[assigns.player_id] !== undefined) {
          disabled = "disabled";

          this.players.forEach((p) => {
            if (this.state.answers[p] == idx) selected_by_players += `${p} `;
          });
        }

        return `<div style="cursor: pointer; text-align: left; background-color: rgb(88 28 135 / 0.5); ${selectedborder} font-size: 18px"><button ${disabled} phx-click="answer-prompt" phx-value-idx=${idx} style="${selectedtext} width: 100%; height: 100%; padding: 24px; text-align: left;">${opt}  <span style="margin-left: 12px; font-size: 14px; color: #d8b4fe">${selected_by_players}</span></button></div>`;
      })
      .join("\n");

    output += [
      question,
      `<div style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); width: 100%; align-items: center; justify-content: flex-start; column-gap: 24px; row-gap: 24px; padding-left: 48px; padding-right: 48px; padding-top: 24px; padding-bottom: 24px">${answers}</div>`,
    ].join("\n");
    // }
    if (this.state.showAnswers) {
      output += `<button phx-click="next-question" phx-value-idx=${this.state.questionIndex} style="padding: 24px; text-align: left; border: 1px solid white;">
      Next Question
      </button>`;
    }

    output += `<div style="margin-top: 40px; display: flex; width: 100%; column-gap: 12px; text-align: left">
                <div style="width: 50%; background-color: rgb(255 255 255 / 0.1); padding: 12px">
                  <p style="margin-bottom: 8px">
                    ANSWER STATUS
                  </p>
                  <ul style="font-size: 22px; color: #d8b4fe">`;
    this.players.forEach((p) => {
      output += `<li style="color: #fff">${p} `;
      if (this.state.answers[p] !== undefined) {
        
        if(this.state.showAnswers) { 
          if(this.state.answers[p] == questions[this.state.questionIndex].answerIndex) { 
            output += "&check;"
          } else { 
            output += "&times;"
          }

        } else { 
          output += `<svg
                      xmlns="http://www.w3.org/2000/svg"
                      fill="#fff"
                      viewBox="0 0 24 24"
                      style="margin-left: -4px; margin-right: 12px; display: inline; height: 12px; width: 12px; color: #d8b4fe"
                    >
                      <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    </svg>`;
        }
      } else {
        output += `<span class=`;
      }
      output += `</li>`;
    });
    output += `</ul>
              </div> 
              `;

    output += `<div style="width: 50%; background-color: rgb(255 255 255 / 0.1); padding: 12px">
                <p style="margin-bottom: 8px">
                  GAME INFO
                </p>
                <p>
                  <b>Round:</b> <span style="color: #d8b4fe">${
                    this.state.questionIndex + 1
                  } of ${questions.length}</span>
                </p>
                <hr style="margin-top: 12px; margin-bottom: 12px" />
                <p>
                  <b>Score:</b>
                </p>
                <div style="display: grid; grid-template-columns: repeat(3, minmax(0, 1fr))">`;
    this.players.forEach((p) => {
      output += ` <div>${p} <span style="color: #d8b4fe">${this.score[p]}</span></div>`;
    });
    output += `  </div>
                </div>
              </div>
              </div>`;

    return output;
  }

  renderScoreboard(_assigns) {
    const scores = Object.keys(this.score)
      .map((player) => {
        return `<li>${player} &ndash; ${this.score[player]} points</li>`;
      })
      .join("\n");

    let output = "";
    output += `<div style="width: 100%; background-image: linear-gradient(to bottom, var(--tw-gradient-stops)); --tw-gradient-from: #9333ea; --tw-gradient-stops: var(--tw-gradient-from), var(--tw-gradient-to); --tw-gradient-to: #6b21a8; padding-left: 24px; padding-right: 24px; padding-top: 12px; padding-bottom: 12px; font-size: 30px">
                  Guess the Song: <b>Imagine Dragons</b>
               </div>`;
    output += `<div style="display: flex; height: 100%; min-height: 42rem; flex-direction: column; align-items: center; justify-content: flex-start; border-width: 4px; border-color: #581c87; background-image: url('http://amymurphy.tech/images/idbg.jpg'); padding: 24px; padding-top: 40px; font-size: 28px;">`;
    output += scores;
    output += `</div>`;
    return output;
  }

  handleEvent(event) {
    // if (event.event_name !== "answer-prompt") throw Error("unknown event");
    switch (event.event_name) {
      case "answer-prompt":
        {
          const assigns = this.handleAnswerPrompt(event);
          if (Object.keys(this.state.answers).length === this.players.length) {
            this.nextState();
          }
          return assigns;
        }
        break;
      case "next-question":
        {
          const assigns = this.handleNextQuestion(event);
          this.nextState();
          return assigns;
        }
        break;
    }
  }

  handleAnswerPrompt(event) {
    const assigns = { player_id: event.player_id };
    if (this.state.name !== "prompting") return assigns;
    this.state.answers[event.player_id] = parseInt(event.value.idx, 10);
    this.version += 1;

    return assigns;
  }

  handleNextQuestion(event) {
    const assigns = { player_id: event.player_id };

    if (this.state.questionIndex >= questions.length - 1) {
      this.finish();
    } else {
      this.state = {
        name: "prompting",
        questionIndex: this.state.questionIndex + 1,
        showAnswers: false,
        answers: {},
      };
    }

    this.version += 1;

    return assigns;
  }

  nextState() {
    switch (this.state.name) {
      case "prompting": {
        // if everyone has answered
        if (Object.keys(this.state.answers).length === this.players.length) {
          this.recordScore();

          this.state.showAnswers = true;
          // this.state = {
          //       name: "showAnswers",
          //       // questionIndex: this.state.questionIndex + 1,
          //       // answers: {},
          //     };
          // }
        }
        break;
      }

      case "done": {
        break;
      }
    }
  }

  // async setNextQuestion() {
  //   console.log("Start");
  //   await new Promise(done => setTimeout(() => done(), 5000));
  //   this.state = {
  //     name: "prompting",
  //     questionIndex: this.state.questionIndex + 1,
  //     answers: {},
  //   };
  //   this.showLoading = false;
  //   // console.log("End");
  // }

  // setNextQuestion() {
  //   // setTimeout(this.setNextQuestion.bind(this), 4000);

  //   this.version += 1;
  // }

  recordScore() {
    if (this.state.name !== "prompting")
      throw Error("Expected to be in prompting state");

    const answer = questions[this.state.questionIndex].answerIndex;
    const answers = this.state.answers;

    Object.keys(answers).forEach((player) => {
      if (answers[player] === answer) {
        this.score[player] += 1;
      }
    });
  }

  finish() {
    this.state = { name: "done" };
  }
}
