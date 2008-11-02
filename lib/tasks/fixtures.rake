# This is breaking things in production environment
if RAILS_ENV=='development'
  namespace :db do
    namespace :fixtures do
      # handy task from http://fukamachi.org/wp/2007/05/18/rails-dump-database-to-fixtures-preserving-utf8/
      desc 'Create YAML test fixtures from data in an existing database.  
      Defaults to development database.  Set RAILS_ENV to override.'
      require 'ya2yaml'
      task :extract => :environment do
        sql  = "SELECT * FROM %s"
        skip_tables = %w(schema_info filters locations location_aliases polling_places schema_migrations)
        ActiveRecord::Base.establish_connection
        (ActiveRecord::Base.connection.tables - skip_tables).each do |table_name|
          i = "000"
          File.open("#{RAILS_ROOT}/test/fixtures/#{table_name}.yml", 'w') do |file|
            data = ActiveRecord::Base.connection.select_all(sql % table_name)
            file.write data.inject({}) { |hash, record|
              hash["#{table_name}_#{i.succ!}"] = record
              hash
            }.ya2yaml
          end
        end
      end
  
    end
  end
end