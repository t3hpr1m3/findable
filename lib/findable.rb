module Findable
  def self.included( base )
    base.send :extend, ClassMethods
  end

  module ClassMethods
    def findable_attribute( name, id_field = false )
      @@findable_attributes ||= []
      @@findable_attributes << name
      @@findable_id_field ||= nil
      @@findable_id_field = name unless id_field == false
      attr_accessor name
    end

    def findable_id_field
      @@findable_id_field
    end

    def findable_attributes
      @@findable_attributes
    end

    def method_missing( method_id, *arguments )
      method_name = method_id.to_s
      if md = /^find_(all_by|last_by|by)_([_a-zA-Z]\w*)$/.match( method_name )
        finder = :first
        finder = :last if $1 == 'last_by'
        finder = :all if $1 == 'all_by'
        name = $2
        if findable_attributes.include?( name.to_sym )
          self.class_eval %{
            def self.#{method_id}(*args)
              options = args.extract_options!
              find( :#{finder}, options.merge( { :#{name} => args.first } ) )
            end
          }, __FILE__, __LINE__
          send( method_id, *arguments )
        else
          super
        end
      else
        super
      end
    end

    def find_from_id( *args )
      idf = findable_id_field
      if idf.nil?
        nil
      else
        select_from_findable( { idf => args.first } ).first
      end
    end

    def select_from_findable( options )
      if options.keys.length == 0
        self.findable_data
      else
        self.findable_data.select { |s|
          is_match = true
          options.each { |key, value|
            t = s.instance_variable_get( "@#{key}" )
            case t
            when Fixnum:
              begin
                v = value.to_i
              rescue
                is_match = false
              end
            when Float:
              begin
                v = value.to_f
              rescue
                is_match = false
              end
            else
              v = value
            end
            if t != v
              is_match = false
              break
            end
          }
          is_match
        }
      end
    end

    def first( options )
      if options.keys.length == 0
        findable_data.first
      else
        select_from_findable( options ).first
      end
    end

    def last( options )
      if options.keys.length == 0
        findable_data.last
      else
        self.select_from_findable( options ).last
      end
    end

    def find( *args )
      if self.findable_data.nil?
        nil
      else
        finder = args.first
        options = args.extract_options!
        case finder
        when :first then self.first( options )
        when :last then self.last( options )
        when :all then select_from_findable( options )
        else find_from_id( args.first, options )
        end
      end
    end
  end
end
