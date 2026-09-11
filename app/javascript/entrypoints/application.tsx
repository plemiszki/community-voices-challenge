import React from "react";
import { createRoot } from "react-dom/client";

const appDiv = document.getElementById("app");
const root = createRoot(appDiv);
root.render(<p>Hello from React!</p>);
