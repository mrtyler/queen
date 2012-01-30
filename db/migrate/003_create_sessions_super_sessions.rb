class CreateSessionsSuperSessions < ActiveRecord::Migration
  def self.up
    create_table :sessions_super_sessions do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :sessions_super_sessions
  end
end
