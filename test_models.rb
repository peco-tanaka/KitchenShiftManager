#!/usr/bin/env ruby

# Simple test script to validate our issue review models syntax
puts "Testing Issue Review Models Syntax"
puts "=" * 40

# Test Ruby syntax of our model files
files_to_test = [
  'app/models/issue.rb',
  'app/models/review.rb',
  'app/controllers/api/issues_controller.rb',
  'app/controllers/api/reviews_controller.rb'
]

files_to_test.each do |file|
  begin
    # Just check syntax, don't execute
    result = `ruby -c #{file} 2>&1`
    if $?.success?
      puts "✓ #{file} - Syntax OK"
    else
      puts "✗ #{file} - Syntax Error: #{result}"
    end
  rescue => e
    puts "✗ #{file} - Error: #{e.message}"
  end
end

# Test React component files
react_files = [
  'frontend/src/App.tsx',
  'frontend/src/pages/IssueList.tsx',
  'frontend/src/pages/IssueDetail.tsx',
  'frontend/src/pages/CreateIssue.tsx'
]

puts "\nTesting React Components"
puts "=" * 40

react_files.each do |file|
  if File.exist?(file)
    # Basic check for React component structure
    content = File.read(file)
    if content.include?('export default') && content.include?('React')
      puts "✓ #{file} - Component structure OK"
    else
      puts "? #{file} - May have issues"
    end
  else
    puts "✗ #{file} - File not found"
  end
end

puts "\nFile structure check complete! 🎉"

# Check if key directories exist
dirs = ['app/models', 'app/controllers/api', 'frontend/src/pages', 'db/migrate']
puts "\nChecking directory structure:"
dirs.each do |dir|
  if Dir.exist?(dir)
    puts "✓ #{dir} exists"
  else
    puts "✗ #{dir} missing"
  end
end