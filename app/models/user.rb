class User < ApplicationRecord
  has_many :doacaos, dependent: :destroy
  has_many :telefones

  validates :username, presence: true, uniqueness: true
  validates :full_name, presence: true
  validates :gender, inclusion: { in: %w[M F] }
  validates :dob, presence: true
  validates :tipo_sanguineo, inclusion: { in: %w[A+ A- B+ B- AB+ AB- O+ O-] }
end
