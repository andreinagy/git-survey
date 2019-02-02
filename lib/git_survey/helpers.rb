# Convenience utilities.
class Helpers
  def self.anonymized(anonymize, string)
    if anonymize
      Digest::MD5.hexdigest(string)[0...10]
    else
      string
    end
  end
end
