# WorkCalendar

WorkCalendar enables you to perform simple date calculations given a user's weekly work schedule and the additional holidays they have off.

## Usage

```ruby
require 'work_calendar'

WorkCalendar.configure do |c|
  c.weekdays = %i[mon tue wed thu fri]
  c.holidays = [Date.new(2015, 1, 1), Date.new(2015, 7, 3), Date.new(2015, 12, 25)]
end

# determine if a given date is "active", i.e. the user is working
WorkCalendar.active?(Date.new(2015, 1, 1))
#=> false

# return the date the specified number of "active" days *before* a date
WorkCalendar.days_before(5, Date.new(2015, 1, 5))
#=> <Date: 2014-12-26 ((2457018j,0s,0n),+0s,2299161j)>

# return the date the specified number of "active" days *after* a date
WorkCalendar.days_after(5, Date.new(2015, 1, 5))
#=> <Date: 2015-01-12 ((2457035j,0s,0n),+0s,2299161j)>

# return the "active" dates between two dates, exclusive of the second date
WorkCalendar.between(Date.new(2015, 1, 1), Date.new(2015, 1, 8))
#=> [#<Date: 2015-01-02 ((2457025j,0s,0n),+0s,2299161j)>,
#    #<Date: 2015-01-05 ((2457028j,0s,0n),+0s,2299161j)>,
#    #<Date: 2015-01-06 ((2457029j,0s,0n),+0s,2299161j)>,
#    #<Date: 2015-01-07 ((2457030j,0s,0n),+0s,2299161j)>]
```

## Implementation

To allow WorkCalendar to be configurable, I added a Configuration class that has `weekdays` and `holidays` as `attr_accessor`s . The WorkCalendar `configure` method stores or instantiates a Configuration object as its own `attr_accessor` `config`, and then initializes it via a block. The only things that can be set in the block are the Configuration `attr_accessor`s.

The methods in WorkCalendar are implemented in Ruby.

## Considerations

1. Module vs class

The first decision I made was whether WorkCalendar should be a class or module. According to the Ruby docs, classes are typically for instantiating new objects and instances; modules are for easily sharing methods across multiple classes. Since WorkCalendar would be globally used across an application and no new instances would ever be created, a module was the more appropriate choice.

2. Set vs array in configuration

One easy way to speed up performance is to use a set rather than array for `WorkCalendar.config.weekdays` and `WorkCalendar.config.holidays`. Since the `active?` method checks its date argument against both arrays, the worst case lookup time is the combined length of the arrays. By using a set, the lookup would be reduced to constant time.

3. Invalid params

Does the module gracefully handle unexpected or invalid input?

- Configuration

If the user attempts to set an attribute that does not exist on the `Configuration`, an error is raised. If they attempt to set the valid `weekdays` or `holidays` attributes as something other than a list or as a list with something other than weekday symbols or Date objects respectively, they will not encounter an error immediately. While we could add additional safeguards, this is really up to the user using the module to ensure they set the configs correctly.

- Module methods

Assuming the user calls the method with the expected argument types, the notable edge cases occur in the `days_before`, `days_after`, and `between` methods. What should happen if a user uses a negative integer for `days_before` or `days_after`? What should happen if a user passes dates in the reverse order to `between`? Arguably we could consider a negative integer in the first example to do the reverse and look at days after in `days_before` and vice versa. Since we have both methods, however, I leave it up to the user using the module to pick the correct method and pass it an integer greater than or equal to 0. If they don't, the method raises an ArgumentError. Similarly, for the `between` method, we keep its behavior consistent by requiring the start date and then the end date, and returning the resulting dates in chronological order.
