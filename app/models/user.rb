class User < ActiveRecord::Base
  ROLES = %w[admin event_manager]

  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable, :timeoutable, :confirmable and :activatable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation

  has_many :events

  def admin?
    self.role == 'admin'
  end
end
