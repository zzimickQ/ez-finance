import cors from "cors";
import express, { Request, Response } from "express";
import { connectDB } from "./db";
import apiRouter from "./routes";

export async function main() {
  try {
    await connectDB();

    const app = express().use(cors());

    app.use(express.json());

    app.use((req: Request, res: Response, next) => {
      res.on("finish", () => {
        console.log(
          `[${new Date().toLocaleString()}] ${req.method} ${res.statusCode} ${req.originalUrl}`
        );
      });
      next();
    });

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
