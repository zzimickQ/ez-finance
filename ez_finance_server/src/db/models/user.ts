import mongoose, { SchemaTypes } from "mongoose";

const { String, Date, Boolean, Number } = SchemaTypes;

export interface IUser {
  email: string;
  password: string;
  createdAt: Date;
  updatedAt: Date;
}

const userSchema = new mongoose.Schema<IUser>(
  {
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
  },
  { timestamps: true },
);

export const UserModel = mongoose.model<IUser>("User", userSchema);
