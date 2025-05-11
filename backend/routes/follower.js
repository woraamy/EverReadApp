const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');
const Follow = require('../models/Follow'); 

// POST /api/follower/follow
router.post('/follow',
    [
    // Input validation
    body('followed_user_id', 'Followed ID (api_id) is required').not().isEmpty().trim(),
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
        
        const { followed_user_id } = req.body;
        const user_id = req.user.userId

        const newFollow = new Follow({
            following_user_id: user_id,
            followed_user_id
        });

        const savedFollow = await newFollow.save();
        
        res.status(201).json({
            message: "Follow successfully",
            following_user : savedFollow.following_user_id,
            followed_user: savedFollow.followed_user_id,
          
        });
    } catch (err) {
        next(err); 
    }
});

// DELETE /api/follower/unfollow
router.delete('/unfollow',
    [
    // Input validation
    body('followed_user_id', 'Followed ID (api_id) is required').not().isEmpty().trim(),
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
        
        const { followed_user_id } = req.body;
        const user_id = req.user.userId

        const deletedFollow = await Follow.deleteOne({followed_user_id, following_user_id:user_id}) 
        if (deletedFollow.deletedCount === 0) {
                return res.status(404).json({
                message: 'Follow relationship not found',
                following_user: user_id,
                followed_user: followed_user_id,
                });
      }
        res.status(201).json({
            message: "unFollow successfully",
            following_user : user_id,
            followed_user: followed_user_id,
          
        });
    } catch (err) {
        next(err); 
    }
});



module.exports = router;