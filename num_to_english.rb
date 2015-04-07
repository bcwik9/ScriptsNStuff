SINGLE = {
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
  19 => 'ninteen'
}

DOUBLE = {
  20 => 'twenty',
  30 => 'thirty',
  40 => 'fourty',
  50 => 'fifty',
  60 => 'sixty',
  70 => 'seventy',
  80 => 'eighty',
  90 => 'ninety'
}

BIG = [
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

# given an integer, returns the english representation
def num_to_english i
  # some simple sanity checks
  ret = ''
  return ret if i.nil? # return empty string if were given nothing
  return 'zero' if i.to_i == 0

  # check to make sure we can support the english version
  max = (10**((BIG.size+1) * 3)) - 1
  raise 'Number too large' if max < i.to_i

  power_counter = 0
  num_arr = i.split ''
  while !num_arr.empty?
    current_num = num_arr.pop(3).join ''
    current_english = get_hundred_representation current_num
    postfix = (power_counter == 0) ? '' : BIG[power_counter-1]
    power_counter += 1
    next if current_english.empty?
    current_english += " #{postfix}" unless postfix.empty?
    ret = current_english + ' ' + ret
  end
  
  return ret
end

# takes a string representation of a number up to 999
# returns the english counterpart of the parameter
def get_hundred_representation num
  raise 'Invalid number specified' unless num.size <= 3
  ret = ''

  # hundred position
  if num.size == 3
    hundred = num[0].to_i
    ret = "#{SINGLE[hundred]} hundred" if hundred != 0
  end

  # rightmost two digits are special
  two_digits = num.to_i % 100
  return ret if two_digits == 0
  ret += ' ' unless ret.empty?
  if two_digits < DOUBLE.keys.min
    ret += SINGLE[two_digits]
  else
    single_digit = two_digits % 10
    ret += DOUBLE[two_digits-single_digit]
    ret += " " + SINGLE[single_digit] unless single_digit == 0
  end

  return ret
end

# *** MAIN ***
num = ARGV.first
puts num_to_english num
