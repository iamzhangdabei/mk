module User::Privilege
  extend ActiveSupport::Concern
  included do
    has_and_belongs_to_many :roles
  end

  def guest?
    id == 0
  end
  alias anonymous? guest?

  def role_names
    roles.collect{|r|r.name}.join(' ')
  end
  # has_role? simply needs to return true or false whether a user has a role or not.
  # It may be a good idea to have "admin" roles return true always

  def has_role?(role_in_question)
    @_list ||= self.role_names
    return true if @_list.include?("admin")
    (@_list.include?(role_in_question.to_s) )
  end

  def is_admin?
    !guest? && has_role?('admin')
  end

end
