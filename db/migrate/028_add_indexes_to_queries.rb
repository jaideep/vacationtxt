class AddIndexesToQueries < ActiveRecord::Migration
  def self.up    
    
    say_with_time "Clearing Duplicate Queries" do
      listing_hash = Hash.new("listing_id_hash")
      Query.find(:all).each do |q|
        if listing_hash.has_key? q.listing_id
          subHash = listing_hash[q.listing_id]
          if subHash.has_key? q.pick_list_id
            Query.delete(q.id)
          else
            subHash[q.pick_list_id] = q;
          end
        else
          newHash = Hash.new("listing_#{q.listing_id}")
          newHash[q.pick_list_id] = q;
          listing_hash[q.listing_id] = newHash;
        end
      end
    end
    
    add_index :queries, ["listing_id", "pick_list_id"], :name=>"listing_and_picklist_index", :unique=>true
    add_index :queries, "listing_id", :name=>"listing_id_foreign_key_idx", :unique=>false
    add_index :queries, "pick_list_id", :name=>"pick_list_id_foreign_key_idx", :unique=>false
  end

  def self.down
    remove_index :queries, :name=>"listing_and_picklist_index"
    remove_index :queries, :name=>"listing_id_foreign_key_idx"
    remove_index :queries, :name=>"pick_list_id_foreign_key_idx"
  end
end
