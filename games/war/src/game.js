import { getDeck } from "./cards";

const deck = getDeck();

export class Game {
  constructor(state) {
    this.players = state.players
    this.version = state.version || 0
    this.deck = state.deck || deck
    if (state.score) {
      this.score = state.score
    } else {
      this.score = {};
      this.players.forEach((p) => (this.score[p] = 0))
    }
    if (state.playerDecks) {
      this.playerDecks = state.playerDecks
    } else {
      this.playerDecks = {};
      this.players.forEach((p) => (this.playerDecks[p] = []))
      this.dealCards();
    }
    this.state = state.state || { phase: "playRound", round: 0, answers: {}, winner: "" };
  }

  dealCards(assigns) {
    for (let i = 0; i < this.deck.length; i = i + 2) {
      let card_count = i;

      this.players.forEach((player) => {
        this.playerDecks[player].push(this.deck[card_count]);
        card_count++;
      });
    }

    return assigns;
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
    output += `<h1>Welcome to War!</h1> Round: ${this.state.round} <hr>`;

    output += `<div style="display: flex; flex-direction: row; width: 100%;">`;
    this.players.forEach((p) => {
      output += `<div style="width: 50%; ${this.checkGameboardStyle(
        p,
        assigns
      )}">`;

      if (p == assigns.player_id) {
        output += `Your Cards Here`;
      } else {
        output += `${p}'s Cards Here`;
      }
      // if (this.state.answers[p] == this.playerDecks[p][this.state.round]["value"]) {
      if(this.state.answers[p]) {
        output += "<p>Flipped Card: <b>" + this.state.answers[p] + "</b></p>";
      }
      // } else {
      //   output += "Waiting on Card Flip";
      // }
      output += `</div>`;
    })

    output += `</div>`;

    if (
      this.state.answers[assigns.player_id] !=
      this.playerDecks[assigns.player_id][this.state.round]["value"]
    ) {
      output += `<div style="text-align: center"><button style="padding: 5px; border: 1px solid purple;" phx-click="flip-card" phx-value-player="${assigns.player_id}">Flip Card ${assigns.player_id}</button></div>`;
    } else {
      output += "Waiting on other player to flip a card"
    }

    if(this.state.winner) { 
      output +=  `<hr> The winner is: <b>${this.state.winner}`
      output += `<div style="text-align: center"><button style="padding: 5px; border: 1px solid purple;" phx-click="next-round" phx-value-round="${this.state.round}">Next Round</button></div>`;
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
        return `<li>${this.score[player]} ${player}</li>`;
      })
      .join("\n");
    return `<h1>Scoreboard</h1><ul>${scores}</ul>`;
  }

  handleEvent(event) {
    // if (event.event_name !== "flip-card") throw Error("unknown event");
    let assigns = ""; 
    switch (event.event_name) {
      case "flip-card": {
        assigns = this.handleCardFlip(event);
        if (Object.keys(this.state.answers).length === this.players.length) {
          this.compareCards()
        }
      }
      case "next-round": {
        assigns = this.handleNextRound();
      }
    }

    // this.version += 1
    // console.log(`VERSION: ${this.version}`)

    return assigns;
  }

  handleNextRound() {  
    this.state.round += 1; 
  }

  handleCardFlip(event) {
    const assigns = { player_id: event.player_id };
    if (this.state.phase !== "playRound") return assigns;

    // if there's a value in the player's deck, assign that value as the player's answer
    if (this.playerDecks[event.player_id][this.state.round].value.length) {
      this.state.answers[event.player_id] =
        this.playerDecks[event.player_id][this.state.round]["value"];
    }

    return assigns;
  }


  compareCards() {
    let answers = [];
    this.players.forEach((p) => {
      this.state.answers[p];
      answers.push(parseInt(this.state.answers[p], 10))
    });

    const winningAnswer = Math.max(...answers);
    let winner = "";
    //log score of winner
    Object.keys(this.state.answers).forEach((player, cardValue) => {
      if (
        parseInt(this.state.answers[player], 10) == parseInt(winningAnswer, 10)
      ) {
        this.score[player] += 1
        const winner = player
      }
    });

    this.state.winner = winner

  }

  finish() {
    this.state = { name: "done" };
  }
}
