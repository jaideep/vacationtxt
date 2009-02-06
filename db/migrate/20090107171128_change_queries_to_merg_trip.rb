class ChangeQueriesToMergTrip < ActiveRecord::Migration
  def self.up
    remove_index :queries,:name=>"pick_list_id_foreign_key_idx"
    remove_index :queries,:name=>"listing_and_picklist_index"
    remove_column :queries,:pick_list_id
    add_column :queries,:check_in,:date
    add_column :queries,:check_out,:date
    add_column :queries,:user_id,:integer
    add_index :queries,"user_id"
  end

  def self.down
    remove_index :queries,"user_id"
    remove_column :queries,:user_id
    remove_column :queries,:check_in
    remove_column :queries,:check_out
    add_column :queries,:pick_list_id,:integer
    add_index :queries,"pick_list_id",:name=>"pick_list_id_foreign_key_idx"
    add_index :queries,["listing_id","pick_list_id"],:name=>"listing_and_picklist_index"
  end
end
