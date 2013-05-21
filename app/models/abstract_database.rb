# Super class of all my model used to specify generic properties
#
class AbstractDatabase < ActiveRecord::Base
  self.abstract_class = true
  establish_connection ::Conf.db
  
  def self.insert(values)
    tuple = self.new(values)
    WLLogger.logger.warn "Tuple could not be inserted properly : #{tuple.errors}" unless tuple.save     
  end  
end
