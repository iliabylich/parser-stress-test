namespace :filelist do
  desc 'Generate *.rb filelist'
  task :generate do
    sh('rm -f filelist')
    sh('find gems -iname *.rb > filelist')
    sh('wc -l filelist')
  end
end
