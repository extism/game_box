
export function inputJson(): any {
  //@ts-ignore
  const input: string = Host.inputString()
  return JSON.parse(input)
}

export function outputJson(obj: any) {
  const payload = JSON.stringify(obj)
  //@ts-ignore
  Host.outputString(payload)
}

export function outputString(str: string) {
  //@ts-ignore
  Host.outputString(str)
}

export function setState(obj: any) {
  const payload = JSON.stringify(obj)
  //@ts-ignore
  Var.set('state', payload)
}

export function getState(): any {
  //@ts-ignore
  const payload = Var.getString('state')
  if (!payload) throw Error("no state")
  return JSON.parse(payload)
}
