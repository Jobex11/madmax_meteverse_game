//server.js

const express = require("express");
const bodyParser = require("body-parser");
const mongoose = require("mongoose");
const passport = require("passport");
const oauth2orize = require("oauth2orize");

const app = express();
app.use(bodyParser.json());

// Database setup
mongoose.connect("mongodb://localhost:27017/oauth-server", {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

// Passport configuration
require("./config/passport");

// Routes
const oauth2Routes = require("./routes/index");
app.use("/oauth2", oauth2Routes);

app.listen(3000, () => {
  console.log("OAuth server is running on port 3000");
});
