import jwt from "jsonwebtoken";
import { Types } from "mongoose";

/// Constants
const JWT_SECRET: string = process.env.JWT_SECRET ?? "your-secret-key";
const JWT_EXPIRES_IN: string = process.env.JWT_EXPIRES_IN ?? "1h";
const REFRESH_TOKEN_EXPIRES_IN: string =
  process.env.REFRESH_TOKEN_EXPIRES_IN ?? "1m";

export const generateTokens = (userId: string | Types.ObjectId) => {
  const content = { userId };
  const secret = JWT_SECRET;
  const accessToken = jwt.sign(content, secret, {
    expiresIn: JWT_EXPIRES_IN as any,
  });
  const refreshToken = jwt.sign(content, secret, {
    expiresIn: REFRESH_TOKEN_EXPIRES_IN as any,
  });
  return { accessToken, refreshToken };
};

export const verifyAndDecodeToken = (token: string) => {
  return jwt.verify(token, JWT_SECRET) as { userId: string };
};
