const express = require("express");
const sqlite3 = require("sqlite3");

const PORT = 3004;

const app = express();
const db = new sqlite3.Database("demo3c.db");

app.get("/", (req, res) => {
  res.send("Hello from Express");
});

app.get("/name", (req, res) => {
  res.send("<h1>Judah Benjamin</h1>");
});

app.get("/json", (req, res) => {
  res.json({ message: "Hello from Express" });
});

app.get("/name/:name", (req, res) => {
  res.json({ name: req.params.name });
});

app.get("/students", (req, res) => {
  const sql =
    "SELECT student_id, name, major FROM students ORDER BY name";

  db.all(sql, [], (err, rows) => {
    if (err) {
      console.error(err);
      return res.sendStatus(500);
    }

    res.json(rows);
  });
});

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});


app.get("/students/html", (req, res) => {
  const sql =
    "SELECT student_id, name, major FROM students ORDER BY name";

  db.all(sql, [], (err, rows) => {
    if (err) {
      console.error(err);
      return res.sendStatus(500);
    }

    let html = "<h1>Students</h1><table>";

    for (const row of rows) {
      html += `<tr><td>${row.student_id}</td>` +
        `<td>${row.name}</td>` +
        `<td>${row.major}</td></tr>`;
    }

    html += "</table>";
    res.send(html);
  });
});

app.get('/students/:id', (req, res) => {
const id = req.params.id;
const sql =
'SELECT student_id, name, major ' +
'FROM students WHERE student_id = ?';
db.get(sql, [id], (err, row) => {
if (err) return res.sendStatus(500);

if (!row) {
return res.status(404).json({
error: 'Student not found'
});
}

res.json(row);
});
});


app.get('/search', (req, res) => {
const major = req.query.major;
const sql =
'SELECT student_id, name, major ' +
'FROM students WHERE major = ? ' +
'ORDER BY name';
db.all(sql, [major], (err, rows) => {
if (err) return res.sendStatus(500);
res.json(rows);
});
})


app.get('/students/:id/courses', (req, res) => {
const id = req.params.id;
const sql =
'SELECT c.course_id, c.title, c.credits ' +
'FROM courses c JOIN enrollment e ' +
'ON c.course_id = e.course_id ' +
'WHERE e.student_id = ? ORDER BY c.title';
db.all(sql, [id], (err, rows) => {
if (err) return res.sendStatus(500);
res.json(rows);
});
});