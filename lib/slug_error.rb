class SlugError < StandardError
  attr_accessor :retrieved_element
  
  def initialize(e)
    self.retrieved_element = e
  end
end