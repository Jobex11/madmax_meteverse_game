const express = require("express");
const passport = require("passport");
const authController = require("../controllers/authController");

const router = express.Router();

// Home route
router.get("/", authController.homePage);

// Google OAuth routes
router.get(
  "/auth/google",
  passport.authenticate("google", { scope: ["profile", "email"] })
);

router.get(
  "/auth/google/callback",
  passport.authenticate("google", { failureRedirect: "/" }),
  authController.googleCallback
);

// Profile route
router.get("/profile", authController.profilePage);

// Logout route
router.get("/auth/logout", authController.logout);

module.exports = router;
