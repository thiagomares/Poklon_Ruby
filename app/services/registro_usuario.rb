class Users
  attr_accessor :dob

  def initialize(dob)
    @dob = dob
  end

  def dob_parser
    Date.parse(@dob)
  end

  def minimum_age
    if dob_parser.year - Date.today.year < 16
      false
    end
  end
end
