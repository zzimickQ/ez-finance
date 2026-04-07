import { Router } from "express";
import expensesRouter from "./expenses";

const apiRouter = Router();
apiRouter.use("/expenses", expensesRouter);

export default apiRouter;
