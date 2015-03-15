class BlobFinder
  # vars
  attr_accessor :blob, :read_cells, :top, :bottom, :left, :right

  def initialize blob
    # check that blob param is a valid 2d array
    raise "invalid blob array!" if blob.nil? or blob.empty? or blob.first.empty?
    
    # we assume that the blob being passed in is valid
    @blob = blob
    @read_cells = []
  end
  
  def find_boundaries
    # store the dimensions
    x_size = @blob.first.size
    y_size = @blob.size

    # find top
    # start from 0,0 and go left to right, top to bottom
    y_size.times.each do |y|
      break unless @top.nil?
      x_size.times.each do |x|
        if read_array(x,y) == 1
          @top = @bottom = y
          @right = @left = x
          break
        end
      end
    end

    # find  bottom
    # start from max,max and go right to left, bottom to top
    bottom_found = false
    y_size.times.each do |y|
      real_y = y_size-1-y
      break if bottom_found or real_y == @bottom
      
      x_size.times.each do |x|
        real_x = x_size-1-x
        if read_array(real_x, real_y) == 1
          bottom_found = true
          @bottom = real_y
          @left = real_x if real_x < @left
          @right = real_x if real_x > @right
          break
        end
      end
    end
    
    # find left
    # start from 0,0 and go top to bottom, left to right
    left_found = false
    x_size.times.each do |x|
      break if left_found or x == @left

      y_size.times.each do |y|
        # skip over cells we've already read
        next if y <= @top
        break if y > @bottom
        if read_array(x, y) === 1
          left_found = true
          @left = x
          @right = x if x > @right
          break
        end
      end
    end

    # find right
    # start from max,max and go bottom to top, right to left
    right_found = false
    x_size.times.each do |x|
      real_x = x_size-1-x
      break if right_found or real_x == @right

      y_size.times.each do |y|
        real_y = y_size-1-y
        # skip over cells we've already read
        next if real_y > @bottom
        next if real_y == @bottom and bottom_found
        break if real_y < @top

        if read_array(real_x, real_y) === 1
          right_found = true
          @right = real_x
          break
        end
      end
    end
    
  end

  # reads a cell from the blob array
  # keep track of cells we've read just to determine how many reads
  # we did total
  def read_array x, y
    cell = [x,y]
    @read_cells.push cell
    # x and y are switched here because of how the blob array is structured
    return @blob[y][x]
  end
end




# *** MAIN ENTRY ***
blob = [
[0,0,0,0,0,0,0,0,0,0],
[0,0,1,1,1,0,0,0,0,0],
[0,0,1,1,1,1,1,0,0,0],
[0,0,1,0,0,0,1,0,0,0],
[0,0,1,1,1,1,1,0,0,0],
[0,0,0,0,1,0,1,0,0,0],
[0,0,0,0,1,0,1,0,0,0],
[0,0,0,0,1,1,1,0,0,0],
[0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0]
]

# locate boundaries
bf = BlobFinder.new blob
bf.find_boundaries

# print out info
puts "Blob we're looking at:"
blob.each do |b|
  puts b.to_s
end
puts "Cells Read: #{bf.read_cells.size}"
puts "Top: #{bf.top}"
puts "Bottom: #{bf.bottom}"
puts "Left: #{bf.left}"
puts "Right: #{bf.right}"


