module ActiveRecord
  module Acts
    module Slug
      def self.included(base)
        base.extend(ClassMethods)
      end
    
      module ClassMethods
        def acts_as_slug(slug_array, options = {})
          
          write_inheritable_attribute(:slug_array, slug_array)
          class_inheritable_reader :slug_array
          write_inheritable_attribute(:slug_options, options)
          class_inheritable_reader :slug_options
          
          def find_with_slug!(slug, *args)
            if slug_options[:append_id]
              res = find(SlugUtilities.id_from_slug(slug), *args)
              raise SlugError, res unless res.to_slug == slug
            else
              res = find_by_slug(slug)
              raise ActiveRecord::RecordNotFound if res.nil?
            end
            res.current_slug
            res
          end

          include ActiveRecord::Acts::Slug::InstanceMethods
          extend ActiveRecord::Acts::Slug::SingletonMethods
        end
      end #module ClassMethods
      
      module SingletonMethods
      end
    
      module InstanceMethods

        def before_save
          unless slug_options[:append_id] == true
            new_slug = self.to_slug
            conditions = self.new_record? ? ["slug like ?", new_slug + "%"] : ["slug like ? and id <> ?", new_slug + "%", self.id]
            elements = self.class.find(:all, :conditions => conditions, :order => "slug ASC").find_all {|o| o.slug_base == self.slug_base }
            self.slug = elements.empty? ? new_slug : new_slug + "-" + (elements.size + 1).to_s
          end
        end
        
        def after_save
          @current_slug = nil
        end

        def to_param
          current_slug
        end
        
        def current_slug
          @current_slug ||= slug_options[:append_id] ? self.to_slug : self.slug
        end
        
        def to_slug
          arbitrary_string = /\A\/(.*)\/\Z/
          evaluated_slug_array = slug_array.inject([]) { |m, v| m << (v =~ arbitrary_string ? v.slice(arbitrary_string, 1) : eval("self.#{v.to_s}.to_slug") rescue ""); m }

          base_slug = case slug_options[:separator]
                      when nil then evaluated_slug_array.join "-"
                      when false then evaluated_slug_array.join ""
                      else evaluated_slug_array.join(slug_options[:separator])
                      end
          
          slug_options[:append_id] == true ? "#{base_slug}-#{self.id}" : base_slug
        end
        
        def slug_base
          SlugUtilities.base_from_slug(current_slug)
        end
        
        def slug_id
          SlugUtilities.id_from_slug(current_slug)
        end
      end #module InstanceMethods
    end #module Related
  end #module Acts
end #module ActiveRecord
