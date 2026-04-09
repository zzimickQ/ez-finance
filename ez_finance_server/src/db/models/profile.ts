import mongoose, { SchemaTypes, Types } from "mongoose";

const { String, Date, Boolean, Number } = SchemaTypes;

export interface IProfile {
  userId: Types.ObjectId;
  firstName?: string;
  lastName?: string;
  phone?: string;
  address?: string;
  dateOfBirth?: Date;
  createdAt: Date;
  updatedAt: Date;
}

const profileSchema = new mongoose.Schema<IProfile>(
  {
    userId: { type: SchemaTypes.ObjectId, required: true },
    firstName: { type: String },
    lastName: { type: String },
    phone: { type: String },
    address: { type: String },
    dateOfBirth: { type: Date },
  },
  { timestamps: true },
);

export const ProfileModel = mongoose.model<IProfile>("Profile", profileSchema);
