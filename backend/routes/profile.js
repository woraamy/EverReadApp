// profile.js
const express = require('express');
const multer = require('multer');
const { storage } = require('../cloudinary');
const User = require('../models/User');

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

module.exports = router;
