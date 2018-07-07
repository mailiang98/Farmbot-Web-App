# Keep track of all JWTs created incase we need to revoke them later (before the
# expiration date).
class TokenIssuance < ApplicationRecord
  belongs_to :device
  after_destroy :maybe_evict_clients

  def broadcast?
    false
  end

  # PROBLEM:
  #     A token issuance was destroyed, but people are still on the broker using
  #     a revoked token.
  #
  # COMPLICATED SOLUTION:
  #     Track the JTI of all users and selectively boot only the users that have
  #     an expired JTI. This requires external caching and session storage.
  #
  # SIMPLE SOLUTION:
  #     Kick _everyone_ off the broker. The clients with the revoked token will
  #     not be able to reconnect.
  def maybe_evict_clients
    Transport::Mgmt.try(:close_connections_for_username, "device_#{device_id}")
  rescue Faraday::ConnectionFailed
    Rollbar.error("Failed to evict clients on token revocation")
  end

  def self.expired
    self.where("exp < ?", Time.now.to_i)
  end

  def self.any_expired?
    expired.any?
  end

  def self.clean_old_tokens
    expired.destroy_all
  end
end
