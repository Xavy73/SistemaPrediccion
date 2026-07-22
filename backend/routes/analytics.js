const express = require('express');
const Analytics = require('../models/Analytics');
const Prediction = require('../models/Prediction');
const { authMiddleware, adminOnly } = require('../middleware/auth');
const router = express.Router();

router.get('/user/:userId', authMiddleware, async (req, res) => {
  try {
    const analytics = await Analytics.findOne({ userId: req.params.userId });
    if (!analytics) {
      return res.json({
        accuracy: 0,
        roi: 0,
        successRate: 0,
        totalPredictions: 0,
        completedPredictions: 0,
      });
    }
    res.json(analytics);
  } catch (error) {
    res.status(500).json({ message: 'Error obteniendo analytics' });
  }
});

router.get('/global', authMiddleware, adminOnly, async (req, res) => {
  try {
    const totalPredictions = await Prediction.countDocuments();
    const completedPredictions = await Prediction.countDocuments({ status: 'completed' });
    const approvedPredictions = await Prediction.countDocuments({ status: 'approved' });

    const trends = await Prediction.aggregate([{ $group: { _id: '$trend', count: { $sum: 1 } } }]);

    res.json({
      totalPredictions,
      completedPredictions,
      approvedPredictions,
      pendingPredictions: totalPredictions - completedPredictions - approvedPredictions,
      successRate: totalPredictions > 0 ? ((completedPredictions / totalPredictions) * 100).toFixed(2) : 0,
      trends,
    });
  } catch (error) {
    res.status(500).json({ message: 'Error obteniendo global analytics' });
  }
});

module.exports = router;
