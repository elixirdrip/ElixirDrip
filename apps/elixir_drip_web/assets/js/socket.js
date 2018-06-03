import {Socket} from "phoenix"

let socket = new Socket("/socket", {
  params: {token: window.userToken},
  logger: (type, message, data) => { console.log(`${type}: ${message}`, data) }
})

socket.connect()

export default socket
