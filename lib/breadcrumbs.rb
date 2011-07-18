module Breadcrumbs
  def self.included receiver
    receiver.extend ClassMethods
  end

  module ClassMethods
    def add_breadcrumb title, url, *args
      options = args.extract_options!
      before_filter options do |controller|
        url = controller.send(url) if url.class == Symbol
        controller.send(:add_breadcrumb, title, url)
      end
    end
    def add_breadcrumb_for_resource instance_variable, title, *args
      options = args.extract_options!
      before_filter options do |controller|
        resource = controller.send(:instance_variable_get, "@#{instance_variable}")
        controller_path = controller.send(:controller_path)
        name = resource.send(title)
        url = '/'+controller_path+"/"+resource.id.to_s
        controller.send(:add_breadcrumb, name, url)
      end
    end
    def add_breadcrumb_for_actions *args
      options = args.extract_options!
      before_filter options do |controller|
        current_action = controller.send(:params)['action']
        controller.send(:add_breadcrumb, ActiveSupport::Inflector.humanize(current_action), '')
      end
    end
    
  end
  def add_breadcrumb title, url = ''
    @breadcrumbs ||= []
    @breadcrumbs << Crumb.new(title,url)
  end
  
  class Crumb
    attr_accessor :title, :url
    def initialize(title, url)
      @title = title
      @url = url
    end
  end
end
