// server/routes/ping.js
import express from "express";
const pingRouter = express.Router();

pingRouter.get("/ping", (req, res) => {
  res.status(200).json({ message: "pong" });
});

export default pingRouter;