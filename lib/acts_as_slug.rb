module ActiveRecord
  module Acts
    module Slug
      def self.included(base)
        base.extend(ClassMethods)
      end
    
      module ClassMethods
        def acts_as_slug(slug_array, options = {})
          raise "You need novelys_hacks plugin in order to use the acts_as_slug plugin" unless String.new.respond_to?(:to_slug)
          
          write_inheritable_attribute(:slug_array, slug_array)
          class_inheritable_reader :slug_array
          write_inheritable_attribute(:slug_options, options)
          class_inheritable_reader :slug_options
          
          def find_with_slug!(slug, *args)
            raise ActiveRecord::RecordNotFound unless slug.present?
            res = find_by_slug(slug)
            if res.nil?
              if slug_options[:append_id]
                res = find(SlugUtilities.id_from_slug(slug), *args)
                if res && res.slug.blank?
                  res.update_slug!
                end
                raise SlugError, res unless res.slug == slug
              else
                raise ActiveRecord::RecordNotFound
              end
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
            new_slug = self.make_slug
            conditions = self.new_record? ? ["slug like ?", new_slug + "%"] : ["slug like ? and id <> ?", new_slug + "%", self.id]
            elements = self.class.find(:all, :conditions => conditions, :order => "slug ASC").find_all {|o| o.slug_base == SlugUtilities.base_from_slug(new_slug) }
            self.slug = elements.empty? ? new_slug : new_slug + "-" + (elements.size + 1).to_s
          end
        end
        
        def after_save
          update_slug! if slug.blank? 
          @current_slug = nil
        end

        def to_param
          current_slug
        end
        
        def current_slug
          self.update_slug! if self.slug.blank? 
          @current_slug ||= self.slug
        end
        
        def make_slug
          arbitrary_string = /\A\/(.*)\/\Z/
          evaluated_slug_array = slug_array.inject([]) { |m, v| m << (v =~ arbitrary_string ? v.slice(arbitrary_string, 1) : eval("#{v.to_s}.to_slug") rescue ""); m }

          base_slug = case slug_options[:separator]
                      when nil then evaluated_slug_array.join "-"
                      when false then evaluated_slug_array.join ""
                      else evaluated_slug_array.join(slug_options[:separator])
                      end
          if slug_options[:append_id] == true
            if base_slug.length + self.id.to_s.length + 1 > 254
              base_slug = base_slug[0..254]
              base_slug[-(self.id.to_s.length + 1), (self.id.to_s.length + 1)] = '-' + self.id.to_s
            else
              base_slug = "#{base_slug}-#{self.id}"
            end
          end
          base_slug
        end

        def update_slug!
          self.update_attribute :slug, make_slug
        rescue
          make_slug
        end
        
        def slug_base
          SlugUtilities.base_from_slug(self.current_slug)
        end
        
        def slug_id
          SlugUtilities.id_from_slug(self.current_slug)
        end
      end #module InstanceMethods
    end #module Related
  end #module Acts
end #module ActiveRecord
