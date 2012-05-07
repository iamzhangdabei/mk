class LockTimeout < Exception
end
class ActiveRecord::Base
  def self.global_lock name, timeout = nil
    v = (if timeout
      connection.select_value "select get_lock('#{name}',#{timeout})"
    else
      connection.select_value "select get_lock('#{name}')"
    end)
    raise LockTimeout unless v == '1'
    yield
  ensure
    connection.select_value "select release_lock('#{name}')"
  end
  
  def global_lock name, timeout = nil, &block
    self.class.global_lock name, timeout, &block
  end
end