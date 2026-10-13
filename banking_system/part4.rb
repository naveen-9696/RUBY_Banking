
class Bank
  attr_reader :account_number
  attr_accessor :account_holder, :account_type, :opening_balance
  
  def initialize
    @registered_accounts = {}
  end 
  
  # Creating a new account 
  def create_account(number, name, type, balance)
    # Checking whether the account number is empty
    if number.nil? || number.to_s.strip.empty? 
      puts "Account number should not be empty"
      return
    end
    
    # Checking account holder name is empty or not and reject if empty 
    if name.nil?
      puts "Account holder name should not be empty"
      return 
    end

    # Checking duplicate account number 
    if @registered_accounts.key?(number)
      puts "Rejected: Account number already exists"
      return
    end
    
    if type == "savings" && balance < 1000
      puts "Rejected: opening balance should not be below 1000"
      return
    end
    
    @registered_accounts[number] = {
      account_holder: name,
      account_type: type,
      opening_balance: balance,
      history: [
        {
          operation: "Account Created",
          amount: balance,
          balance_after: balance
        }
      ]
    }

    puts "Account #{number} created. Balance: INR #{balance}"
  end

  # Deposit function 
  def deposit(number, amount)
    account = @registered_accounts[number]

    if amount <= 0 
      puts "Rejected; no balance change"
      return
    end

    account[:opening_balance] += amount
    account[:history] << {
      operation: "Deposit",
      amount: amount,
      balance_after: account[:opening_balance]
    }
    puts "Deposit Successful. #{number} balance: the amount present in account is INR #{account[:opening_balance]}"
    account[:opening_balance]
  end
  
  # Withdrawal function
  def withdraw(number, amount)
    account = @registered_accounts[number]
    
    current_balance = account[:opening_balance] - amount

    # Withdrawal amount should not be negative
    if amount < 0
      puts "Withdrawal rejected: amount should not be negative"
      return
    end

    # Checking if withdrawal amount is greater than the present balance amount
    if amount > account[:opening_balance]
      puts "Rejected; Insufficient funds"
      return
    end

    if account[:account_type] == "savings" && current_balance <= 1000
      puts "Withdrawal rejected: Minimum savings balance should be greater than INR 1000.00"
      return 
    end

    account[:opening_balance] = current_balance
    puts "Withdrawal successful. #{number}: the amount present in account is INR #{account[:opening_balance]}"

    account[:history] << {
      operation: "Withdraw",
      amount: amount,
      balance_after: account[:opening_balance]
    }

    amount
  end
  
  # Loan calculation using simple interest
  def loan_calculation(type, amount, time)
    # Time should not be less than or equal to  0
    if time <= 0
      puts "Loan Tenure should not be invalid"
      return
    end

    # Checking and calculating the loan interest
    loan = if type == "personal"
             (amount * 12 * time) / 100
           else
             (amount * 8 * time) / 100
           end

    puts "#{type} loan:"
    puts "Loan interest: #{loan}"
    puts "Total Payable amount: #{amount + loan}"
  end

  # Show history 
  def show_history(number)
    account = @registered_accounts[number]

    # Checking if history has successful operations or not
    if account[:history].empty?
      puts "No Successful transaction is present"
      return 
    end
    
    account[:history].each_with_index do |transaction, index|
      puts "#{index + 1}. #{transaction[:operation]}"
      puts "   Amount: INR #{transaction[:amount]}"
      puts "   Balance After: INR #{transaction[:balance_after]}"
      puts "--------------------------------"
    end
  end
  
  def savings_to_current
    puts "Enter the saving account number from u want to sent amount:"
    saving_acc_number = gets.chomp

    puts "Enter the amount to transfer:"
    saving_amount = gets.chomp.to_i

    puts "Enter the account number u want to sent amount:"
    curr_acc_number = gets.chomp
    
    withdrawal_amount = withdraw(saving_acc_number, saving_amount)
    
    # Check if withdrawal succeeded or not
    if withdrawal_amount.is_a?(Numeric)
      current_balance_amount = deposit(curr_acc_number, withdrawal_amount)
      puts "Amount transferred successfully!"
      puts "New current account balance: INR #{current_balance_amount}"
    else
      puts "Transfer failed because withdrawal could not be completed."
    end
  end
  
  def current_to_savings 
    puts "Enter the current account number from you want to send amount:"
    curr_acc_number = gets.chomp

    puts "Enter the amount to transfer:"
    transfer_amount = gets.chomp.to_i

    puts "Enter the savings account number you want to send amount to:"
    saving_acc_number = gets.chomp
    
    withdrawal_amount = withdraw(curr_acc_number, transfer_amount)

    # Check if withdrawal succeeded or not
    if withdrawal_amount.is_a?(Numeric)
      new_savings_balance = deposit(saving_acc_number, withdrawal_amount)
      puts "Amount transferred successfully!"
      puts "New savings account balance: INR #{new_savings_balance}"
    else
      puts "Transfer failed because withdrawal could not be completed."
    end
  end
end

acc = Bank.new
acc.create_account("abc123", "Naveen", "savings",10000)

# acc.deposit("abc123",0)
acc.create_account("abc121","Aayushi","current",5000)
acc.withdraw("abc121",5001)
# acc.withdraw("abc123",10000)
# acc.loan_calculation("home",500000,0)

# acc.savings_to_current
# acc.show_history("abc123")
# acc.current_to_savings
