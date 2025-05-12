const express = require('express');
const router = express.Router();
const { query, validationResult } = require('express-validator');
const History = require('../models/History');
const User = require('../models/User');
const Review = require('../models/Review');
const Follow = require('../models/Follow');

// GET /api/feed/getReview
router.get('/getReview', async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    if (!req.user || !req.user.userId) {
      return res.status(401).json({ error: 'User not authenticated or userId missing from token.' });
    }

    const userId = req.user.userId;

    const followingList = await Follow.find({ following_user_id: userId }).select('followed_user_id') || [];
    const followingIds = followingList.map(f => f.followed_user_id);

    const followedReview = await Review.find({ user_id: { $in: followingIds } })
      .populate('user_id', 'username')
      .sort({ createdAt: -1 });

    const excludedIds = [...followingIds.map(id => id.toString()), userId];
    const recentReviews = await Review.find({ user_id: { $nin: excludedIds } })
      .populate('user_id', 'username')
      .sort({ createdAt: -1 })
      .limit(20);

    const combinedFeed = [...followedReview, ...recentReviews];
    combinedFeed.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

    const formattedReviews = combinedFeed.map(review => {
      const r = review.toObject();
      return {
        ...r,
        username: r.user_id?.username || 'Unknown',
        user_id: r.user_id?._id || null
      };
    });

    res.status(200).json(formattedReviews);
  } catch (err) {
    next(err);
  }
});


// GET /api/feed/getHistory
router.get('/getHistory', async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    if (!req.user || !req.user.userId) {
      return res.status(401).json({ error: 'User not authenticated or userId missing from token.' });
    }

    const userId = req.user.userId;

    const followingList = await Follow.find({ following_user_id: userId }).select('followed_user_id') || [];
    const followingIds = followingList.map(f => f.followed_user_id);

    const followedHistory = await History.find({ user_id: { $in: followingIds } })
      .populate('user_id', 'username')
      .sort({ createdAt: -1 });

    const formattedHistory = followedHistory.map(h => {
      const historyObj = h.toObject();
      return {
        ...historyObj,
        username: historyObj.user_id?.username || 'Unknown',
        user_id: historyObj.user_id?._id || null
      };
    });

    res.status(200).json(formattedHistory);
  } catch (err) {
    next(err);
  }
});

module.exports = router;