import { Router } from "express";
import { ProfileModel } from "../db";
import { authMiddleware, AuthRequest } from "../middleware/auth";

const userRouter = Router();

function formatProfileResponse(profile: any) {
  return {
    id: profile._id,
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
    const profile = await ProfileModel.findById(req.userId);

    if (!profile) {
      return res.status(404).json({ error: "Profile not found" });
    }

    res.json(formatProfileResponse(profile));
  } catch (error) {
    res.status(500).json({ error: "Failed to get profile" });
  }
});

userRouter.get("/profile/:id", authMiddleware, async (req: AuthRequest, res) => {
  try {
    const profile = await ProfileModel.findById(req.params.id);

    if (!profile) {
      return res.status(404).json({ error: "Profile not found" });
    }

    res.json(formatProfileResponse(profile));
  } catch (error) {
    res.status(500).json({ error: "Failed to get profile" });
  }
});

userRouter.post("/profile", authMiddleware, async (req: AuthRequest, res) => {
  try {
    const existingProfile = await ProfileModel.findById(req.userId);
    if (existingProfile) {
      return res.status(409).json({ error: "Profile already exists" });
    }

    const { firstName, lastName, phone, address, dateOfBirth } = req.body;

    const profile = new ProfileModel({
      _id: req.userId,
      firstName,
      lastName,
      phone,
      address,
      dateOfBirth: dateOfBirth ? new Date(dateOfBirth) : undefined,
    });

    await profile.save();

    res.status(201).json(formatProfileResponse(profile));
  } catch (error) {
    res.status(500).json({ error: "Failed to create profile" });
  }
});

userRouter.put("/profile", authMiddleware, async (req: AuthRequest, res) => {
  try {
    const {
      firstName,
      lastName,
      phone,
      address,
      dateOfBirth,
    } = req.body;

    const profile = await ProfileModel.findByIdAndUpdate(
      req.userId,
      {
        $set: {
          ...(firstName !== undefined && { firstName }),
          ...(lastName !== undefined && { lastName }),
          ...(phone !== undefined && { phone }),
          ...(address !== undefined && { address }),
          ...(dateOfBirth !== undefined && { dateOfBirth: new Date(dateOfBirth) }),
        },
      },
      { new: true },
    );

    if (!profile) {
      return res.status(404).json({ error: "Profile not found" });
    }

    res.json(formatProfileResponse(profile));
  } catch (error) {
    res.status(500).json({ error: "Failed to update profile" });
  }
});

userRouter.patch("/profile", authMiddleware, async (req: AuthRequest, res) => {
  try {
    const updates: Record<string, any> = {};
    const allowedFields = ["firstName", "lastName", "phone", "address", "dateOfBirth", "isSynced"];

    for (const field of allowedFields) {
      if (req.body[field] !== undefined) {
        if (field === "dateOfBirth" && req.body[field]) {
          updates[field] = new Date(req.body[field]);
        } else {
          updates[field] = req.body[field];
        }
      }
    }

    if (Object.keys(updates).length === 0) {
      return res.status(400).json({ error: "No valid fields to update" });
    }

    const profile = await ProfileModel.findByIdAndUpdate(
      req.userId,
      { $set: updates },
      { new: true },
    );

    if (!profile) {
      return res.status(404).json({ error: "Profile not found" });
    }

    res.json(formatProfileResponse(profile));
  } catch (error) {
    res.status(500).json({ error: "Failed to update profile" });
  }
});

export default userRouter;
