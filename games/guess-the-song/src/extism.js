
export function inputJson() {
  const input = Host.inputString()
  return JSON.parse(input)
}

export function outputJson(obj) {
  const payload = JSON.stringify(obj)
  Host.outputString(payload)
}

export function outputString(str) {
  Host.outputString(str)
}

export function setState(obj) {
  const payload = JSON.stringify(obj)
  Var.set('state', payload)
}

export function getState() {
  const payload = Var.getString('state')
  if (!payload) throw Error("no state")
  return JSON.parse(payload)
}
