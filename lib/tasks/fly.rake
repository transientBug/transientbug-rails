namespace :fly do
  # BUILD step:
  #  - changes to the fs make here DO get deployed
  #  - NO access to secrets, volumes, databases
  #  - Failures here prevent deployment
  task :build => 'assets:precompile'

  # RELEASE step:
  #  - changes to the fs make here are DISCARDED
  #  - access secrets, databases
  #  - Failures here prevent deployment
  task :release => 'db:migrate'

  # SERVER step:
  #  - changes to the fs make here are deployed
  #  - access secrets, databases
  #  - Failures here result in VM being stated, shutdown, and rollback
  #    to last successful VM.
  task :server do
    sh 'bin/rails server'
  end
end
