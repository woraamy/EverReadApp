// profile.js
const express = require('express');
const multer = require('multer');
const { storage } = require('../cloudinary');
const User = require('../models/User');
const { body, query, validationResult } = require('express-validator');
const router = express.Router(); 

const upload = multer({ storage });

router.post('/upload', upload.single('profile'), async (req, res) => {
  try {
    const userId = req.user.userId;
    const imageUrl = req.file.path; // Cloudinary URL

    // Update and return updated user
    const updatedUser = await User.findByIdAndUpdate(
      userId,
      { profile_img: imageUrl },
      { new: true } // return the updated document
    );
    if (!updatedUser) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.json({ message: 'Uploaded successfully', user: updatedUser});
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Upload failed' });
  }
});

// PUT /api/profile/name
router.put('/name',
  [body('username', 'new username is required').not().isEmpty().trim()], 
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      if (!req.user || !req.user.userId) {
        return res.status(401).json({ error: 'User not authenticated or userId missing from token.' });
      }

      const { username } = req.body;
      const updatedUser = await User.findByIdAndUpdate(
        req.user.userId,
        { username },
        { new: true }
      );

      res.status(200).json({
        message: "Update username successfully",
        username: updatedUser.username
      });
    } catch (err) {
      next(err);
    }
});

// PUT /api/profile/bio
router.put('/bio',
  [body('bio', 'new bio is required').not().isEmpty().trim()], 
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      if (!req.user || !req.user.userId) {
        return res.status(401).json({ error: 'User not authenticated or userId missing from token.' });
      }

      const { bio } = req.body;
      const updatedUser = await User.findByIdAndUpdate(
        req.user.userId,
        { bio },
        { new: true }
      );

      res.status(200).json({
        message: "Update bio successfully",
        bio: updatedUser.bio
      });
    } catch (err) {
      next(err);
    }
});

module.exports = router;
