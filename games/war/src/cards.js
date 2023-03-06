// import data from "./data.json"


export function getDeck() { 
  const suits = ["hearts", "diamonds", "spades", "clubs"]
  const values = [
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "11",
    "12",
    "13",
    "14"
  ];

  let deck = []
 
  for (let i = 0; i < suits.length; i++) {
    for (let x = 0; x < values.length; x++) {
        let card = { value: values[x], suit: suits[i] };
        deck.push(card);
    }
  }
  
  // shuffle the cards
  for (let i = deck.length - 1; i > 0; i--) {
      let j = Math.floor(Math.random() * i);
      let temp = deck[i];
      deck[i] = deck[j];
      deck[j] = temp;
  }
  
  return deck; 
  
}


// export function getDeck() {
//   return populate_deck(); 
// }

