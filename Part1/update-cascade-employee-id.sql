USE Stores;

DECLARE @old_employee_id INT = 5;
DECLARE @new_employee_id INT = 105;

SELECT * FROM Employees WHERE Employee_ID = @old_employee_id;
SELECT Sale_ID, Employee_ID FROM Sales WHERE Employee_ID = @old_employee_id;

UPDATE Employees SET Employee_ID = @new_employee_id WHERE Employee_ID = @old_employee_id;
SELECT 'Employee ID ' + CAST(@old_employee_id AS VARCHAR) + ' was changed to' + CAST(@new_employee_id AS VARCHAR) AS Message;

SELECT * FROM Employees WHERE Employee_ID = @new_employee_id;
SELECT Sale_ID, Employee_ID FROM Sales WHERE Employee_ID = @new_employee_id;