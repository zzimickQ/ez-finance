import express, { Request, Response } from "express";
import cors from "cors";
import { connectDB } from "./db";
import apiRouter from "./routes";

export async function main() {
  try {
    await connectDB();

    const app = express().use(cors());

    app.get("/health", (req: Request, res: Response) => {
      res.json({
        status: "ok",
        uptime: process.uptime().toFixed(0) + "s",
        timestamp: new Date().toISOString(),
      });
    });

    app.use("/api", apiRouter);

    const port = process.env.PORT || 3000;
    app.listen(port, () => {
      console.log(`Server running at http://localhost:${port}`);
    });
  } catch (error) {
    console.error("Fatal Error: ");
    console.error(error);
  }
}
