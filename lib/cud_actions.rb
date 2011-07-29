module CudActions
  def self.included receiver
    receiver.extend ClassMethods
  end

  module ClassMethods
    def creates_updates_destroys resource_name
      creates resource_name
      updates resource_name
      destroys resource_name
    end
    def destroys resource_name
      self.send(:define_method, :destroy, -> {  generic_destroy(resource_name) }) unless (self.respond_to? :destroy) 
    end
    def updates resource_name
      self.send(:define_method, :update, -> { generic_update(resource_name) }) unless (self.respond_to? :update) 
    end
    def creates resource_name
      self.send(:define_method, :create, -> { generic_create(resource_name) }) unless (self.respond_to? :create) 
    end

  end
  
  def generic_destroy(resource_name)
    before_destroy if self.respond_to? :before_destroy
    resource = send(:instance_variable_get, "@#{resource_name}")
    resource.destroy
    if (self.respond_to? :after_destroy) 
      after_destroy
    else 
      redirect_to send("#{resource_name.to_s.pluralize}_path")
    end
  end

  def generic_update(resource_name)
    before_update if self.respond_to? :before_update
    resource = send(:instance_variable_get, "@#{resource_name}")
    if resource.update_attributes(params[resource_name])
      if (self.respond_to? :after_update) 
        after_update
      else 
        redirect_to resource, notice: "#{resource_name.to_s.humanize} was successfully updated."
      end
    else
      render action: "edit"
    end
  end

  def generic_create(resource_name)
    before_create if self.respond_to? :before_create
    resource = send(:instance_variable_get, "@#{resource_name}")
    if resource.save
      if (self.respond_to? :after_create) 
        after_create
      else 
        redirect_to resource, notice: '#{resouce_name.to_s.humanize} was successfully created.'
      end
    else
      render action: "new"
    end
  end
    
end
