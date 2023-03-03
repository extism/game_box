import {Game} from './game.js'

jest.mock('./game')

describe("Game", () => {
  const game = new Game();

  test("defines handleEvent()", () => { 
    expect(typeof game.handleEvent ).toBe("function");
  });


});
