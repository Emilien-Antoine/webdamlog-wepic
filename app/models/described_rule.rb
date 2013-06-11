class DescribedRule < AbstractDatabase
  attr_accessible :description, :rule
  
  def self.setup
    unless @setup_done      
      validates :description, :presence => false
      validates :rule, :presence => true
      
      self.table_name = "describedRule"
      connection.create_table 'describedRule', :force => true do |t|
        t.text :description
        t.text :rule
        t.timestamps
      end if !connection.table_exists?('describedRule')
      
      @setup_done = true
    end 
  end
  
  def self.table_name
    'describedRule'
  end
  
  def default_values
    self.description = "No description"
  end
  
  def self.schema
    {'rule' => 'string',
     'description' => 'string'
     }
  end
  
  setup  
  
  before_validation :default_values
  
end