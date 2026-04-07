import mongoose, { SchemaTypes } from "mongoose";
const { Number, Date } = SchemaTypes;

const schema = new mongoose.Schema({
  amount: { type: Number, required: true },
  createdAt: { type: Date, required: true },
});

export const ExpenseModel = mongoose.model("Expense", schema);
