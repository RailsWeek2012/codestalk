class Snippet < ActiveRecord::Base
  attr_accessible :description, :language, :library, :source, :title, :user_id, :user, :library_id, :language_id
  belongs_to :user
  belongs_to :library
  belongs_to :language
end
