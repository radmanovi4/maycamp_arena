class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages, :force => true do |t|
      t.string :subject, :null => false
      t.text :body, :null => false
      t.text :emails_sent
      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
