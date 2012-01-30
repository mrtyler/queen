class CreateAchievementsPeople < ActiveRecord::Migration
  def self.up
    create_table :achievements_people do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :achievements_people
  end
end
