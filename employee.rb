
# Helper module for checking employee si present the id or not 
module EmployeeHelper
  def find_employee(id)
    employee = @registered_employees[id]

    if employee.nil?
      puts "Employee with ID #{id} not found."
      return nil
    end

    employee
  end
end

# combining all the employee operations related together
module EmployeeOperations
  include EmployeeHelper
  # Create Employee
  def create_employee(id, name, department, designation, salary)

    if id.empty?
      puts "Employee number should not be empty."
      return
    end

    if @registered_employees.key?(id)
      puts "Rejected: Employee ID already exists."
      return
    end
    
    if salary <= 0 
      puts "Salary must be a positive amount."
      return
    end

    details = [name, department, designation]

    if details.any? { |value| value.nil? || value.to_s.strip.empty? }
      puts "Employee details should not be empty."
      return
    end

    @registered_employees[id] = {
      emp_name: name,
      department: department,
      designation: designation,
      monthly_salary: salary,
      attendance: [],
      leaves: []
    }

    puts "Employee with ID - #{id} created successfully."
    @registered_employees[id]
  end

  # 2. View all employees
  def view_all_employees
    if @registered_employees.empty?
      puts "No employees found."
      return
    end

    @registered_employees.each do |id, employee|
      puts "\n Employee ID: #{id}"
      puts "Name: #{employee[:emp_name]}"
      puts "Department: #{employee[:department]}"
      puts "Designation: #{employee[:designation]}"
      puts "Monthly Salary: #{employee[:monthly_salary]}"
      puts "--------------------------"
    end
  end

  # 3. Search employee
  def search_employee(id)
    employee = find_employee(id)
    return if employee.nil?

    employee
  end

  # 4. Update employee details or salary
  def update_employee(id)
    employee = find_employee(id)
    return if employee.nil?

    print "Enter the name: "
    updated_name = gets.chomp
    employee[:emp_name] = updated_name.strip unless updated_name.strip.empty?

    print "Enter the department : "
    updated_department = gets.chomp
    employee[:department] = updated_department.strip unless updated_department.strip.empty?

    print "Enter the designation: "
    updated_designation = gets.chomp
    employee[:designation] = updated_designation.strip.downcase unless updated_designation.strip.empty?

    print "Enter the monthly base salary: "
    updated_salary = gets.chomp

    if updated_salary <= Employee.budget
      employee[:monthly_salary] = updated_salary 
      puts "Employee details updated successfully."
    else
      puts "Rejected Employee; because updated salary should not exceed the budget"
    end
    employee
  end

  # 5. Delete employee
  def delete_employee(id)
    
    if @registered_employees.key?(id)
      @registered_employees.delete(id)
      puts "Employee with ID #{id} deleted successfully."
    else
      puts "Employee with ID #{id} not found."
    end
  end

  # 6. View employees by department
  def view_employees_by_department(department_name)
    matched_employees = @registered_employees.select do |_id, info|
      info[:department].strip.downcase == department_name.downcase
    end

    if matched_employees.empty?
      puts "No employees found in the '#{department_name}' department."
      return
    end

    puts "\nEmployees in #{department_name} Department"

    matched_employees.each do |id, info|
      puts "Employee ID: #{id}"
      puts "Name: #{info[:emp_name]}"
      puts "Designation: #{info[:designation]}"
      puts "Monthly Salary: #{info[:monthly_salary]}"
      puts "--------------------------"
    end
  end
end

# combining all the attendance operations related together
module AttendanceOperations
  include EmployeeHelper
  # 7. Mark attendance
  def mark_attendance(id, day, month, year, status)
    employee = find_employee(id)
    return if employee.nil?

    if day < 1 || day > 31
      puts "Day must be between 1 and 31."
      return
    end

    if month < 1 || month > 12
      puts "Month must be between 1 and 12."
      return
    end

    if year < 1
      puts "Invalid year."
      return
    end
    
    status = status.to_s.strip.downcase

    unless ["present", "absent"].include?(status)
      puts "Status must be present or absent."
      return
    end

    duplicate = employee[:attendance].any? do |record|
      record[:day_attended] == day &&
        record[:month] == month &&
        record[:year] == year
    end

    if duplicate
      puts "Attendance has already been marked for this date."
      return
    end

    employee[:attendance] << {
      day_attended: day,
      month: month,
      year: year,
      status: status
    }

    puts "Attendance marked as #{status} for employee #{id}."
  end
