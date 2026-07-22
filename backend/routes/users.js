const express = require('express');
const User = require('../models/User');
const { authMiddleware, adminOnly } = require('../middleware/auth');
const bcrypt = require('bcryptjs');
const router = express.Router();

router.get('/', authMiddleware, adminOnly, async (req, res) => {
  try {
    const users = await User.find().select('-password');
    res.json(users);
  } catch (error) {
    res.status(500).json({ message: 'Error obteniendo usuarios' });
  }
});

router.get('/me', authMiddleware, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-password');
    if (!user) return res.status(404).json({ message: 'Usuario no encontrado' });
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: 'Error obteniendo perfil' });
  }
});

router.put('/me', authMiddleware, async (req, res) => {
  try {
    const { name, company, password } = req.body;
    const updates = { name, company };
    if (password) {
      updates.password = await bcrypt.hash(password, 10);
    }
    const user = await User.findByIdAndUpdate(req.user.id, updates, { new: true }).select('-password');
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: 'Error actualizando perfil' });
  }
});

router.post('/', authMiddleware, adminOnly, async (req, res) => {
  try {
    const { name, email, password, role, company } = req.body;
    if (!name || !email || !password) {
      return res.status(400).json({ message: 'Nombre, email y contraseña son requeridos' });
    }
    const existing = await User.findOne({ email });
    if (existing) {
      return res.status(409).json({ message: 'El correo electrónico ya existe' });
    }
    const hashedPassword = await bcrypt.hash(password, 10);
    const user = new User({
      name,
      email,
      password: hashedPassword,
      role: role || 'client',
      company: company || '',
      active: true,
    });
    await user.save();
    const result = user.toObject();
    delete result.password;
    res.status(201).json(result);
  } catch (error) {
    res.status(500).json({ message: 'Error creando usuario' });
  }
});

router.put('/:id', authMiddleware, adminOnly, async (req, res) => {
  try {
    const { name, email, role, company, active, password } = req.body;
    const updates = {};
    if (name !== undefined) updates.name = name;
    if (email !== undefined) updates.email = email;
    if (role !== undefined) updates.role = role;
    if (company !== undefined) updates.company = company;
    if (active !== undefined) updates.active = active;
    if (password) {
      updates.password = await bcrypt.hash(password, 10);
    }
    const user = await User.findByIdAndUpdate(req.params.id, updates, { new: true }).select('-password');
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: 'Error actualizando usuario' });
  }
});

router.put('/:id/role', authMiddleware, adminOnly, async (req, res) => {
  try {
    const { role } = req.body;
    if (!['admin', 'client'].includes(role)) {
      return res.status(400).json({ message: 'Rol inválido' });
    }
    const user = await User.findByIdAndUpdate(req.params.id, { role }, { new: true }).select('-password');
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: 'Error actualizando rol' });
  }
});

router.put('/:id/status', authMiddleware, adminOnly, async (req, res) => {
  try {
    const { active } = req.body;
    const user = await User.findByIdAndUpdate(req.params.id, { active }, { new: true }).select('-password');
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: 'Error actualizando estado del usuario' });
  }
});

router.delete('/:id', authMiddleware, adminOnly, async (req, res) => {
  try {
    const user = await User.findByIdAndDelete(req.params.id);
    if (!user) return res.status(404).json({ message: 'Usuario no encontrado' });
    res.json({ message: 'Usuario eliminado correctamente' });
  } catch (error) {
    res.status(500).json({ message: 'Error eliminando usuario' });
  }
});

module.exports = router;
