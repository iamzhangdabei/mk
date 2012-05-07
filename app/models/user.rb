class User < ActiveRecord::Base
  include Privilege
  class NotAuthorized < StandardError
  end

  class MyCryptoProvider
    # Turns your raw password into a Sha1 hash.
    def self.encrypt(*tokens)
      digest = Digest::SHA1.hexdigest("--#{tokens[1]}--#{tokens[0]}--")
      digest
    end

    # Does the crypted password match the tokens? Uses the same tokens that were used to encrypt.
    def self.matches?(crypted, *tokens)
      encrypt(*tokens) == crypted
    end
  end

  acts_as_authentic do |c|
    #    c.transition_from_crypto_providers= ::MyCryptoProvider
    #    c.crypto_provider = Authlogic::CryptoProviders::Sha512
    c.login_field = :login
    c.crypto_provider = MyCryptoProvider
    c.disable_perishable_token_maintenance true
  end
  #  attr_accessible :login, :email, :password, :password_confirmation
end
