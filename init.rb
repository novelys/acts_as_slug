require 'slug_error'
require 'acts_as_slug'

ActiveRecord::Base.send(:include, ActiveRecord::Acts::Slug)
