# WorkCalendar

WorkCalendar enables you to perform simple date calculations given a user's weekly work schedule and the holidays that are the exceptions.

## Usage

```ruby
require 'work_calendar'

WorkCalendar.configure do |c|
  c.weekdays = %i[sun mon tue wed thu fri sat]
  c.holidays = [Date.new(2015, 1, 1), Date.new(2015, 7, 3), Date.new(2015, 12, 25)]
end

# determine if a given date is "active", i.e. a work day
WorkCalendar.active?(Date.new(2015, 1, 1)) #=> false

# return the date the specified number of "active" days *before* a date
WorkCalendar.days_before(5, Date.new(2015, 1, 5))

# return the date the specified number of "active" days *after* a date
WorkCalendar.days_after(5, Date.new(2015, 1, 5))

# return the "active" dates between two dates, exclusive of the second date
WorkCalendar.between(Date.new(2015, 1, 1), Date.new(2015, 1, 8))
```

## Considerations

1. **Module vs class**: 
The first decision I made was whether WorkCalendar should be a class or module. Classes are typically used for instantiating new objects and instances; modules are for easily sharing methods across multiple classes. Since WorkCalendar would be globally used across an application and no new instances would ever be created, a module was the more appropriate choice.

2. **Configuration: set vs array**: 
One easy way to speed up performance is to use a set rather than array for `WorkCalendar.config.weekdays` and `WorkCalendar.config.holidays`. Since the `active?` method checks its date argument against both arrays, the worst case lookup time is the combined length of the arrays. By using a set, the lookup would be reduced to constant time.

3. **Invalid params**: 
Does the module gracefully handle unexpected or invalid input?

    3a. _Configuration_

    If the user attempts to set an attribute that does not exist on the `Configuration`, an error is raised. If they attempt to set the valid `weekdays` or `holidays` attributes as something other than a list or as a list with something other than weekday symbols or Date objects respectively, they will not encounter an error immediately. While we could add additional safeguards, this is really up to the user using the module to ensure they set the configs correctly.

    3b. _Module methods_

    Assuming the user calls the method with the expected argument types, the notable edge cases occur in the `days_before`, `days_after`, and `between` methods. What should happen if a user uses a negative integer for `days_before` or `days_after`? What should happen if a user passes dates in the reverse order to `between`? Arguably we could consider a negative integer in the first example to do the reverse and look at days after in `days_before` and vice versa. Since we have both methods, however, I leave it up to the user using the module to pick the correct method and pass it an integer greater than or equal to 0. If they don't, the method raises an ArgumentError. The same goes for the `between` method.
