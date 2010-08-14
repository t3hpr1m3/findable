# Findable 0.0.1

## Motivation
You're developing a Rails application that gets it's data from an unsupported source (by unsupported, I mean it's not a database, not ActiveResource capable, etc).  This could be an old socket server, flat files, etc.  Like a good developer, you're using Ruby classes to represent that data, like so (assuming something xml-like):

    class Car
      attr_accessor :color
      attr_accessor :year
      attr_accessor :make
      attr_accessor :model

      def self.get_cars
        list_of_cars = get_from_service_and_parse
      end
    end

You've wrapped all the dirty work of accessing the data store in the model, which is good.  In your controllers, you can call Car.get_cars, and magically, the list of Car objects comes across.  Fantastic.

But what about filtering?  You could add a bunch of methods to your Car class, or add one `find` method that takes a hash of arguments.  But doing this on several models quickly becomes a pain.

## Documentation
Using Findable is easy.  Simply `include Findable` in the class, change `attr_accessor` to `findable_attribute` for any attribute you want to be searchable, and `findable_method`, padding it the method to use to retrieve an array of objects.  Continuing the above example:

    class Car
      include Findable
      findable_attribute :color
      findable_attribute :year
      findable_attribute :make
      findable_attribute :model
	  findable_data :get_cars
    end

At this point, we can use find methods similar to ActiveRecord.

    Car.find(:all)
    Car.find(:first, :year => 2010)
    Car.find_by_color("red")
    Car.find_all_by_make("Porsche")

### ID attributes
If you have an attribute that acts like an ID (something that would be in the URL of your RESTful rails application), simply pass `true` to findable_attribute:

    findable_attribute :car_id, true

and now you can use

    @car = Cars.find( params[:id] )

