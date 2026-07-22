const express = require('express');
const Prediction = require('../models/Prediction');
const User = require('../models/User');
const { authMiddleware, adminOnly } = require('../middleware/auth');
const router = express.Router();

router.get('/stats', authMiddleware, adminOnly, async (req, res) => {
  try {
    const totalPredictions = await Prediction.countDocuments();
    const approved = await Prediction.countDocuments({ status: 'approved' });
    const completed = await Prediction.countDocuments({ status: 'completed' });
    const pending = await Prediction.countDocuments({ status: 'pending' });
    const totalUsers = await User.countDocuments();
    const clients = await User.countDocuments({ role: 'client' });
    const admins = await User.countDocuments({ role: 'admin' });

    const trends = await Prediction.aggregate([
      { $group: { _id: '$trend', count: { $sum: 1 } } },
    ]);

    const probabilities = await Prediction.aggregate([
      { $bucket: { groupBy: '$probability', boundaries: [0, 30, 60, 80, 101], default: '80-100', output: { count: { $sum: 1 } } } },
    ]);

    const allPredictions = await Prediction.find().select('title category probability targetReturn amount riskLevel trend status');

    // 1. Scatter Data (Probability vs Target Return)
    const scatterData = allPredictions.map((p) => ({
      id: p._id.toString(),
      title: p.title || '',
      category: p.category || 'Acciones',
      probability: p.probability || 50,
      targetReturn: p.targetReturn || 10,
      amount: p.amount || 1000,
      riskLevel: p.riskLevel || 'Medio',
    }));

    // 2. Histogram Bins (5 intervals: 0-20, 20-40, 40-60, 60-80, 80-100)
    const binRanges = [
      { range: '0 - 20%', min: 0, max: 20 },
      { range: '20 - 40%', min: 20, max: 40 },
      { range: '40 - 60%', min: 40, max: 60 },
      { range: '60 - 80%', min: 60, max: 80 },
      { range: '80 - 100%', min: 80, max: 101 },
    ];
    const histogramBins = binRanges.map((bin) => {
      const matches = allPredictions.filter((p) => (p.probability || 0) >= bin.min && (p.probability || 0) < bin.max);
      const totalAmount = matches.reduce((sum, p) => sum + (p.amount || 0), 0);
      return {
        range: bin.range,
        count: matches.length,
        totalAmount,
      };
    });

    // 3. Data Mining Insights
    const avgReturnByCategory = await Prediction.aggregate([
      {
        $group: {
          _id: '$category',
          avgReturn: { $avg: '$targetReturn' },
          avgProbability: { $avg: '$probability' },
          count: { $sum: 1 },
        },
      },
    ]);

    const riskClusters = await Prediction.aggregate([
      {
        $group: {
          _id: { category: '$category', riskLevel: '$riskLevel' },
          count: { $sum: 1 },
          avgReturn: { $avg: '$targetReturn' },
        },
      },
    ]);

    const totalProbabilitySum = allPredictions.reduce((acc, p) => acc + (p.probability || 0), 0);
    const confidenceIndex = totalPredictions > 0 ? parseFloat((totalProbabilitySum / totalPredictions).toFixed(1)) : 75.0;

    const dataMining = {
      confidenceIndex,
      avgReturnByCategory: avgReturnByCategory.map((c) => ({
        category: c._id || 'Acciones',
        avgReturn: parseFloat((c.avgReturn || 0).toFixed(1)),
        avgProbability: parseFloat((c.avgProbability || 0).toFixed(1)),
        count: c.count,
      })),
      clusters: riskClusters.map((cluster) => ({
        clusterName: `${cluster._id.category || 'Activo'} (${cluster._id.riskLevel || 'Medio'})`,
        count: cluster.count,
        avgReturn: parseFloat((cluster.avgReturn || 0).toFixed(1)),
      })),
    };

    res.json({
      totalPredictions,
      approved,
      completed,
      pending,
      totalUsers,
      clients,
      admins,
      trends,
      probabilities,
      scatterData,
      histogramBins,
      dataMining,
    });
  } catch (error) {
    res.status(500).json({ message: 'Error obteniendo estadísticas' });
  }
});

router.get('/recent', authMiddleware, adminOnly, async (req, res) => {
  try {
    const recentPredictions = await Prediction.find().sort({ createdAt: -1 }).limit(6).populate('createdBy', 'name email');
    res.json(recentPredictions);
  } catch (error) {
    res.status(500).json({ message: 'Error obteniendo predicciones recientes' });
  }
});

module.exports = router;
