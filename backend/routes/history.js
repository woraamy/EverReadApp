const express = require('express');
const router = express.Router();
const { body, query, validationResult } = require('express-validator');
const History = require('../models/History'); 
const User = require('../models/User'); 
const Review = require('../models/Review'); 

// GET /api/history/getUserHistory
// Get all history of logged-in user
router.get('/getUserHistory', async (req, res, next) => {
  try {
    if (!req.user || !req.user.userId) {
      return res.status(401).json({ error: 'User not authenticated or userId missing from token.' });
    }

    const user_id = req.user.userId;

    // Find history documents where user_id matches
    const history = await History.find({ user_id }).sort({ createdAt: -1 });

    if (!history || history.length === 0) {
      return res.status(404).json({ error: 'No history found for this user.' });
    }

    res.status(200).json(history);
  } catch (err) {
    next(err);
  }
});

module.exports = router;