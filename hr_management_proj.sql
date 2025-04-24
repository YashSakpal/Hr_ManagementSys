
-- HR Management System

-- Step 1: Create Database
CREATE DATABASE IF NOT EXISTS hr_management;
USE hr_management;

-- Step 2: Create Tables

-- Departments Table
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(100)
);

-- Employees Table
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    dept_id INT,
    salary DECIMAL(10,2),
    hire_date DATE,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

-- Leaves Table
CREATE TABLE leaves (
    leave_id INT PRIMARY KEY,
    emp_id INT,
    leave_type VARCHAR(50),
    start_date DATE,
    end_date DATE,
    status VARCHAR(20),
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);

-- Attendance Table
CREATE TABLE attendance (
    attendance_id INT PRIMARY KEY,
    emp_id INT,
    date DATE,
    status VARCHAR(10),
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);

-- Employees Audit Table
CREATE TABLE employees_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT,
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Step 3: Insert Sample Data

-- Departments
INSERT INTO departments (dept_id, dept_name) VALUES
(1, 'HR'), (2, 'Engineering'), (3, 'Marketing');

-- Employees
INSERT INTO employees (emp_id, name, email, dept_id, salary, hire_date) VALUES
(101, 'Alice', 'alice@example.com', 1, 60000, '2021-01-10'),
(102, 'Bob', 'bob@example.com', 2, 85000, '2022-03-15'),
(103, 'Charlie', 'charlie@example.com', 2, 92000, '2020-11-23'),
(104, 'Diana', 'diana@example.com', 3, 50000, '2023-06-01'),
(105, 'Eve', 'eve@example.com', 1, 70000, '2021-09-19');

-- Leaves
INSERT INTO leaves (leave_id, emp_id, leave_type, start_date, end_date, status) VALUES
(1, 101, 'Sick', '2024-01-03', '2024-01-05', 'Approved'),
(2, 102, 'Vacation', '2024-02-10', '2024-02-15', 'Approved'),
(3, 105, 'Sick', '2024-03-01', '2024-03-03', 'Pending');

-- Attendance
INSERT INTO attendance (attendance_id, emp_id, date, status) VALUES
(1, 101, '2025-04-01', 'Present'),
(2, 101, '2025-04-02', 'Absent'),
(3, 102, '2025-04-01', 'Present'),
(4, 103, '2025-04-01', 'Present'),
(5, 104, '2025-04-02', 'Late');

-- Step 4: Create Trigger
DELIMITER $$
CREATE TRIGGER before_salary_update
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
  IF OLD.salary != NEW.salary THEN
    INSERT INTO employees_audit (emp_id, old_salary, new_salary)
    VALUES (OLD.emp_id, OLD.salary, NEW.salary);
  END IF;
END$$
DELIMITER ;

-- Step 5: Create Index
CREATE INDEX idx_employee_name ON employees(name);

-- Step 6: Create Read only User
CREATE USER IF NOT EXISTS 'readonly_user'@'localhost' IDENTIFIED BY 'password123';
GRANT SELECT ON hr_management.* TO 'readonly_user'@'localhost';

-- Step 7: Sample Queries Demonstrating JOINs, GROUP BY + HAVING, and Subqueries

-- 1. JOIN: Get employee names with their department names
SELECT e.name AS employee_name, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;

-- 2. GROUP BY + HAVING: Departments with average salary greater than 70000
SELECT d.dept_name, AVG(e.salary) AS avg_salary
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
GROUP BY d.dept_name
HAVING AVG(e.salary) > 70000;

-- 3. Subquery: Employees whose salary is above the company average
SELECT name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);
