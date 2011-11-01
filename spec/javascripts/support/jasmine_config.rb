# When jasmine starts the server out-of-process, it needs this in order to be able to invoke the asset tasks.
# This step, along with the coffeescript compilation for jasmine is borrowed and modified from Jeff Dean's blog post
# http://pivotallabs.com/users/jdean/blog/articles/1778-writing-and-running-jasmine-specs-with-rails-3-1-and-coffeescript
unless Object.const_defined?(:Rake)
  require 'rake'
  load File.expand_path('../../../../Rakefile', __FILE__)
end

module Jasmine
  class Config

    def js_files(spec_filter = nil)
      prepare_jasmine_coffeescript
      prepare_code_coverage_coffeescript

      # This is code from the original jasmine config js_files method - you could also just alias_method_chain it
      spec_files_to_include = spec_filter.nil? ? spec_files : match_files(spec_dir, [spec_filter])
      src_files.collect {|f| "/" + f } + helpers.collect {|f| File.join(spec_path, f) } + spec_files_to_include.collect {|f| File.join(spec_path, f) }
    end

    private

    # Convenience method for recursively deleting our files from previous Jasmine runs
    def delete_coffeescript source_path
      if not File.exists?(File.dirname(File.expand_path(source_path, __FILE__)))
        return
      end
      
      generated_directory = File.dirname(File.expand_path(source_path, __FILE__))
      Dir.foreach(generated_directory) do |file|
        if file != generated_directory && file == '.' && file == '..'
          if File.directory?(file)
            FileUtils.rm_rf(file)
          else
            FileUtils.rm(file)
          end
        end
      end
    end
    
    # Convenience method for compiling coffeescript to all the places we need it
    def compile_coffeescript source_path, destination_path
      # Jasmine testing directories
      Dir.mkdir(File.dirname(File.expand_path(destination_path, __FILE__))) unless File.exists?(File.dirname(File.expand_path(destination_path, __FILE__)))
      
      # Compile coffee script from the project into the test directory
      root = File.expand_path(source_path, __FILE__)
      destination_dir = File.expand_path(destination_path, __FILE__)
      glob = File.expand_path("**/*.js.coffee", root)
      Dir.glob(glob).each do |srcfile|
        srcfile = Pathname.new(srcfile)
        destfile = srcfile.sub(root, destination_dir).sub(".coffee", "")
        FileUtils.mkdir_p(destfile.dirname)
        File.open(destfile, "w") {|f| f.write(CoffeeScript.compile(File.new(srcfile)))}
      end
    end

    # This method compiles all of the spec files into js files that Jasmine can run
    def prepare_jasmine_coffeescript
      # Remove previously compiled project coffeescript and spec coffeescript
      delete_coffeescript("../../../generated/")
      
      # Compile project coffeescript and spec coffeescript
      compile_coffeescript("../../../../app/assets/javascripts/builder/", "../../../generated/javascripts/")
      compile_coffeescript("../../../coffeescripts/specs/", "../../../generated/specs/")
    end
    
    def prepare_code_coverage_coffeescript
      delete_coffeescript("../../../../coverage/javascripts/uninstrumented/public/javascripts/")
      delete_coffeescript("../../../../coverage/javascripts/instrumented/public/javascripts/")
      
      compile_coffeescript("../../../../app/assets/javascripts/builder/", "../../../../coverage/javascripts/uninstrumented/public/javascripts/")
      compile_coffeescript("../../../coffeescripts/specs/", "../../../../coverage/javascripts/uninstrumented/public/javascripts/")
    end
  end
end


# Note - this is necessary for rspec2, which has removed the backtrace
module Jasmine
  class SpecBuilder
    def declare_spec(parent, spec)
      me = self
      example_name = spec["name"]
      @spec_ids << spec["id"]
      backtrace = @example_locations[parent.description + " " + example_name]
      parent.it example_name, {} do
        me.report_spec(spec["id"])
      end
    end
  end
end
