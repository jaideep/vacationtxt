module ActiveRecordExtension
  module AttributeHelpers
    
  public
    def set_if_nil(attr,value)
      write_attribute(attr,value) if read_attribute(attr).nil?
    end
  end
end