import data from "./data.json"

export interface Question {
  prompt: string,
  options: Array<string>
  answerIndex: number,
}

export function getQuestions(): Array<Question> {
  return data as Array<Question>
}

