#!/usr/bin/env ruby
# Test script for plugin system

require 'fileutils'

puts "Testing rsh Plugin System v3.2.0"
puts "="*50

# Test 1: Plugin files exist
puts "\nTest 1: Plugin files"
plugin_dir = File.expand_path("~/.rsh/plugins")
plugins = Dir.glob(plugin_dir + "/*.rb")
puts "  ✓ Plugin directory: #{plugin_dir}"
puts "  ✓ Found #{plugins.length} plugins:"
plugins.each { |p| puts "    - #{File.basename(p)}" }

# Test 2: Plugin syntax
puts "\nTest 2: Plugin syntax validation"
plugins.each do |plugin_file|
  result = `ruby -c #{plugin_file} 2>&1`
  if result.include?("Syntax OK")
    puts "  ✓ #{File.basename(plugin_file)}: Syntax OK"
  else
    puts "  ✗ #{File.basename(plugin_file)}: #{result}"
  end
end

# Test 3: Plugin class naming
puts "\nTest 3: Plugin class naming convention"
test_cases = {
  "git_prompt" => "GitPromptPlugin",
  "command_logger" => "CommandLoggerPlugin",
  "kubectl_completion" => "KubectlCompletionPlugin",
  "my_tools" => "MyToolsPlugin",
  "k8s" => "K8sPlugin"
}

test_cases.each do |file, expected|
  result = file.split('_').map(&:capitalize).join + 'Plugin'
  status = result == expected ? "✓" : "✗"
  puts "  #{status} #{file}.rb → #{result} (expected: #{expected})"
end

# Test 4: Load and instantiate plugins
puts "\nTest 4: Plugin loading simulation"
plugins.each do |plugin_file|
  plugin_name = File.basename(plugin_file, '.rb')
  begin
    load(plugin_file)
    class_name = plugin_name.split('_').map(&:capitalize).join + 'Plugin'

    if Object.const_defined?(class_name)
      plugin_class = Object.const_get(class_name)
      mock_context = {version: "3.2.0", history: [], bookmarks: {}}
      instance = plugin_class.new(mock_context)

      # Check for hooks
      hooks = [:on_startup, :on_command_before, :on_command_after, :on_prompt].select do |hook|
        instance.respond_to?(hook)
      end

      # Check for extensions
      exts = [:add_completions, :add_commands].select do |ext|
        instance.respond_to?(ext)
      end

      puts "  ✓ #{plugin_name}: #{class_name}"
      puts "    Hooks: #{hooks.join(', ')}" unless hooks.empty?
      puts "    Extensions: #{exts.join(', ')}" unless exts.empty?
    else
      puts "  ✗ #{plugin_name}: Class #{class_name} not found"
    end
  rescue => e
    puts "  ✗ #{plugin_name}: #{e.message}"
  end
end

puts "\n" + "="*50
puts "Plugin system tests complete!"
puts "Start rsh to see plugins in action"