end

# combining all the Leave operations related together
module LeaveOperations
  include EmployeeHelper
  # 8. Apply for leave
  def apply_for_leave(id, days_requested, reason, month, year)
    employee = find_employee(id)
    return if employee.nil?

    if month < 1 || month > 12 || year < 1
      puts "Invalid month or year."
      return
    end

    if days_requested <= 0 || days_requested > 2
      puts "Leave must be between 1 and 2 days per request."
      return
    end

    if reason.empty?
      puts "Leave reason cannot be empty."
      return
    end

    active_request = employee[:leaves].any? do |leave|
      leave[:month] == month &&
        leave[:year] == year &&
        ["pending", "approved"].include?(leave[:status])
    end

    if active_request
      puts "An active leave request already exists for this month."
      return
    end

    employee[:leaves] << {
      leave_days: days_requested,
      reason: reason,
      status: "pending",
      month: month,
      year: year
    }

    puts "Leave request created with status pending."
  end

  # 9. Approve or reject leave
  def check_leave(id, decision)
    employee = find_employee(id)
    return if employee.nil?

    pending_leave = employee[:leaves].find do |leave|
      leave[:status] == "pending"
    end

    if pending_leave.nil?
      puts "No pending leave requests found."
      return
    end

    decision = decision.to_s.strip.downcase

    if decision == "approve"
      approved_days = employee[:leaves].select do |leave|
        leave[:status] == "approved" &&
          leave[:month] == pending_leave[:month] &&
          leave[:year] == pending_leave[:year]
      end.sum { |leave| leave[:leave_days].to_i }

      if approved_days + pending_leave[:leave_days].to_i > 2
        pending_leave[:status] = "rejected"
        puts "Leave rejected: Monthly paid leave limit exceeded."
        return
      end

      pending_leave[:status] = "approved"
      puts "Leave approved."

    elsif decision == "reject"
      pending_leave[:status] = "rejected"
      puts "Leave rejected."

    else
      puts "Invalid decision. Enter approve or reject."
    end
  end

  # 10. View employee attendance and leave
  def view_summary(id)
    employee = find_employee(id)
    return if employee.nil?

    puts "\nEmployee ID: #{id}"
    puts "Name: #{employee[:emp_name]}"

    puts "\nAttendance Records:"
    if employee[:attendance].empty?
      puts "No attendance records found."
    else
      employee[:attendance].each do |record|
        puts "#{record[:day_attended]}/#{record[:month]}/#{record[:year]} - #{record[:status]}"
      end
    end

    puts "\nLeave Records:"
    if employee[:leaves].empty?
      puts "No leave records found."
    else
      employee[:leaves].each do |leave|
        puts "Days: #{leave[:leave_days]}"
        puts "Reason: #{leave[:reason]}"
        puts "Status: #{leave[:status]}"
        puts "--------------------------"
      end
    end
  end
end

# combining all the Salary operations related together
module SalaryOperations
  include EmployeeHelper
  # 11. Generate monthly salary report
  def monthly_salary_report(id, month, year)
    employee = find_employee(id)
    return if employee.nil?

    if month < 1 || month > 12 || year < 1
      puts "Invalid month or year."
      return
    end

    present_days = employee[:attendance].count do |record|
      record[:status] == "present" &&
        record[:month] == month &&
        record[:year] == year
    end

    approved_leave_days = employee[:leaves].select do |leave|
      leave[:status] == "approved" &&
        leave[:month] == month &&
        leave[:year] == year
    end.sum { |leave| leave[:leave_days].to_i }

    approved_leave_days = [approved_leave_days, 2].min

    base_salary = employee[:monthly_salary]

    payable_salary = base_salary *
      (present_days + approved_leave_days) / 30.0

    puts "\nMonthly Salary Report"
    puts "Employee id: #{id}"
    puts "Employee name: #{employee[:emp_name]}"
    puts "Base salary: #{base_salary}"
    puts "Present days: #{present_days}"
    puts "Approved paid leave days: #{approved_leave_days}"
    puts "Payable salary: #{payable_salary.round(2)}"
  end

  # 12. View department budget summary
  def budget_summary(department)
    # check matching employees using department
    matched_employees = @registered_employees.select do |_id, info|
      info[:department].strip.downcase == department.downcase
    end
    
    if matched_employees.empty?
      puts "No employees found in the '#{department}' department."
      return
    end

    employee_count = matched_employees.size
    
    department_salary = matched_employees.sum do |_id, info|
      info[:monthly_salary].to_f
    end

    company_salary = @registered_employees.values.sum do |info|
      info[:monthly_salary].to_f
    end

    budget_remaining = Employee.budget - company_salary

    puts "\nDepartment Budget Summary"
    puts "Department: #{department}"
    puts "Employee count: #{employee_count}"
    puts "Department monthly salary total: #{department_salary}"
    puts "Company budget: #{Employee.budget}"
    puts "Company monthly salary total: #{company_salary}"
    puts "Budget remaining: #{budget_remaining}"
  end

