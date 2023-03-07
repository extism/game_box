import { getDeck } from "./cards";

const deck = getDeck();

export class Game {
  constructor(state) {
    this.players = state.players;
    this.version = state.version || 0;
    this.deck = state.deck || deck;
    this.gamewinner = state.gamewinner || "";
    if (state.score) {
      this.score = state.score;
    } else {
      this.score = {};
      this.players.forEach((p) => (this.score[p] = 0));
    }
    if (state.playerDecks) {
      this.playerDecks = state.playerDecks;
    } else {
      this.playerDecks = {};
      this.players.forEach((p) => (this.playerDecks[p] = []));
      this.dealCards();
    }
    this.state = state.state || {
      phase: "playRound",
      round: 0,
      answers: {},
      winner: "",
    };
  }

  dealCards() {
    for (let i = 0; i < 8; i = i + 2) {
    // for (let i = 0; i < this.deck.length; i = i + 2) {
      let card_count = i;

      this.players.forEach((player) => {
        this.playerDecks[player].push(this.deck[card_count]);
        card_count++;
      });
    }

    // return assigns;
  }

  render(assigns) {
    switch (this.state.phase) {
      case "playRound": {
        return this.renderRound(assigns);
      }
      case "done": {
        return this.renderScoreboard(assigns);
      }
    }
  }

  renderRound(assigns) {
    let output = "";
   
    output += `<div style="width: 100%; background-color: #000; padding: 24px; color: #fff; font-family: "Helvetica, Arial, sans">`;
    output += `<h1 style="font-size: 30px">WAR</h1>`;

    output += `<div
                style="
                  margin-top: 12px;
                  margin-bottom: 12px;
                  display: flex;
                  width: 100%;
                  justify-content: space-between;
                  background-color: #581c87;
                  padding: 12px;
                "
              >
                <div>`;

    this.players.forEach((p) => {
      output += `${p}: ${this.score[p]} &nbsp;`;
    });

    output += `</div>
                <div>Round ${this.state.round + 1} of ${
      this.deck.length / 2
    }</div>
              </div>`;

    output += `<div style="display: flex; width: 100%">`;

    this.players.forEach((p) => {
      output += ` <div
                   style="
                      width: 50%;
                      flex: 1 1 0%;
                      padding-right: 40px;
                   "
                  >`;
      if (p == assigns.player_id) {
        output += `<p style="margin-bottom: 4px;">Your Board:</p>\n`;
      } else {
        output += `<p style="margin-bottom: 4px;">${p}'s Board:</p>\n`;
      }

      if (
        this.state.answers[p] &&
        this.state.answers[p] == this.playerDecks[p][this.state.round].value
      ) {
        let color = ``
        if(this.playerDecks[p][this.state.round].suit == "&diams;" || this.playerDecks[p][this.state.round].suit == "&hearts;") { 
           color = `#DC2626`;
        } else { 
           color = `#000`;
        }
        
        output += `<div
                    style="
                      display: flex;
                      height: 420px;
                      width: 320px;
                      flex-direction: column;
                      justify-content: space-between;
                      border-radius: 4px;
                      background-color: #fff;
                      padding: 16px;
                      font-size: 48px;
                      color: ${color};
                      `;
        if (this.state.winner == p) {
          output += `border-radius: 4px;
                     border-width: 6px;
                     border-color: #22c55e;`;
        }
        output += `"
                  >
                    <div>${this.state.answers[p]} ${this.playerDecks[p][this.state.round].suit}</div>
                    <div
                      style="
                        margin-top: 32px;
                        margin-bottom: 32px;
                        text-align: center;
                        font-size: 128px;
                      "
                    >
                      ${this.playerDecks[p][this.state.round].suit}
                    </div>
                    <div style="text-align: right">${this.state.answers[p]} ${this.playerDecks[p][this.state.round].suit}</div>
                  </div>`;
        if (this.state.winner == p) {
          output += ` <span style="color: #4ade80; font-size: 24px;">WINNER!</span>`;
        }
        if (this.state.winner == "tie") {
          output += ` <span style="color: #FACC15; font-size: 24px;">IT'S A TIE!</span>`;
        }
      } else {
        output += `<div
                    style="
                      display: flex;
                      height: 420px;
                      width: 320px;
                      flex-direction: column;
                      justify-content: space-between;
                      border-radius: 4px;
                      background-color: #fff;
                      padding: 16px;
                      font-size: 48px;
                      color: #1d4ed8;
                    "`;
        if (p == assigns.player_id) {
          output += `phx-click="flip-card" phx-value-player="${assigns.player_id}"`;
        }
        output += `>
                    <div>&#10022;</div>
                   `;
        if (p == assigns.player_id) {
          output += `<div
                          style="
                            margin-top: 96px;
                            margin-bottom: 96px;
                            text-align: center;
                            font-size: 36px;
                            text-decoration-line: underline;
                          "
                        >
                          Flip Card
                        </div>`;
        } else {
          output += `<div
                          style="
                            margin-top: 96px;
                            margin-bottom: 96px;
                            font-size: 24px;
                            font-style: italic;"
                        >
                        Waiting on card flip
                        </div>`;
        }
        output += ` <div style="text-align: right">&#10022;</div>
                  </div>`;
      }

      output += `</div>`;
    });

    output += `</div>`;

    if (this.state.winner) {
      output += `<div style="margin-top: 24px; display: flex; justify-content: start">
                    <button
                        style="
                          display: block;
                          border-radius: 8px;
                          background-color: #a855f7;
                          padding: 8px 20px;
                          color: white;
                        "
                        phx-click="next-round" 
                        phx-value-round="next-round"
                      >
                        Next Round
                      </button>
                  </div>`;
    }

    return output;
  }

