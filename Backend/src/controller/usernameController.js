const User = require("../model/userModel");

exports.setGameUsername = async (req, res) => {
  const { userId, gameUsername } = req.body;

  try {
    // Check if the gameUsername already exists
    const existingUser = await User.findOne({ gameUsername });
    if (existingUser) {
      return res
        .status(400)
        .json({ message: "Game username is already taken" });
    }

    // Update user's game username
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    user.gameUsername = gameUsername;
    await user.save();

    res.status(200).json({ message: "Game username set successfully", user });
  } catch (error) {
    res.status(500).json({ message: "Server error", error });
  }
};
