class Comment < AbstractDatabase
  attr_accessible :owner, :text, :title
  def self.setup
    unless @setup_done      
      validates :owner, :presence => true
      validates :text, :presence => true
      validates :title, :presence => true
      
      self.table_name = "comments"
      connection.create_table 'comments', :force => true do |t|
        t.string :title
        t.string :owner
        t.string :text
        t.timestamps
      end if !connection.table_exists?('comments')
      
      @setup_done = true
    end # unless @setup_done
  end # self.setup
  
  def self.table_name
    'comments'
  end
  
  def self.schema
    {'title' => 'string',
     'owner' => 'string',
     'text' => 'string'
     }
  end
  setup  
end