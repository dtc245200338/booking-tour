const $ = (id) => document.getElementById(id);
const esc = (s) => String(s ?? '').replace(/[&<>"']/g, (c) =>
  ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
const vnd = (n) => Number(n).toLocaleString('vi-VN') + ' đ';

async function api(url, opts) {
  const r = await fetch(url, opts);
  const d = await r.json().catch(() => ({}));
  if (!r.ok) throw new Error(d.error || 'Có lỗi xảy ra');
  return d;
}

async function loadTours() {
  const tours = await api('/api/tours');
  $('tours').innerHTML = tours.map((t) => `
    <div class="card">
      <h3>${esc(t.name)}</h3>
      <p>📍 ${esc(t.destination)} · ${esc(t.duration_days)} ngày</p>
      <p>${esc(t.description)}</p>
      <p class="price">${vnd(t.price)}</p>
      <button data-id="${esc(t.id)}">Xem lịch trình & đặt tour</button>
    </div>`).join('');
}

async function openTour(id) {
  const t = await api('/api/tours/' + id);
  $('d-name').textContent = t.name;
  $('d-info').textContent = `📍 ${t.destination} · ${t.duration_days} ngày · ${vnd(t.price)}/người`;
  $('d-itin').innerHTML = t.itinerary.map((i) =>
    `<li><b>${esc(i.title)}</b> – ${esc(i.detail)}</li>`).join('');
  $('schedule').innerHTML = t.schedules.map((s) =>
    `<option value="${esc(s.id)}">${esc(s.departure_date)} (còn ${esc(s.seats_available)} chỗ)</option>`).join('');
  $('msg').textContent = '';
  $('tours').hidden = true;
  $('detail').hidden = false;
}

$('tours').addEventListener('click', (e) => {
  const id = e.target.dataset.id;
  if (id) openTour(id).catch((err) => alert(err.message));
});
$('back').addEventListener('click', () => { $('detail').hidden = true; $('tours').hidden = false; loadTours(); });

$('form').addEventListener('submit', async (e) => {
  e.preventDefault();
  try {
    const r = await api('/api/bookings', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        schedule_id: $('schedule').value, full_name: $('full_name').value,
        email: $('email').value, phone: $('phone').value, num_people: $('num_people').value,
      }),
    });
    $('msg').className = 'ok';
    $('msg').textContent = `✅ Đặt tour thành công! Mã booking #${r.id} – Tổng tiền ${vnd(r.total_price)}`;
  } catch (err) {
    $('msg').className = 'err';
    $('msg').textContent = '❌ ' + err.message;
  }
});

loadTours().catch(() => { $('tours').textContent = 'Không tải được danh sách tour.'; });
