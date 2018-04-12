class RubyFilesCollection
  def initialize(filepath)
    @filepath = filepath
  end

  def each_filepath
    return to_enum(:each_filepath) unless block_given?

    File.open(@filepath, 'r').each_line.map do |line|
      filepath = line.chomp

      if File.file?(filepath)
        yield(filepath)
      end
    end
  end
end

namespace :mri do
  # rvm use 2.5.1
  # rake mri:parse
  desc 'Run MRI against files listed in filelist'
  task :parse do
    puts "Running againg MRI #{RUBY_VERSION}"

    require 'ripper'

    parsed = RubyFilesCollection.new('filelist').each_filepath.select do |filepath|
      source = File.read(filepath)
      if Ripper.sexp(source)
        true
      else
        puts "Skipping #{filepath}"
        false
      end
    end

    output = "valid-for-#{RUBY_VERSION}"
    File.write(output, parsed.join("\n"))

    parsed = parsed.length
    skipped = File.open('filelist').count - parsed

    puts "Done. #{parsed} files can be parsed (skipped #{skipped}). Filelist is exported to #{output}"
  end
end
