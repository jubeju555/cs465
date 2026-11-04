const $ = (selector) => document.querySelector(selector);
const api = async (path, options = {}) => {
  const response = await fetch(path, { headers: { "Content-Type": "application/json" }, ...options });
  const data = await response.json();
  if (!response.ok) throw new Error(data.error || "Request failed.");
  return data;
};
const escapeHtml = (value) => String(value ?? "").replace(/[&<>"']/g, (char) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#039;" }[char]));
const dateLabel = (value) => new Date(`${value}T00:00:00`).toLocaleDateString(undefined, { month: "short", day: "numeric", year: "numeric" });
const badge = (status) => `<span class="badge badge-${escapeHtml(status)}">${escapeHtml(status)}</span>`;
const showNotice = (message) => { const notice = $("#notice"); notice.textContent = message; notice.hidden = false; setTimeout(() => { notice.hidden = true; }, 4500); };
const showError = (error) => showNotice(error.message);

async function loadDashboard() {
  const data = await api("/api/dashboard");
  const stats = [
    ["Total events", data.stats.event_count],
    ["Volunteers", data.stats.volunteer_count],
    ["Volunteer hours", Number(data.stats.volunteer_hours).toFixed(1)],
    ["Low stock items", data.stats.low_stock_count],
  ];
  $("#stats").innerHTML = stats.map(([label, value]) => `<div class="stat"><span class="stat-label">${label}</span><strong class="stat-value">${value}</strong></div>`).join("");
  $("#upcomingList").innerHTML = data.upcoming.length ? data.upcoming.map((event) => `<div class="upcoming-item"><span class="upcoming-date">${dateLabel(event.event_date)}</span><strong>${escapeHtml(event.event_name)}</strong><span class="event-meta">${escapeHtml(event.location_name)} · ${badge(event.status)}</span></div>`).join("") : '<p class="muted">No upcoming events.</p>';
}

async function loadEvents() {
  const params = new URLSearchParams({ search: $("#searchInput").value, status: $("#statusFilter").value });
  const data = await api(`/api/events?${params}`);
  $("#eventsList").innerHTML = data.events.length ? data.events.map((event) => `<div class="event-row" data-event="${event.event_id}"><div><div class="event-name">${escapeHtml(event.event_name)}</div><div class="event-meta">${escapeHtml(event.location_name)} · ${dateLabel(event.event_date)}</div></div><div>${badge(event.status)}</div></div>`).join("") : '<p class="muted">No events match those filters.</p>';
  document.querySelectorAll("[data-event]").forEach((row) => row.addEventListener("click", () => openEvent(row.dataset.event)));
}

