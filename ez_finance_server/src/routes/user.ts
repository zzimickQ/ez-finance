import { Router, Response } from "express";
import { IProfile, ProfileModel } from "../db";
import { authMiddleware, AuthRequest } from "../middleware/auth";
import { HydratedDocument } from "mongoose";

const userRouter = Router();

function formatProfileResponse(profile: HydratedDocument<IProfile>) {
  return {
    id: profile._id,
    userId: profile.userId,
    firstName: profile.firstName,
    lastName: profile.lastName,
    phone: profile.phone,
    address: profile.address,
    dateOfBirth: profile.dateOfBirth,
    createdAt: profile.createdAt,
    updatedAt: profile.updatedAt,
  };
}

userRouter.get("/profile", authMiddleware, async (req: AuthRequest, res) => {
  try {
    const profile = await ProfileModel.findOne({ userId: req.userId });

    if (!profile) {
      return res.status(404).json({ error: "Profile not found" });
    }

    res.json(formatProfileResponse(profile));
  } catch (error) {
    res.status(500).json({ error: "Failed to get profile" });
  }
});

userRouter.get(
  "/profile/:id",
  authMiddleware,
  async (req: AuthRequest, res) => {
    try {
      const profile = await ProfileModel.findOne({ userId: req.params.id });

      if (!profile) {
        return res.status(404).json({ error: "Profile not found" });
      }

      res.json(formatProfileResponse(profile));
    } catch (error) {
      res.status(500).json({ error: "Failed to get profile" });
    }
  },
);

const updateHandler = async (req: AuthRequest, res: Response) => {
  try {
    const { firstName, lastName, phone } = req.body;

    const userId = req.params.id ?? req.userId;

    const profile = await ProfileModel.findOneAndUpdate(
      { userId },
      {
        userId,
        firstName,
        lastName,
        phone,
      },
      { new: true, upsert: true, setDefaultsOnInsert: true },
    );

    if (!profile) {
      return res.status(404).json({ error: "Profile not found" });
    }

    res.json(formatProfileResponse(profile));
  } catch (error) {
    res.status(500).json({ error: "Failed to update profile" });
  }
};

userRouter.post("/profile/:id", authMiddleware, updateHandler);
userRouter.put("/profile/:id", authMiddleware, updateHandler);
userRouter.post("/profile", authMiddleware, updateHandler);
userRouter.put("/profile", authMiddleware, updateHandler);

export default userRouter;
