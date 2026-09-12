import { createRoot } from "react-dom/client"
import App from "../components/App"

const appDiv = document.getElementById("app")
if (!appDiv) {
  throw new Error("Could not find #app element to mount React")
}

const root = createRoot(appDiv)
root.render(<App />)