end
  

class Employee
  attr_accessor :emp_name, :department, :designation, :monthly_salary

  @@budget = 1_00_00_000

  def initialize
    @registered_employees = {}
  end
  
  def self.budget
  @@budget
  end

  include EmployeeOperations
  include AttendanceOperations
  include LeaveOperations
  include SalaryOperations

  # Menu-driven method
  def menu_driven
    loop do
      puts "\n===== Employee Management System ====="
      puts "1.  Add Employee"
      puts "2.  View All Employees"
      puts "3.  Search Employee"
      puts "4.  Update Employee Details/Salary"
      puts "5.  Delete Employee"
      puts "6.  View Employees by Department"
      puts "7.  Mark Attendance"
      puts "8.  Apply for Leave"
      puts "9.  Approve or Reject Leave"
      puts "10. View Employee Attendance and Leave"
      puts "11. Generate Monthly Salary Report"
      puts "12. View Department Budget Summary"
      puts "13. Exit"

      print "Please enter your choice (1-13): "
      choice = gets.chomp.to_i

      case choice
      when 1
        print "Enter Employee ID: "
        id = gets.chomp

        print "Enter Employee Name: "
        name = gets.chomp.to_s

        print "Enter Department: "
        department = gets.chomp.to_s

        print "Enter Designation: "
        designation = gets.chomp.to_s

        print "Enter Monthly Base Salary: "
        salary = gets.chomp.to_f

        create_employee(id, name, department, designation, salary)

      when 2
        view_all_employees

      when 3
        print "Enter Employee ID to search: "
        id = gets.chomp

        result = search_employee(id)

        if result
          puts "Name: #{result[:emp_name]}"
          puts "Department: #{result[:department]}"
          puts "Designation: #{result[:designation]}"
          puts "Monthly Salary: #{result[:monthly_salary]}"
        end

      when 4
        print "Enter Employee ID to update: "
        id = gets.chomp
        update_employee(id)

      when 5
        print "Enter Employee ID to delete: "
        id = gets.chomp
        delete_employee(id)

      when 6
        print "Enter Department Name: "
        department_name = gets.chomp
        view_employees_by_department(department_name)

      when 7
        print "Enter Employee ID: "
        id = gets.chomp

        print "Enter Day: "
        day = gets.chomp.to_i

        print "Enter Month: "
        month = gets.chomp.to_i

        print "Enter Year: "
        year = gets.chomp.to_i

        print "Enter Status (present/absent): "
        status = gets.chomp

        mark_attendance(id, day, month, year, status)

      when 8
        print "Enter Employee ID: "
        id = gets.chomp

        print "Enter Number of Leave Days: "
        days = gets.chomp.to_i

        print "Enter Leave Reason: "
        reason = gets.chomp

        print "Enter Leave Month (1-12): "
        month = gets.chomp.to_i

        print "Enter Leave Year: "
        year = gets.chomp.to_i

        apply_for_leave(id, days, reason, month, year)

      when 9
        print "Enter Employee ID: "
        id = gets.chomp

        print "Enter Decision (approve/reject): "
        decision = gets.chomp

        check_leave(id, decision)

      when 10
        print "Enter Employee ID: "
        id = gets.chomp
        view_summary(id)

      when 11
        print "Enter Employee ID: "
        id = gets.chomp

        print "Enter Month (1-12): "
        month = gets.chomp.to_i

        print "Enter Year: "
        year = gets.chomp.to_i

        monthly_salary_report(id, month, year)

      when 12
        print "Enter Department: "
        department = gets.chomp
        budget_summary(department)

      when 13
        puts "Exiting... Goodbye!"
        break

      else
        puts "Invalid choice. Please try again."
      end
    end
  end
end

# Create an object and run the menu
employee = Employee.new
employee.menu_driven