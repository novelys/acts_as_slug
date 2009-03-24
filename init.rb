require 'slug_error'
require 'slug_utilities'
require 'acts_as_slug'

ActiveRecord::Base.send(:include, ActiveRecord::Acts::Slug)
