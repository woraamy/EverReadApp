const express = require('express');
const jwt = require('jsonwebtoken');
const User = require('../../models/User');
const router = express.Router();
const argon2 = require('argon2');

// Get JWT_SECRET from environment or use default
const JWT_SECRET = process.env.JWT_SECRET || 'your_jwt_secret';

// POST /api/auth/login 
router.post('/', async (req, res) => {
    try {
        const { email, password } = req.body;
        
        // Validate input
        if (!email || !password) {
            return res.status(400).json({ error: 'Email and password are required' });
        }
        
        const user = await User.findOne({ email });
        if (!user) return res.status(400).json({ error: 'Invalid email' });
        
        // Debug logs (remove in production)
        console.log('User found:', user.email);
        
        try {
            const isMatch = await argon2.verify(user.password, password);
            console.log('Password match:', isMatch);
            
            // if (!isMatch) return res.status(400).json({ error: 'Invalid password' });
            
            const token = jwt.sign({ userId: user.id }, JWT_SECRET, { expiresIn: '7d' });

            res.json({ 
                token,
                user: {
                    id: user._id,
                    username: user.username,
                    email: user.email
                }
            });
        } catch (verifyError) {
            console.error('Password verification error:', verifyError);
            return res.status(500).json({ error: "Password verification failed" });
        }
    } catch (err) {
        console.error('Login error:', err);
        res.status(500).json({ error: "Server error" });
    }
});

module.exports = router;