namespace :jasmine do
  namespace :ci do
    desc "Run Jasmine CI build headlessly"
    task :headless do
      Headless.ly do
        puts "Running Jasmine Headlessly"
        Rake::Task['jasmine:ci'].invoke
      end
    end
  end
end