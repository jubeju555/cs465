Assume PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS enrollment;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS students;

-- Create Tables

CREATE TABLE students (
    student_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    major TEXT
);

CREATE TABLE courses (
    course_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    credits INTEGER
);

CREATE TABLE enrollment (
    student_id INTEGER,
    course_id INTEGER,
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);


-- Populate Tables

INSERT INTO students (student_id, name, major)
VALUES (1, 'Alice', 'CS');

INSERT INTO students (student_id, name, major)
VALUES (2, 'Bob', 'EE');

INSERT INTO students (student_id, name, major)
VALUES (3, 'Carol', 'CS');

INSERT INTO students (student_id, name, major)
VALUES (4, 'David', 'Math');


-- Populate Tables

-- ============================================================
-- Populate courses
-- ============================================================

INSERT INTO courses (course_id, title, credits)
VALUES (101, 'Databases', 3);

INSERT INTO courses (course_id, title, credits)
VALUES (102, 'Python', 4);

INSERT INTO courses (course_id, title, credits)
VALUES (103, 'Software Eng', 3);


-- ============================================================
-- Populate enrollment
-- ============================================================

INSERT INTO enrollment (student_id, course_id)
VALUES (1, 101);

INSERT INTO enrollment (student_id, course_id)
VALUES (1, 103);

INSERT INTO enrollment (student_id, course_id)
VALUES (2, 101);

INSERT INTO enrollment (student_id, course_id)
VALUES (3, 102);


-- Display starting data

SELECT * FROM students;
SELECT * FROM courses;
SELECT * FROM enrollment;
