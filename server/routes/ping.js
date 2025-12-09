// server/routes/ping.js
const express = require("express");
const pingRouter = express.Router();

pingRouter.get("/ping", (req, res) => {
  res.status(200).json({ message: "pong" });
});

module.exports = pingRouter;