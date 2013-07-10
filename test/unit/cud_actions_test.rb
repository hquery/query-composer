require 'test_helper'
require 'cud_actions'
include Devise::TestHelpers

class CudActionsTest < ActionController::TestCase
  
  setup do
    dump_database
    CudResource.all.each {|x| x.destroy}
    @controller = CudResourceController.new
    
    @admin = FactoryGirl.create(:admin)
    sign_in @admin
    
  end
  
  def get_fake_resource
    r = CudResource.new
    r.name = 'foo'
    r
  end
  
  test "make sure create creates" do
    
    resource = get_fake_resource
    
    do_with_route do
      assert_difference('CudResource.count') do
        post :create, cud_resource: resource.attributes
      end

      assert_redirected_to "/cud_resource/"+assigns[:cud_resource].id.to_s
      assert_equal 1, CudResource.all.count
    end
    
  end

  test "make sure update updates" do
    
    resource = get_fake_resource
    resource.save!
    
    do_with_route do
      put :update, id: resource.to_param, cud_resource: resource.attributes
      assert_redirected_to "/cud_resource/"+assigns[:cud_resource].id.to_s
    end
    
  end

  test "make sure destroy destroys" do
    
    resource = get_fake_resource
    resource.save!
    
    do_with_route do
      delete :destroy, id: resource.to_param

      assert_redirected_to "/cud_resources"
      assert_equal 0, CudResource.all.count
    end
    
  end
  
  test "make sure before and after called on create" do
    
    resource = get_fake_resource
    
    def @controller.before_create
      @before_method_called = true 
    end 
    def @controller.after_create
      @after_method_called = true
      render text: 'foo'
    end 
    
    do_with_route do
      post :create, cud_resource: resource.attributes

      assert @controller.send(:instance_variable_get, "@before_method_called")
      assert @controller.send(:instance_variable_get, "@after_method_called")

    end
    
  end

  test "make sure before and after called on update" do
    
    resource = get_fake_resource
    resource.save!
    
    def @controller.before_update
      @before_method_called = true 
    end 
    def @controller.after_update
      @after_method_called = true
      render text: 'foo'
    end 
    
    do_with_route do
      put :update, id: resource.to_param, cud_resource: resource.attributes

      assert @controller.send(:instance_variable_get, "@before_method_called")
      assert @controller.send(:instance_variable_get, "@after_method_called")

    end
    
  end

  test "make sure before and after called on destroy" do
    
    resource = get_fake_resource
    resource.save!
    
    def @controller.before_destroy
      @before_method_called = true 
    end 
    def @controller.after_destroy
      @after_method_called = true
      render text: 'foo'
    end 
    
    do_with_route do
      delete :destroy, id: resource.to_param

      assert @controller.send(:instance_variable_get, "@before_method_called")
      assert @controller.send(:instance_variable_get, "@after_method_called")

    end
    
  end
  
  
  def do_with_route

    QueryComposer::Application.routes.draw do
      resources :cud_resource
      root :to => 'cud_resources#index'
      
    end

    yield
    
    QueryComposer::Application.reload_routes!
    
  end
  
  
end

class CudResource
  include Mongoid::Document
  
  field :name, type: String
end

class CudResourceController < ApplicationController
  include CudActions
  skip_authorization_check
  creates_updates_destroys :cud_resource
  load_resource
  
  def cud_resources_path
    "/cud_resources" 
  end
end
