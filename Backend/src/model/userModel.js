const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  verified: { type: Boolean, default: false },
  verificationToken: { type: String },
  gameUsername: { type: String, unique: true, sparse: true }, //unique but allow null
});

module.exports = mongoose.model("User", userSchema);