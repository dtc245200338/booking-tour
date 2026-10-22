const express = require('express');
const path = require('path');
const { Pool } = require('pg');

const app = express();
app.disable('x-powered-by');
app.set('trust proxy', 1);
app.use(express.json({ limit: '10kb' }));

const pool = new Pool({
  host: process.env.DB_HOST,
  port: 5432,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  max: 10,
});

// Log dạng JSON, mỗi request 1 dòng (dùng cho Loki ở Commit 3)
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    console.log(JSON.stringify({
      time: new Date().toISOString(),
      level: res.statusCode >= 500 ? 'error' : 'info',
      method: req.method, path: req.originalUrl,
      status: res.statusCode, duration_ms: Date.now() - start, ip: req.ip,
    }));
  });
  next();
});

const wrap = (fn) => (req, res) =>
  fn(req, res).catch((err) => {
    console.error(JSON.stringify({ time: new Date().toISOString(), level: 'error', msg: err.message }));
    res.status(500).json({ error: 'Lỗi máy chủ' });
  });

app.get('/api/health', wrap(async (req, res) => {
  await pool.query('SELECT 1');
  res.json({ status: 'ok', db: 'connected' });
}));

app.get('/api/tours', wrap(async (req, res) => {
  const { rows } = await pool.query(
    'SELECT id, name, destination, price, duration_days, description FROM tours ORDER BY id');
  res.json(rows);
}));

app.get('/api/tours/:id', wrap(async (req, res) => {
  const id = parseInt(req.params.id, 10);
  if (!Number.isInteger(id)) return res.status(400).json({ error: 'id không hợp lệ' });
  const tour = await pool.query('SELECT * FROM tours WHERE id = $1', [id]);
  if (!tour.rows.length) return res.status(404).json({ error: 'Không tìm thấy tour' });
  const itin = await pool.query(
    'SELECT day_no, title, detail FROM tour_itineraries WHERE tour_id = $1 ORDER BY day_no', [id]);
  const sch = await pool.query(
    `SELECT id, to_char(departure_date,'DD/MM/YYYY') AS departure_date, seats_available
       FROM tour_schedules WHERE tour_id = $1 AND departure_date >= CURRENT_DATE
       ORDER BY departure_date`, [id]);
  res.json({ ...tour.rows[0], itinerary: itin.rows, schedules: sch.rows });
}));

app.post('/api/bookings', wrap(async (req, res) => {
  const b = req.body || {};
  const fullName = String(b.full_name || '').trim().slice(0, 100);
  const email = String(b.email || '').trim().toLowerCase().slice(0, 150);
  const phone = String(b.phone || '').trim().slice(0, 20);
  const sid = parseInt(b.schedule_id, 10);
  const n = parseInt(b.num_people, 10);
  if (!fullName || !/^\S+@\S+\.\S+$/.test(email) || !Number.isInteger(sid) || !(n >= 1 && n <= 20)) {
    return res.status(400).json({ error: 'Dữ liệu không hợp lệ' });
  }
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const s = await client.query(
      `SELECT s.seats_available, t.price FROM tour_schedules s
         JOIN tours t ON t.id = s.tour_id WHERE s.id = $1 FOR UPDATE OF s`, [sid]);
    if (!s.rows.length) { await client.query('ROLLBACK'); return res.status(404).json({ error: 'Lịch khởi hành không tồn tại' }); }
    if (s.rows[0].seats_available < n) { await client.query('ROLLBACK'); return res.status(409).json({ error: 'Không đủ chỗ trống' }); }
    const c = await client.query(
      `INSERT INTO customers (full_name, email, phone) VALUES ($1,$2,$3)
       ON CONFLICT (email) DO UPDATE SET full_name = EXCLUDED.full_name, phone = EXCLUDED.phone
       RETURNING id`, [fullName, email, phone]);
    const total = Number(s.rows[0].price) * n;
    const bk = await client.query(
      `INSERT INTO bookings (customer_id, schedule_id, num_people, total_price)
       VALUES ($1,$2,$3,$4) RETURNING id, status, total_price`, [c.rows[0].id, sid, n, total]);
    await client.query('UPDATE tour_schedules SET seats_available = seats_available - $1 WHERE id = $2', [n, sid]);
    await client.query('COMMIT');
    res.status(201).json(bk.rows[0]);
  } catch (e) {
    await client.query('ROLLBACK').catch(() => {});
    throw e;
  } finally {
    client.release();
  }
}));

app.use(express.static(path.join(__dirname, '../public')));

app.listen(3000, '0.0.0.0', () => console.log(JSON.stringify({ level: 'info', msg: 'Server listening on 3000' })));
