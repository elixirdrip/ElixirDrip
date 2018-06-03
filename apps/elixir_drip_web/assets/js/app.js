import "phoenix_html"
import socket from "./socket"

import Notification from "./notification"

Notification.init(socket, window.userId)
