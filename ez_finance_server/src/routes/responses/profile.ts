import { HydratedDocument } from "mongoose";
import { IProfile } from "../../db";

export function formatProfileResponse(profile: HydratedDocument<IProfile>) {
  return {
    id: profile._id,

    firstName: profile.firstName,
    lastName: profile.lastName,
    phone: profile.phone,
  };
}
