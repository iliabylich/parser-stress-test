namespace :parser do
  desc "Run Parser version ENV['VERSION'] against files listed in ENV['FILELIST']"
  task :parse do
    version = ENV.fetch('VERSION') { raise "ENV['VERSION'] can't be blank" }
    filelist = ENV.fetch('FILELIST') { raise "ENV['FILELIST'] can't be blank" }

    require 'bundler/setup'
    require "parser/ruby#{version}"

    parser = Parser.const_get(:"Ruby#{version}").new
    parser.diagnostics.all_errors_are_fatal = true
    parser.diagnostics.ignore_warnings      = true

    RubyFilesCollection.new(filelist).each_filepath do |filepath|
      begin
        buffer = Parser::Source::Buffer.new(filepath)
        buffer.source = File.read(filepath)
        parser.parse(buffer)
      rescue => e
        if e.message =~ /literal contains escape sequences/
          # ignoring
        elsif e.message =~ /invalid multibyte escape/
          # ignoring
        elsif e.is_a?(EncodingError)
          # ignoring
        elsif e.message =~ /too short escaped multibyte character/
          # ignoring
        elsif e.message =~ /invalid multibyte character/
          # ignoring
        else
          p [filepath, e.class, e.message]
        end
      ensure
        parser.reset
      end
    end
  end
end
