// goal.js
const express = require('express');
const multer = require('multer');
const User = require('../models/User');
const { body, query, validationResult } = require('express-validator');
const router = express.Router(); 

// PUT /api/goal/year
router.put('/year',
  [body('yearly_goal', 'yearly_goal is required').not().isEmpty().trim().isInt()], 
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      if (!req.user || !req.user.userId) {
        return res.status(401).json({ error: 'User not authenticated or userId missing from token.' });
      }

      const { yearly_goal } = req.body;
      const updatedUser = await User.findByIdAndUpdate(
        req.user.userId,
        { yearly_goal },
        { new: true }
      );

      res.status(200).json({
        message: "Update yearly goal successfully",
        yearly_goal: updatedUser.yearly_goal
      });
    } catch (err) {
      next(err);
    }
});

// PUT /api/goal/month
router.put('/month',
  [body('month_goal', 'new month_goal is required').not().isEmpty().trim().isInt()], 
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      if (!req.user || !req.user.userId) {
        return res.status(401).json({ error: 'User not authenticated or userId missing from token.' });
      }

      const { month_goal } = req.body;
      const updatedUser = await User.findByIdAndUpdate(
        req.user.userId,
        { month_goal },
        { new: true }
      );

      res.status(200).json({
        message: "Update monthly goal successfully",
        month_goal: updatedUser.month_goal
      });
    } catch (err) {
      next(err);
    }
});

module.exports = router;
