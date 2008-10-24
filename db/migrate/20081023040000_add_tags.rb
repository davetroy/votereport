class AddTags < ActiveRecord::Migration
  def self.up
    [ { :pattern => 'machine',           :description => 'Problem with voting machine(s)', :score => 2 },
      { :pattern => 'registration',      :description => 'Problems with the registration process', :score => 3 },
      { :pattern => 'wait:?(\d+)',       :description => 'Indicates wait time', :score => 0 },
      { :pattern => 'challenges',        :description => 'Widespread challenges occurring at the location', :score => 4 },
      { :pattern => 'hava',              :description => 'Accessibility issues', :score => 2 },
      { :pattern => 'ballots',           :description => 'Out or running out of paper ballots', :score => 3 },
      { :pattern => 'good',              :description => 'Good overall experience', :score => 0 },
      { :pattern => 'bad',               :description => 'Bad overall experience', :score => 3 },
      { :pattern => '\sEP[A-Z]{2}\s?',   :description => 'Election Protection, with State', :score => 2 } ].each { |t| Tag.create(t) }
  end

  def self.down
    Tag.connection.execute('TRUNCATE TABLE tags')
  end
end