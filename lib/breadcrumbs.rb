module Breadcrumbs
  def self.included receiver
    receiver.extend ClassMethods
  end

  module ClassMethods
    def add_breadcrumb name, url, *args
      options = args.extract_options!
      before_filter options do |controller|
        url = controller.send(url) if url.class == Symbol
        controller.send(:add_breadcrumb, name, url)
      end
    end
    def add_breadcrumb_for_resource instance_variable, name_method, *args
      options = args.extract_options!
      before_filter options do |controller|
        resource = controller.send(:instance_variable_get, "@#{instance_variable}")
        controller_path = controller.send(:controller_path)
        name = resource.send(name_method)
        url = '/'+controller_path+"/"+resource.id.to_s
        controller.send(:add_breadcrumb, name, url)
      end
    end
    def add_breadcrumb_for_actions *args
      options = args.extract_options!
      before_filter options do |controller|
        current_action = controller.send(:params)['action']
        controller.send(:add_breadcrumb, current_action, '')
      end
    end
    
  end
  def add_breadcrumb name, url = ''
    @breadcrumbs ||= []
    url = eval(url) if url =~ /_path|_url|@/
    @breadcrumbs << [name, url]
  end
end
