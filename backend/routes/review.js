const express = require('express');
const router = express.Router();
const { body, query, validationResult } = require('express-validator');
const History = require('../models/History'); 
const User = require('../models/User'); 
const Review = require('../models/Review'); 

// POST /api/review/post
router.post('/post',
    [
    // Input validation
    body('api_id', 'Book API ID (api_id) is required').not().isEmpty().trim(),
    body('rating', 'Rating is required').not().isEmpty().trim().isInt({ min: 0, max: 5 }),
    body('description', 'Review description is required').not().isEmpty().trim(),
    body('book_name', 'Book name is required').not().isEmpty().trim(),
  ], 
  async (req, res, next) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        if (!req.user || !req.user.userId) {
            return res.status(401).json({ error: 'User not authenticated or userId missing from token.' });
        }
        
        const { api_id, rating, description, book_name} = req.body;
        const user_id = req.user.userId
        console.log(user_id)
        const newReview = new Review({
            user_id,
            api_id,
            rating,
            description,
            book_name
        });

        const savedReview = await newReview.save();
        
        const newHistory = new History({
            action : "write a review",
            api_id,
            user_id,
            book_name
        })

        const savedHistory = await newHistory.save();

        res.status(200).json({
            message: "Post Review successfully",
            bookAPIId : savedReview.api_id,
            ReviewId: savedReview._id,
            Reviewer: savedReview.user_id,
            rating: savedReview.rating,
            description: savedReview.description,
            bookName: savedReview.book_name
        });
    } catch (err) {
        next(err); 
    }
});

// GET /api/review/get
// Get all reviews of a specific book
router.get('/get',
  [
    query('api_id', 'Book API ID (api_id) is required').not().isEmpty().trim()
  ], 
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      if (!req.user || !req.user.userId) {
        return res.status(401).json({ error: 'User not authenticated or userId missing from token.' });
      }

      const { api_id } = req.query;

      // Get reviews with user name
      const reviews = await Review.find({ api_id })
        .populate('user_id', 'username') // assumes 'username' exists in User model
        .sort({ createdAt: -1 });

      const formattedReviews = reviews.map(review => {
        const reviewObj = review.toObject();
        return {
          ...reviewObj,
          username: reviewObj.user_id?.username || 'Unknown',
          user_id: reviewObj.user_id?._id || null
        };
      });

      res.status(200).json(formattedReviews);
    } catch (err) {
      next(err);
    }
});


// GET /api/review/getUserReview
// Get only reviews made by the logged-in user
router.get('/getUserReview', async (req, res, next) => {
  try {
    if (!req.user || !req.user.userId) {
      return res.status(401).json({ error: 'User not authenticated or userId missing from token.' });
    }

    const user_id = req.user.userId;

    // Get user once
    const user = await User.findById(user_id).select('username');

    if (!user) {
      return res.status(404).json({ error: 'User not found.' });
    }

    // Find all reviews by this user
    const reviews = await Review.find({ user_id }).sort({ createdAt: -1 });

    // Attach username to each review
    const formattedReviews = reviews.map(review => ({
      ...review.toObject(),
      username: user.username
    }));

    res.status(200).json(formattedReviews);
  } catch (err) {
    next(err);
  }
});

// GET /api/review/getReviewByUserId
router.get('/getReviewByUserId',
  [
    query('user_id', 'user_id is required').not().isEmpty().trim()
  ] , async (req, res, next) => {
  try {
    if (!req.user || !req.user.userId) {
      return res.status(401).json({ error: 'User not authenticated or userId missing from token.' });
    }

    const { user_id } = req.query;

    // Get user once
    const user = await User.findById(user_id).select('username');

    if (!user) {
      return res.status(404).json({ error: 'User not found.' });
    }

    // Find all reviews by this user
    const reviews = await Review.find({ user_id }).sort({ createdAt: -1 });

    // Attach username to each review
    const formattedReviews = reviews.map(review => ({
      ...review.toObject(),
      username: user.username
    }));

    res.status(200).json(formattedReviews);
  } catch (err) {
    next(err);
  }
});


module.exports = router;