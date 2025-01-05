const express = require("express");
const { setGameUsername } = require("../controller/usernameController");

const router = express.Router();

// Route to set game username
router.post("/set-username", setGameUsername);

module.exports = router;
