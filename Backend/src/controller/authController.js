const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");
const nodemailer = require("nodemailer");
const User = require("../model/userModel");

exports.homePage = (req, res) => {
  res.send('<h1>Home</h1><a href="/auth/google">Login with Google</a>');
};

exports.googleLogin = (req, res, next) => {
  next(); // Pass control to Passport middleware
};

exports.googleCallback = (req, res) => {
  res.redirect("/profile");
};

exports.profilePage = (req, res) => {
  if (!req.isAuthenticated()) {
    return res.redirect("/");
  }
  res.send(
    `<h1>Profile</h1><pre>${JSON.stringify(
      req.user,
      null,
      2
    )}</pre><a href="/auth/logout">Logout</a>`
  );
};

exports.logout = (req, res) => {
  req.logout(() => res.redirect("/"));
};
