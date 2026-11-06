
const express = require("express");
const sqlite3 = require("sqlite3");

const PORT = 3004;

const app = express();
const db = new sqlite3.Database("demo3c.db");

app.use(express.urlencoded({ extended: false }));

// Home route
app.get("/", (req, res) => {
  res.send("Hello from Express");
});

// Display name as HTML
app.get("/name", (req, res) => {
  res.send("<h1>Judah Benjamin</h1>");
});

// Return JSON
app.get("/json", (req, res) => {
  res.json({ message: "Hello from Express" });
});

// Return name from URL parameter
app.get("/name/:name", (req, res) => {
  res.json({ name: req.params.name });
});

// Get all students
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

// Get all students as HTML
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
      html +=
        `<tr><td>${row.student_id}</td>` +
        `<td>${row.name}</td>` +
        `<td>${row.major}</td></tr>`;
    }

    html += "</table>";

    res.send(html);
  });
});

// Display form to add a student
app.get("/students/add", (req, res) => {
  res.send(`
    <h1>Add Student</h1>
    <form method="POST" action="/students">
      Name: <input name="name">
      Major: <input name="major">
      <button type="submit">Add Student</button>
    </form>
  `);
});

// Get a specific student by ID
app.get("/students/:id", (req, res) => {
  const id = req.params.id;

  const sql =
    "SELECT student_id, name, major " +
    "FROM students WHERE student_id = ?";

  db.get(sql, [id], (err, row) => {
    if (err) {
      return res.sendStatus(500);
    }

    if (!row) {
      return res.status(404).json({
        error: "Student not found",
      });
    }

    res.json(row);
  });
});

// Search students by major
app.get("/search", (req, res) => {
  const major = req.query.major;

  const sql =
    "SELECT student_id, name, major " +
    "FROM students WHERE major = ? " +
    "ORDER BY name";

  db.all(sql, [major], (err, rows) => {
    if (err) {
      return res.sendStatus(500);
    }

    res.json(rows);
  });
});

// Get courses for a specific student
app.get("/students/:id/courses", (req, res) => {
  const id = req.params.id;

  const sql =
    "SELECT c.course_id, c.title, c.credits " +
    "FROM courses c JOIN enrollment e " +
    "ON c.course_id = e.course_id " +
    "WHERE e.student_id = ? ORDER BY c.title";

  db.all(sql, [id], (err, rows) => {
    if (err) {
      return res.sendStatus(500);
    }

    res.json(rows);
  });
});

// Add a new student
app.post("/students", (req, res) => {
  const name = req.body.name;
  const major = req.body.major;

  const sql =
    "INSERT INTO students (name, major) " +
    "VALUES (?, ?)";

  if (!name || !major) {
    return res.status(400).json({
      error: "name and major are required",
    });
  }

  db.run(sql, [name, major], function (err) {
    if (err) {
      return res.sendStatus(500);
    }

    res.json({
      student_id: this.lastID,
      name: name,
      major: major,
    });
  });
});

// Display form to edit a student's major
app.get("/students/:id/edit", (req, res) => {
  const id = req.params.id;

  res.send(`
    <h1>Change Major</h1>
    <form method="POST" action="/students/${id}/major">
      New major: <input name="major">
      <button type="submit">Update</button>
    </form>
  `);
});

// Update a student's major
app.post("/students/:id/major", (req, res) => {
  const id = req.params.id;
  const major = req.body.major;

  const sql =
    "UPDATE students SET major = ? " +
    "WHERE student_id = ?";

  db.run(sql, [major, id], function (err) {
    if (err) {
      return res.sendStatus(500);
    }

    res.send("Student updated");
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
