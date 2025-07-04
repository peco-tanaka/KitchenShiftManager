# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "start seed data creation..."

# 成功・失敗を追跡する変数
success_count = 0
error_count = 0

puts "Creating manager user..."

# 管理者ユーザーの作成
begin
  # 既存ユーザーの確認
  manager = User.find_by(employee_number: "0001")

  if manager.present?
    puts "Manager user already exists: #{manager.last_name} #{manager.first_name} (Employee Number: #{manager.employee_number})"
    success_count += 1
  else
    # 新規作成
    manager = User.create!({
      employee_number: "0001",
      password: "1000",
      password_confirmation: "1000",
      last_name: "管理者",
      first_name: "店長",
      role: "manager",
      hourly_wage: 1500, # 時給1500円
      hired_on: Date.new(2025, 1, 1), # 2025年1月1日入社
      terminated_on: nil # 在職中
    })
    puts "Manager user created successfully: #{manager.last_name} #{manager.first_name} (Employee Number: #{manager.employee_number})"
    success_count += 1
  end
rescue => e
  puts "An error occurred while creating the manager user: #{e.message}"
  if defined?(manager) && manager&.errors&.any?
    manager.errors.full_messages.each do |error|
      puts "Error: #{error}"
    end
  end
  error_count += 1
end

# 開発環境用の従業員ユーザーの作成
if Rails.env.development?
  puts "Creating development employee users..."

  begin
    # 既存ユーザーの確認
    sample_employee = User.find_by(employee_number: 0002)

    if sample_employee.present?
      puts "Sample employee user already exists: #{sample_employee.last_name} #{sample_employee.first_name} (Employee Number: #{sample_employee.employee_number})"
      success_count += 1
    else
      # 新規作成
      sample_employee = User.create!({
        employee_number: "0002",
        password: "1001",
        password_confirmation: "1001",
        last_name: "山田",
        first_name: "太郎",
        role: "employee",
        hourly_wage: 1200, # 時給1200円
        hired_on: Date.new(2025, 2, 1), # 2025年2月1日入社
        terminated_on: nil # 在職中
      })
      puts "Sample employee user created successfully: #{sample_employee.last_name} #{sample_employee.first_name} (Employee Number: #{sample_employee.employee_number})"
      success_count += 1
    end
  rescue => e
    puts "An error occurred while creating the sample employee user: #{e.message}"
    if defined?(sample_employee) && sample_employee&.errors&.any?
      sample_employee.errors.full_messages.each do |error|
        puts "Error: #{error}"
      end
    end
    error_count += 1
  end
end


# 結果の表示（条件分岐付き）
puts "\n" + "="*50
if error_count == 0
  puts "🎉 Seed data creation completed successfully!"
  puts "✅ All users created/verified: #{success_count}"
else
  puts "⚠️  Seed data creation completed with errors!"
  puts "✅ Successful operations: #{success_count}"
  puts "❌ Failed operations: #{error_count}"
end

puts "\n📋 Expected user accounts:"
puts "  Manager: employee_number=0001, password=1000"
if Rails.env.development?
  puts "  Sample Employee: employee_number=0002, password=1001"
end
puts "\n⚠️  Important: Change passwords in production environment!"
puts "="*50