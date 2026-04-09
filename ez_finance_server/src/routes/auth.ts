import bcrypt from "bcryptjs";
import { Router } from "express";
import jwt from "jsonwebtoken";
import { Types } from "mongoose";
import { ProfileModel, UserModel } from "../db";
import { authMiddleware, AuthRequest } from "../middleware/auth";
import StatusCodes from "http-status-codes";
import { formatProfileResponse } from "./responses";
import * as utils from "../utils";

const authRouter = Router();

authRouter.post("/register", async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: "Email and password required" });
    }

    const existingUser = await UserModel.findOne({ email });

    if (existingUser) {
      return res.status(409).json({ error: "Email already in use" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const newUser = new UserModel({
      email,
      password: hashedPassword,
    });

    await newUser.save();

    const tokens = utils.generateTokens(newUser._id);

    res.status(StatusCodes.CREATED).json({
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      user: {
        id: newUser._id,
        email,
      },
    });
  } catch (error) {
    res.status(500).json({ error: "Registration failed" });
  }
});

authRouter.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: "Email and password required" });
    }

    const user = await UserModel.findOne({ email });

    if (!user) {
      return res.status(401).json({ error: "Invalid credentials" });
    }

    const isValid = await bcrypt.compare(password, user.password);

    if (!isValid) {
      return res.status(401).json({ error: "Invalid credentials" });
    }

    const profile = await ProfileModel.findOne({ _id: user._id });
    const tokens = utils.generateTokens(user._id);

    res.json({
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      user: {
        id: user._id,
        email: user.email,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
        profile: profile ? formatProfileResponse(profile) : null,
      },
    });
  } catch (error) {
    res.status(500).json({ error: "Login failed" });
  }
});

authRouter.post("/logout", authMiddleware, async (_req, res) => {
  res.json({ message: "Logged out successfully" });
});

authRouter.post("/refresh", async (req, res) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({ error: "Refresh token required" });
    }

    const decoded = utils.verifyAndDecodeToken(refreshToken);
    const tokens = utils.generateTokens(decoded.userId);

    res.json({
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    });
  } catch {
    return res.status(401).json({ error: "Invalid refresh token" });
  }
});

authRouter.get("/me", authMiddleware, async (req: AuthRequest, res) => {
  try {
    const user = await UserModel.findById(req.userId);
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    const profile = await ProfileModel.findById(req.userId);

    res.json({
      id: user._id,
      email: user.email,
      profile: profile ? formatProfileResponse(profile) : null,
    });
  } catch (error) {
    res.status(500).json({ error: "Failed to get user" });
  }
});

export default authRouter;
