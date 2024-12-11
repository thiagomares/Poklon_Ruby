class Usuario
  attr_accessor :dob

  def initialize(dob)
    @dob = dob
  end

  def dob_parser
    Date.parse(@dob)
  end
end