async function openEvent(id) {
  try {
    const data = await api(`/api/events/${id}`);
    const event = data.event;
    const volunteers = await api("/api/volunteers");
    const statusOptions = ["planned", "open", "completed", "cancelled"].map((status) => `<option ${status === event.status ? "selected" : ""}>${status}</option>`).join("");
    $("#eventDetail").innerHTML = `<div class="detail-header"><p class="eyebrow">Event details</p><h2>${escapeHtml(event.event_name)}</h2><div class="event-meta">${dateLabel(event.event_date)} · ${badge(event.status)}</div><p class="muted">${escapeHtml(event.location_name)} · ${escapeHtml(event.street_address)}</p></div><div class="inline-action"><select id="detailStatus">${statusOptions}</select><button class="button button-quiet" id="saveStatus">Save status</button></div><div class="detail-section"><h3>Registered volunteers (${data.volunteers.length})</h3><ul class="detail-list">${data.volunteers.length ? data.volunteers.map((item) => `<li><span>${escapeHtml(item.volunteer)}</span><small>${escapeHtml(item.role)} · ${item.hours_worked} hrs</small></li>`).join("") : "<li><span class='muted'>No volunteers registered.</span></li>"}</ul><div class="inline-action"><select id="volunteerSelect"><option value="">Select a volunteer</option>${volunteers.volunteers.map((item) => `<option value="${item.volunteer_id}">${escapeHtml(item.first_name)} ${escapeHtml(item.last_name)}</option>`).join("")}</select><input id="volunteerRole" placeholder="Role" value="volunteer"><button class="button button-quiet" id="registerVolunteer">Register</button></div></div><div class="detail-section"><h3>Supply requests (${data.supplies.length})</h3><ul class="detail-list">${data.supplies.length ? data.supplies.map((item) => `<li><span>${escapeHtml(item.supply_name)} × ${item.quantity_requested}</span><small>${escapeHtml(item.request_status)} ${item.request_status === "approved" ? `<button class="text-button" data-fulfill="${item.request_id}">Fulfill</button>` : ""}</small></li>`).join("") : "<li><span class='muted'>No supply requests.</span></li>"}</ul></div>`;
    $("#saveStatus").addEventListener("click", async () => {
      try { await api(`/api/events/${id}/status`, { method: "PATCH", body: JSON.stringify({ status: $("#detailStatus").value }) }); showNotice("Event status updated."); await openEvent(id); await Promise.all([loadDashboard(), loadEvents()]); } catch (error) { showError(error); }
    });
    $("#registerVolunteer").addEventListener("click", async () => {
      try { await api("/api/participation", { method: "POST", body: JSON.stringify({ event_id: Number(id), volunteer_id: Number($("#volunteerSelect").value), role: $("#volunteerRole").value }) }); showNotice("Volunteer registered."); await openEvent(id); await loadDashboard(); } catch (error) { showError(error); }
    });
    document.querySelectorAll("[data-fulfill]").forEach((button) => button.addEventListener("click", async () => {
      try { await api(`/api/requests/${button.dataset.fulfill}/fulfill`, { method: "POST", body: "{}" }); showNotice("Supply request fulfilled."); await openEvent(id); await loadDashboard(); } catch (error) { showError(error); }
    }));
    $("#eventDialog").showModal();
  } catch (error) { showError(error); }
}

const table = (headers, rows) => rows.length ? `<table class="data-table"><thead><tr>${headers.map((header) => `<th>${header[1]}</th>`).join("")}</tr></thead><tbody>${rows.map((row) => `<tr>${headers.map(([key]) => `<td>${escapeHtml(row[key])}</td>`).join("")}</tr>`).join("")}</tbody></table>` : '<p class="muted">No records to display.</p>';
async function loadActivity() { try { const data = await api("/api/activity"); $("#activityTable").innerHTML = table([["event_name", "Event"], ["event_date", "Date"], ["status", "Status"], ["volunteer_count", "Volunteers"], ["total_hours", "Hours"], ["supply_request_count", "Requests"]], data.summary); } catch (error) { showError(error); } }
async function loadInventory() { try { const data = await api("/api/inventory"); $("#inventoryTable").innerHTML = table([["supply_name", "Supply"], ["quantity_on_hand", "On hand"], ["reorder_level", "Reorder at"], ["units_used", "Used"]], data.inventory); } catch (error) { showError(error); } }

$("#refreshButton").addEventListener("click", () => Promise.all([loadDashboard(), loadEvents()]).catch(showError));
$("#searchInput").addEventListener("input", loadEvents);
$("#statusFilter").addEventListener("change", loadEvents);
$("#activityButton").addEventListener("click", loadActivity);
$("#inventoryButton").addEventListener("click", loadInventory);
$("#addVolunteerButton").addEventListener("click", () => $("#volunteerDialog").showModal());
document.querySelectorAll("[data-close]").forEach((button) => button.addEventListener("click", () => button.closest("dialog").close()));
$("#volunteerForm").addEventListener("submit", async (event) => {
  event.preventDefault();
  const form = new FormData(event.target);
  try {
    await api("/api/volunteers", { method: "POST", body: JSON.stringify(Object.fromEntries(form)) });
    event.target.reset(); $("#volunteerDialog").close(); showNotice("Volunteer added successfully."); await loadDashboard();
  } catch (error) { showError(error); }
});
Promise.all([loadDashboard(), loadEvents()]).catch(showError);
