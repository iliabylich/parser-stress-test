require 'open-uri'
require 'zlib'

class RemoteGem < Struct.new(:name, :version)
  include FileUtils

  def bucket
    name[0..1]
  end

  def downloaded?
    Dir["gems/#{bucket}/#{name}-#{version}"].any?
  end

  def download
    sh("gem fetch '#{name}' --version #{version}")
  end

  def unpack
    sh("gem unpack '#{name}'")
  end

  def remove_file
    sh("rm '#{name}-#{version}.gem'")
  end

  def move_to_own_dir
    sh("mkdir -p 'gems/#{bucket}'")
    sh("mv '#{name}-#{version}' 'gems/#{bucket}/'")
  end
end

namespace :gems do
  gems_to_exclude = %w[
    -
    _
    AbsoluteRenamer-system
  ]

  desc 'Download all gems'
  task :download do
    sh('mkdir -p gems')

    gzipped = open('https://rubygems.org/latest_specs.4.8.gz'); false
    marshalled = Zlib::GzipReader.new(gzipped).read; false
    gems = Marshal.load(marshalled)

    pool = Concurrent::FixedThreadPool.new(20)

    gems.each do |gem_name, version, platform|
      next unless platform == 'ruby'
      next if gems_to_exclude.include?(gem_name)
      remote_gem = RemoteGem.new(gem_name, version)
      next if remote_gem.downloaded?

      pool.post do
        remote_gem.download
        remote_gem.unpack
        remote_gem.remove_file
        remote_gem.move_to_own_dir
      end
    end

    pool.wait_for_termination
  end
end
