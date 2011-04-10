module FractionalArithmetic
  
require 'rational'

class MF < Struct.new(:whole, :fracNum, :fracDen) do
 include Comparable  
  def self.zero
    MF.new(0, 0,1)
  end # self.zero
  def self.commonDen(mf)
    case mf
      when MF then mf.whole + Rational(mf.fracNum, mf.fracDen)
      when Integer then mf + Rational(0,1)
      else puts "Error: addend is #{mf.class} and not mixed fraction or integer"
      end
  end # self.commonDen
  def self.convertStr(string, base=32)
    string.lstrip!
    sign = string[0] == "-" ? -1 : 1
    decimal_pattern = /\d+\.\d+/  # 0.xx or 1.xx
    decimal_pattern =~ string
    decimal_match = Regexp.last_match 
    if decimal_match.nil?
     fraction_pattern = /\d+\s\d+\/\d+|\d+\/\d+|\d+/    # d1 d2/d3 or d1/d2 or d1
     fraction_pattern =~ string
     a = Regexp.last_match
     aa = a ? a[0].split(/\s|\//) : []  # if a is nil then empty array for [0,0,0]
     case aa.size
       when 1
         digits = aa<<["0","1"]
       when 2
         digits = ["0"]<<aa
       when 3
         digits = aa
       else
         digits = ["0","0","1"]
     end
      wh, fn, fd = digits.flatten.map {|d| d.to_i}
      fd = 1 if fd == 0     # no division by zero
      result = MF.new( sign*wh, sign*fn,fd)
    else
      result = convertDec( decimal_match[0].to_f * sign, base)
    end # if decimal_match
    result
  end # self.convertStr
  def self.newNr(value,base=32)
    mfvalue = case value
    when String
      MF.convertStr(value, base)
    when MF
      value
    when Numeric
      MF.convertDec(value, base)
    end
    mfvalue.rebase(base)
  end # self.newNr
  def self.convertDec(decimal, base=32)
    wNum = decimal.to_i
    fR = (decimal - wNum)*base
    fNum = fR.to_i
    fReduced = Rational(fNum, base)
    MF.new(wNum, fReduced.numerator, fReduced.denominator)
  end
  def rebase(base)
    MF.convertDec( to_f, base)
  end # rebase
  def deconstruct(mf)
    wNum = mf.to_f.to_i
    fR = mf - wNum
    fNum = fR.numerator
    fDen = fR.denominator
    [wNum, fNum, fDen]
  end # deconstruct
  def fraction_part
    mf = MF.commonDen(self)
    mf - self.whole
  end # fraction_part
  def <=>(other)
    self_value = MF.commonDen(self)
    other_value = MF.commonDen(other)
    if self_value < other_value then -1
    elsif self_value > other_value then 1
    else 0
    end # if
  end # <=>
  def +(other)
    newF = MF.commonDen(self) + MF.commonDen(other)
    MF.new(*deconstruct(newF))
  end # +
  def -(other)
    newF = MF.commonDen(self) - MF.commonDen(other)
    MF.new(*deconstruct(newF))
  end # -
  def *(other)
    result = case other
    when MF
      newF = MF.commonDen(self) * MF.commonDen(other)
      MF.new(*deconstruct(newF))
    when Numeric
      MF.convertDec(other * self.to_f)
    else 
      MF.zero
    end
    
  end # *
  def /(other)
    begin
      newF = MF.commonDen(self) * 1/other # exception unless other.is_a?(Numeric) && other.abs > 0
    rescue Exception => error    # error is the variable containing the exception object
      puts "#{error.class}: #{error.message}"
      return self
    else
      MF.new(*deconstruct(newF))
    end # begin
  end # /
  def to_f
    MF.commonDen(self).to_f
  end # to_f
  def to_s
    str = case true
    when (whole != 0 and fracNum == 0)
      "#{whole}"
    when (whole == 0 and fracNum != 0)
      "#{fracNum}/#{fracDen}"
    when (whole == 0 and fracNum == 0)
      "0"
    else 
      "#{whole} #{fracNum.abs}/#{fracDen}"
    end
    str
  end # to_s
  def out
    print self.to_s
  end # out
  def output
    puts self.to_s
  end # output

end # do
end # MF
=begin
  another way to create and alias of the class method convertStr is
  class << MF
   alias newNr convertStr
  end
=end

class LWD < Struct.new(:length, :width, :depth) do
  def self.make(length, width, depth)
    LWD.new(MF.convertStr(length), MF.convertStr(width), MF.convertStr(depth))
  end # self.make
  def +(other) 
    newLWD = LWD.new(self.length + other.length, self.width + other.width, self.depth + other.depth)
  end # +
  def -(other)
    newLWD = LWD.new(self.length - other.length, self.width - other.width, self.depth - other.depth)
  end # -
  def *(other)
    newLWD = LWD.new(self.length * other, self.width * other, self.depth * other)
  end # *
  def /(other)
    newLWD = LWD.new(self.length / other, self.width / other, self.depth / other)
  end # /
  def join_at(other, joindir = :length)
    maxLength = [self.length, other.length].max
    maxWidth = [self.width, other.width].max
    maxDepth = [self.depth, other.depth].max
    case joindir
    when :length
       newLWD = LWD.new(self.length + other.length, maxWidth, maxDepth)
    when :width
       newLWD = LWD.new(maxLength, self.width + other.width, maxDepth)
    when :depth
       newLWD = LWD.new(maxLength, maxWidth, self.depth + other.depth)
    else
      puts "no direction given, all directions summed"
      self + other
    end # case
  end # join_at
  def join_many(n, other, joindir = :length)
    (1..n).inject(self) {|newLWD, i| newLWD = newLWD.join_at(other, joindir)}
  end # join_many
  def cut_out(other)
    newLength = self.length
    newWidth = self.width
    newDepth = self.depth
    length_throughcut = self.length <= other.length  # cut in length direction 
    width_throughcut = self.width <= other.width  # cut in width direction
    depth_throughcut = self.depth <= other.depth  # cut in depth direction
    newLength = self.length - other.length if width_throughcut && depth_throughcut
    newWidth = self.width - other.width if length_throughcut && depth_throughcut
    newDepth = self.depth - other.depth if length_throughcut && width_throughcut

    newLWD = LWD.new(newLength, newWidth, newDepth)
  end # cut_out
  def face_view
    rsorted = [self.length, self.width, self.depth].sort.reverse
    LWD.new(*rsorted)
  end # face_view
  def out
#    self.length.out; print ", "; self.width.out; print ", "; self.depth.out
    print self.to_s
  end # out
  def output
    out; print "\n"
  end # output
  def to_s
    self.length.to_s + " x " + self.width.to_s + " x " + self.depth.to_s
  end # to_s
  
 alias cutout cut_out
end # do
end # LWD

def lwd_tally(*lwdlist)
  tally = {}
  face_list = lwdlist.map {|lwd| lwd.face_view}
  face_list.each do |lwd_item|
    if tally.key?(lwd_item)
      tally[lwd_item] += 1
    else
      tally[lwd_item] = 1
    end # if
  end # do
  tally
end # lwd_tally

module_function :lwd_tally
end # FractionalArithmetic
