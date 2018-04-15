namespace :filelist do
  desc 'Generate *.rb filelist'
  task :generate do
    sh('rm -f filelist')
    filelist = Dir['gems/**/*.rb']
    File.write('filelist', filelist.join("\n"))
    sh('wc -l filelist')
  end
end
