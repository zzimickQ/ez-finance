import mongoose from "mongoose";

export const connectDB = async () => {
  await mongoose.connect(
    process.env.MONGO_URI ?? "mongodb://localhost:27017/ez_finance",
  );
  console.log("Connected to MongoDB");
};
