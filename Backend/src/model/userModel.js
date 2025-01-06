const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  googleId: { type: String },
  name: { type: String },
  photo: { type: String },
  verified: { type: Boolean, default: false },
  verificationToken: { type: String },
  gameUsername: { type: String, unique: true, sparse: true }, //unique but allow null
});

module.exports = mongoose.model("User", userSchema);
