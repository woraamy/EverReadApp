const express = require('express');
const User = require('../../models/User');
const router = express.Router();
const argon2 = require('argon2');
// POST /api/auth/register - Add a new user
router.post('/', async (req, res, next) => {
  try {
    const { username, password, correctpassword, email} = req.body;

    if (!username || !password || !correctpassword || !email) {
        return res.status(400).json({ error: "All fields are required" });
      }
    
    if (password !== correctpassword) {
    return res.status(400).json({ error: "Passwords do not match" });
    }

    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(409).json({ error: "Email already registered" });
    }

    const hashedPassword = await argon2.hash(password);
    const newUser = new User({
        username,
        email,
        password: hashedPassword,
        yearly_goal: 0,
        month_goal: 0,
      });

      const savedUser = await newUser.save();

      res.status(201).json({
        message: "User registered successfully",
        userId: savedUser._id,
        username: savedUser.username,
        email: savedUser.email
      });
  } catch (err) {
    next(err); 
  }
});

module.exports = router;