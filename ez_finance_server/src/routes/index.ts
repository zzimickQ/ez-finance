import express, { Router } from "express";
import authRouter from "./auth";
import expensesRouter from "./expenses";
import userRouter from "./user";

const apiRouter = Router();

apiRouter.use(express.json());

apiRouter.use("/expenses", expensesRouter);
apiRouter.use("/auth", authRouter);
apiRouter.use("/user", userRouter);

export default apiRouter;
