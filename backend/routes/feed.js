const express = require('express');
const router = express.Router();
const { query, validationResult } = require('express-validator');
const History = require('../models/History');
const User = require('../models/User');
const Review = require('../models/Review');
const Follow = require('../models/Follow');

// GET /api/feed/getReview
router.get('/getReview',
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      if (!req.user || !req.user.userId) {
        return res.status(401).json({ error: 'User not authenticated or userId missing from token.' });
      }

      const userId = req.user.userId;

      // Step 1: Get the current user's following list
     
      const followingList = await Follow.find({following_user_id: userId}).select('followed_user_id') || [];
      const followingIds = followingList.map(follow => follow.followed_user_id);
      console.log(followingIds)
      // Step 2: Get Review history of followed users for this book
      const followedReview = await Review.find({
        user_id: { $in: followingIds }
      })
        .sort({ createAt: -1 });

      // Step 3: Get latest reviews from non-followed users
      const excludedIds = [...followingIds.map(id => id.toString()), userId];

      const recentReviews = await Review.find({
        user_id: { $nin: excludedIds }
      })
        .sort({ createdAt: -1 })
        .limit(20); // limit for performance

      
      // Step 4: Combine both followed and recent reviews
      const combinedFeed = [...followedReview, ...recentReviews];

      // Sort combined feed by creation date
      combinedFeed.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

      res.status(200).json(combinedFeed);

    } catch (err) {
      next(err);
    }
  }
);
module.exports = router;

// GET /api/feed/getHistory
router.get('/getHistory',
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      if (!req.user || !req.user.userId) {
        return res.status(401).json({ error: 'User not authenticated or userId missing from token.' });
      }

      const userId = req.user.userId;

      // Step 1: Get the current user's following list
      const followingList = await Follow.find({following_user_id: userId}).select('followed_user_id') || [];
      const followingIds = followingList.map(follow => follow.followed_user_id);
      console.log(followingIds)

      // Step 2: Get History of followed users
      const followedHistory = await History.find({
        user_id: { $in: followingIds }
      })
        .populate('user_id', 'username')
        .sort({ createdAt: -1 });  // Adjust sorting based on your history data (e.g., creation date)

      // Step 3: Send the combined feed of followed user histories
      res.status(200).json(followedHistory);
    } catch (err) {
      next(err);
    }
  }
);
