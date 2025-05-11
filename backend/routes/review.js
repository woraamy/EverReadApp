const express = require('express');
const router = express.Router();
const { body, query, validationResult } = require('express-validator');
const History = require('../models/History'); 
const Review = require('../models/Review'); 

// POST /api/review/post
router.post('/post',
    [
    // Input validation
    body('api_id', 'Book API ID (api_id) is required').not().isEmpty().trim(),
    body('rating', 'Rating is required').not().isEmpty().trim().isInt({ min: 0, max: 5 }),
    body('description', 'Review description is required').not().isEmpty().trim(),
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
        
        const { api_id, rating, description} = req.body;
        const user_id = req.user.userId

        const newReview = new Review({
            user_id,
            api_id,
            rating,
            description
        });

        const savedReview = await newReview.save();
        
        const newHistory = new History({
            action : "write a review",
            api_id,
            user_id,
        })

        const savedHistory = await newHistory.save();

        res.status(200).json({
            message: "Post Review successfully",
            bookAPIId : savedReview.api_id,
            ReviewId: savedReview._id,
            Reviewer: savedReview.user_id,
            rating: savedReview.rating,
            description: savedReview.description
        });
    } catch (err) {
        next(err); 
    }
});

// GET /api/review/get
// Get only all review of specific book
router.get('/get',
    [
    // Input validation
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

        const reviews = await Review.find({api_id});
        res.status(200).json(reviews);
    } catch (err) {
        next(err); 
    }
});

module.exports = router;