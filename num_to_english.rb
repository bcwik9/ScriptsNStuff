###
# Ben Cwik
# 2015
# Description: Simple script which takes a single integer parameter and returns the english representation of it
# Usage: ruby <scriptname> <number>
###

# class which converts ints to english representations
class NumConverter
  # calculates largest supported number based off of
  # the values in the POWER_OF_TEN array
  def self.get_maximum_supported_number
    (10**((POWER_OF_TEN.size+1) * 3)) - 1
  end
  
  # given an integer, returns the english representation
  def self.num_to_english i
    # some simple sanity checks
    ret = ''
    return ret if i.nil? # return empty string if were given nothing
    return 'zero' if i.to_i == 0

    # handle negative numbers
    negative = (i.to_i < 0) ? 'negative ' : ''
    i = i.to_i.abs.to_s # convert to absolute value

    # check to make sure we can support the english version
    raise 'Number too large' if get_maximum_supported_number < i.to_i

    # keep track of where we are in the number
    power_counter = 0
    # convert number string to an array
    num_arr = i.split ''
    
    # keep pulling off sets of 3 digits and process them until
    # there are no more
    while !num_arr.empty?
      # pull off 3 digits
      current_num = num_arr.pop(3).join ''
      # get english representation of the 3 digits
      current_english = get_hundred_representation current_num
      # figure out postfix if we have a number greater than 999
      postfix = (power_counter == 0) ? '' : POWER_OF_TEN[power_counter-1]
      power_counter += 1
      # skip if the section was 0
      next if current_english.empty?
      # add postfix if necessary
      current_english += " #{postfix}" unless postfix.empty?
      # add to our return value
      ret = current_english + ' ' + ret
    end

    # return and add negative if necessary
    return negative + ret
  end

  # takes a string representation of a number up to 999
  # returns the english counterpart of the parameter
  def self.get_hundred_representation num
    # input should have 3 digits or less
    raise 'Invalid number specified' unless num.size <= 3

    # what we'll return
    ret = ''

    # hundred position
    if num.size == 3
      hundred = num[0].to_i # get the digit
      ret = "#{DOUBLE_DIGITS[hundred]} hundred" if hundred != 0
    end

    # rightmost two digits are special
    # they include the uniquely named single digits and teens
    two_digits = num.to_i % 100
    return ret if two_digits == 0
    # add a space if there was a third digit
    ret += ' and ' unless ret.empty?
    # look up appropriate english version of the two digits
    # nineteen is the last uniquely named number
    if two_digits <= 19
      # no need to combine numbers
      ret += DOUBLE_DIGITS[two_digits]
    else
      # combine two numbers
      single_digit = two_digits % 10
      ret += DOUBLE_DIGITS[two_digits-single_digit]
      ret += " " + DOUBLE_DIGITS[single_digit] unless single_digit == 0
    end

    return ret
  end
  
  # hash of numbers required to make any number between 1 and 999
  DOUBLE_DIGITS = {
    1 => 'one',
    2 => 'two',
    3 => 'three',
    4 => 'four',
    5 => 'five',
    6 => 'six',
    7 => 'seven',
    8 => 'eight',
    9 => 'nine',
    10 => 'ten',
    11 => 'eleven',
    12 => 'twelve',
    13 => 'thirteen',
    14 => 'fourteen',
    15 => 'fifteen',
    16 => 'sixteen',
    17 => 'seventeen',
    18 => 'eighteen',
    19 => 'ninteen',
    20 => 'twenty',
    30 => 'thirty',
    40 => 'fourty',
    50 => 'fifty',
    60 => 'sixty',
    70 => 'seventy',
    80 => 'eighty',
    90 => 'ninety'
  }

  # list of important power of 10 names
  # simply add additional names to support larger numbers
  POWER_OF_TEN = [
    'thousand',
    'million',
    'billion',
    'trillion',
    'quadrillion',
    'quintillion',
    'sextillion',
    'septillion',
    'octillion',
    'nonillion',
    'decillion'
  ]
end



# *** MAIN ***
puts NumConverter.num_to_english ARGV.first