  checkGameboardStyle(p, assigns) {
    if (p == assigns.player_id) {
      return "border: 1px solid green;";
    }
    return "border: 1px solid #666;";
  }

  renderScoreboard(_assigns) {
    const scores = Object.keys(this.score)
      .map((player) => {
        return `${player}: ${this.score[player]} `;
      })
      .join("\n");
    // return `<h1>Scoreboard</h1><ul>${scores}</ul>`;

    let output = "";
    output += `<div style="margin-top: 12px; margin-bottom: 12px; display: flex; width: 100%; flex-direction: column; justify-content: center; background-color: #581c87; padding: 12px">
                  <div style="text-align: center; font-size: 96px">`
    if(this.gamewinner == "tie") { 
      output += "TIE!"
    } else { 
      output += `${this.gamewinner} WINS!`
    }          
    output += `</div>
                  <div style="margin-top: 12px; text-align: center; font-size: 30px"><span style="color: #a1a1aa">FINAL SCORE</span> ${scores}</div>
                </div>
                <div style="text-align: center; font-size: 20px; font-style: italic">Host: return to the lobby and select the game again to play another round!</div> 
              `;
    return output;
  }

  handleEvent(event) {
    const assigns = { player_id: event.player_id };
    switch (event.event_name) {
      case "flip-card": {
        if (this.state.round < this.deck.length / 2) {
          this.handleCardFlip(event);
        }
        if (
          this.state.answers &&
          Object.keys(this.state.answers).length === this.players.length
        ) {
          this.compareCards(assigns);
        }
        break;
      }
      case "next-round": {
        if (this.state.round + 1 < this.deck.length / 2) {
          this.handleNextRound();
        } else {
          this.finish();
        }
        break;
      }
    }

    this.version += 1;

    return assigns;
  }

  handleNextRound(assigns) {
    // this.players.forEach(p => { this.state.answers[p] = "" })
    this.state.round += 1;
    this.version += 1;
    this.state.answers = {};
    this.state.winner = "";
    return assigns;
  }

  handleCardFlip(event) {
    const assigns = { player_id: event.player_id };
    if (this.state.phase !== "playRound") return assigns;

    // if there's a value in the player's deck, assign that value as the player's answer
   if(this.playerDecks[event.player_id][this.state.round]) { 
    if (
      this.playerDecks[event.player_id][this.state.round].value &&
      this.playerDecks[event.player_id][this.state.round].value.length
    ) {
      this.state.answers[event.player_id] =
        this.playerDecks[event.player_id][this.state.round].value;
    }
  }

    this.version += 1;

    return assigns;
  }

  isTie(answers) {
    return answers.every((val) => val === answers[0]);
  }

  compareCards(assigns) {
    let answers = [];
    this.players.forEach((p) => {
      this.state.answers[p];
      answers.push(parseInt(this.state.answers[p], 10));
    });
    const isTie = this.isTie(answers);

    let winner = "";
    if (!isTie) {
      const winningAnswer = Math.max(...answers);

      //log score of winner
      Object.keys(this.state.answers).forEach((player, cardValue) => {
        if (
          parseInt(this.state.answers[player], 10) ==
          parseInt(winningAnswer, 10)
        ) {
          this.score[player] += 1;
          winner = player;
        }
      });
    } else {
      winner = "tie";
    }
    this.state.winner = winner;
    this.version += 1;
    return assigns;
  }

  finish() {
    let scores = [];
    Object.keys(this.score).forEach((player, cardValue) => {
      scores.push(parseInt(this.score[player], 10));
    });

    const isTie = this.isTie(scores);

    if (!isTie) {
    const winningScore = Math.max(...scores);
    Object.keys(this.score).forEach((player, cardValue) => {
      if (parseInt(this.score[player], 10) == parseInt(winningScore, 10)) {
        // this.score[player] += 1;
        this.gamewinner = player;
      }
    });
  } else { 
    this.gamewinner = "tie";
  }

    this.state = { phase: "done" };
  }
}
