require 'active_record/railtie'

ActiveRecord::Base.establish_connection(
  ENV['DATABASE_URL'] || 'postgresql://dev:devpass@localhost:5432/attendance_dev'
)