class User < ActiveRecord::Base
  attr_accessible :email, :name
  has_one :authorization
  has_many :snippets
  has_many :comments
  validates :name, :email, :presence => true

  def add_provider(auth_hash)
    # Check if the provider already exists, so we don't add it twice
    unless authorizations.find_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"])
      Authorization.create :user => self, :provider => auth_hash["provider"], :uid => auth_hash["uid"]
    end
  end

  def omniauth_failure
    redirect_to init_sign_in_users_path
    #redirect wherever you want.
  end
end