#!/usr/bin/env ruby
# frozen_string_literal: true

# Tests verifying the security fixes in rsh (Phase 1 + Phase 2).
# These read the source file and check that dangerous patterns
# have been replaced with safe alternatives.

require 'minitest/autorun'

class TestRshSecurityFixes < Minitest::Test
  RSH_SOURCE = File.read(File.join(__dir__, '..', 'bin', 'rsh'))

  # --- Phase 1: xclip shell injection fix ---

  def test_xclip_uses_io_popen
    assert_match(/IO\.popen\('xclip', 'w'\)/, RSH_SOURCE,
      "xclip call should use IO.popen, not system with string interpolation")
  end

  def test_xclip_no_system_echo
    refute_match(/system\("echo -n.*xclip"\)/, RSH_SOURCE,
      "old system(\"echo ... | xclip\") pattern must be removed")
  end

  # --- Phase 1: EDITOR calls use array form ---

  def test_editor_ctrl_g_uses_array_form
    # The Ctrl-G handler should use: system(ENV['EDITOR'] || 'vi', temp_file)
    assert_match(/system\(ENV\['EDITOR'\] \|\| 'vi', temp_file\)/, RSH_SOURCE,
      "Ctrl-G editor call should use array form of system()")
  end

  def test_editor_auto_open_uses_array_form
    # The auto-open handler should use: system(ENV['EDITOR'] || 'vi', @cmd)
    assert_match(/system\(ENV\['EDITOR'\] \|\| 'vi', @cmd\)/, RSH_SOURCE,
      "Auto-open editor call should use array form of system()")
  end

  def test_no_interpolated_editor_in_system
    # No system("#{ENV['EDITOR']}...") calls should remain
    refute_match(/system\(".*#\{ENV\['EDITOR'\]\}/, RSH_SOURCE,
      "No system() calls should use string interpolation with EDITOR")
  end

  # --- Phase 1: run-mailcap and xdg-open use Shellwords.escape ---

  def test_run_mailcap_uses_shellwords_escape
    assert_match(/run-mailcap #\{Shellwords\.escape\(@cmd\)\}/, RSH_SOURCE,
      "run-mailcap call should use Shellwords.escape on @cmd")
  end

  def test_xdg_open_uses_shellwords_escape
    assert_match(/xdg-open #\{Shellwords\.escape\(@cmd\)\}/, RSH_SOURCE,
      "xdg-open call should use Shellwords.escape on @cmd")
  end

  # --- Phase 1: bare rescues replaced with specific exceptions ---

  def test_no_bare_rescues
    # Match "rescue" on its own line (with only whitespace), not "rescue SomeError"
    bare_rescues = RSH_SOURCE.scan(/^\s*rescue\s*$/)
    assert_empty bare_rescues,
      "No bare rescue statements should remain; found #{bare_rescues.length}"
  end

  def test_dir_entries_rescues_are_specific
    # All Dir.entries rescues should catch Errno::EACCES, Errno::ENOENT
    dir_entry_blocks = RSH_SOURCE.scan(/Dir\.entries.*?rescue\s+(\S[^\n]*)/m)
    dir_entry_blocks.each do |match|
      exception_list = match[0]
      assert_match(/Errno::EACCES/, exception_list,
        "Dir.entries rescue should catch Errno::EACCES")
      assert_match(/Errno::ENOENT/, exception_list,
        "Dir.entries rescue should catch Errno::ENOENT")
    end
  end

  def test_eval_rescues_are_specific
    # Eval-related rescues for nick/gnick should catch SyntaxError, StandardError
    eval_blocks = RSH_SOURCE.scan(/eval\(\$1\).*?rescue\s+(\S[^\n]*)/m)
    assert(eval_blocks.length >= 2,
      "Should find at least 2 eval-related rescue blocks (nick + gnick)")
    eval_blocks.each do |match|
      exception_list = match[0]
      assert_match(/SyntaxError/, exception_list,
        "Eval rescue should catch SyntaxError")
      assert_match(/StandardError/, exception_list,
        "Eval rescue should catch StandardError")
    end
  end

  # --- Phase 2: backtick calls use Shellwords.escape ---

  def test_help_backticks_use_shellwords_escape
    # get_command_switches should escape the command before backtick execution
    assert_match(/escaped = Shellwords\.escape\(command\)/, RSH_SOURCE,
      "get_command_switches should escape command with Shellwords")
    assert_match(/`#\{escaped\} --help 2>\/dev\/null`/, RSH_SOURCE,
      "backtick --help call should use escaped variable")
    assert_match(/`#\{escaped\} -h 2>\/dev\/null`/, RSH_SOURCE,
      "backtick -h call should use escaped variable")
  end

  def test_no_unescaped_command_backticks
    # The old pattern should be gone
    refute_match(/`#\{command\} --help/, RSH_SOURCE,
      "Raw command interpolation in backticks should be replaced with escaped version")
  end

  # --- Phase 2: Shellwords loaded lazily ---

  def test_shellwords_loaded_lazily
    # Should NOT have a bare top-level require 'shellwords'
    # Should use: require 'shellwords' unless defined?(Shellwords)
    assert_match(/require 'shellwords' unless defined\?\(Shellwords\)/, RSH_SOURCE,
      "Shellwords should be loaded lazily with defined? guard")
  end
end
