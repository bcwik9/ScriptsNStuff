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

BIG = {
  10 ** 2 => 'hundred',
  10 ** 3 => 'thousand',
  10 ** 6 => 'million',
  10 ** 9 => 'billion',
  10 ** 12 => 'trillion',
  10 ** 15 => 'quadrillion',
  10 ** 18 => 'quintillion',
  10 ** 21 => 'sextillion',
  10 ** 24 => 'septillion',
  10 ** 27 => 'octillion',
  10 ** 30 => 'nonillion',
  10 ** 33 => 'decillion'
}

# given an integer, returns the english representation
def num_to_english i
  # some simple sanity checks
  ret = ''
  return 'zero' if i == 0

  # start ripping the number apart
  two_digits = i % 100
  if two_digits < DOUBLE.keys.min
    ret = SINGLE[two_digits]
  else
    single_digit = two_digits % 10
    ret = DOUBLE[two_digits-single_digit]
    ret += " " + SINGLE[single_digit] if SINGLE.has_key? single_digit
  end

  return ret
end

# *** MAIN ***
num = ARGV.first
return '' if num.nil?
puts num_to_english num.to_i
