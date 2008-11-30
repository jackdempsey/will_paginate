require 'will_paginate/finders/base'
require 'sequel'
module WillPaginate::Finders
  module Sequel

    include WillPaginate::Finders::Base

    protected

    def wp_query(options, pager, args, &block)
      find_options = options.except(:count, :offset, :limit, :all, :conditions, :order)
      #use dup below as the array thats passed around is changed later on
      find_options = options[:conditions].dup if options[:conditions]

      result = if find_options.empty?
        dataset.limit(pager.per_page, pager.offset)
      else
        dataset.filter(find_options).limit(pager.per_page, pager.offset)
      end

      if options[:order]
        pager.replace result.order(options[:order]).all
      else
        pager.replace result.all
      end

      unless pager.total_entries
        pager.total_entries = wp_count(options)
      end
    end

    def wp_count(options)
      count_options = options.except(:count, :order, :limit, :offset, :conditions)
      count_options = options[:conditions] if options[:conditions]
      count_options.empty?? count() : filter(count_options).count
    end

  end
end

# lets you bring in pagination to your model with "include WP::Sequel" in the class definition
module WillPaginate
  module Sequel
    def self.included(klass)
      klass.extend WillPaginate::Finders::Sequel
    end
  end
end