class Brand < ActiveRecord::Base

  searchable do
    text :name
  end

end
