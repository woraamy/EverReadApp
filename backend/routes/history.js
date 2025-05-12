const express = require('express');
const router = express.Router();
const { body, query, validationResult } = require('express-validator');
const History = require('../models/History'); 
const User = require('../models/User'); 
const Review = require('../models/Review'); 

// GET /api/history/get
// Get all history of logged-in user
router.get('/get', async (req, res, next) => {
  try {
    if (!req.user || !req.user.userId) {
      return res.status(401).json({ error: 'User not authenticated or userId missing from token.' });
    }

    const user_id = req.user.userId;

    // Find history documents where user_id matches
    const history = await History.find({ user_id }).populate('user_id', 'username').sort({ createdAt: -1 });

    if (!history || history.length === 0) {
      return res.status(404).json({ error: 'No history found for this user.' });
    }

    const formattedHistory = history.map(h => {
      const historyObj = h.toObject();

      const createdAtDate = new Date(historyObj.created_at);
      const today = new Date();
      const timeDiff = Math.abs(today - createdAtDate);
      const daysAgo = Math.floor(timeDiff / (1000 * 60 * 60 * 24));

      return {
        ...historyObj,
        username: historyObj.user_id?.username || 'Unknown',
        user_id: historyObj.user_id?._id || null,
        daysAgo
      };
 
    })
    res.status(200).json(formattedHistory);
  } catch (err) {
    next(err);
  }
});

module.exports = router;