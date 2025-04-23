const mongoose = require('mongoose');

const followSchema = new mongoose.Schema({
  following_user_id: {
    type: mongoose.Schema.Types.ObjectId, // References User._id
    ref: 'User',
    required: [true, 'Following user ID is required'],
    index: true,
  },
  followed_user_id: {
    type: mongoose.Schema.Types.ObjectId, // References User._id
    ref: 'User',
    required: [true, 'Followed user ID is required'],
    index: true,
  },
  created_at: {
    type: Date,
    default: Date.now,
  },
});

// Ensure a user can only follow another user once
followSchema.index({ following_user_id: 1, followed_user_id: 1 }, { unique: true });

// Validate that a user cannot follow themselves
followSchema.pre('save', function(next) {
  if (this.following_user_id.equals(this.followed_user_id)) {
    next(new Error('User cannot follow themselves.'));
  } else {
    next();
  }
});

module.exports = mongoose.model('Follow', followSchema);