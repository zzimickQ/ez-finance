import { Router } from "express";
import { ExpenseModel } from "../db";
const expensesRouter = Router();

expensesRouter.get("/", async (req, res) => {
  const expenses = await ExpenseModel.find({});
  res.json(expenses);
});

export default expensesRouter;
