# require 'rubygems'
require 'spec'
require File.dirname(__FILE__) + '/fractionalArithmetic'
include FractionalArithmetic

describe MF do
 before(:each) do
   @zero = MF.zero
   @bp = MF.new(26, 3,4)
   @neg_bp = MF.new(-26,-3,4)
   @bo = MF.new(20, 1,2)

#   (bp + bo).output
#    (bp - bo).output
#    (bo - bp).output

#   (bp + 44).output
 end

 it "can convert a mixed fraction string to MF" do
   MF.convertStr("34").should eql(MF.new(34, 0,1))
   MF.convertStr("-34").should eql(MF.new(-34, 0,1))
   MF.convertStr("3/4").should eql(MF.new(0, 3,4))
   MF.convertStr("-3/4").should eql(MF.new(0, -3,4))
   MF.convertStr("34 3/4").should eql(MF.new(34, 3,4))
   MF.convertStr("-34 3/4").should eql(MF.new(-34, -3,4))
   MF.convertStr(" ").should eql(MF.new(0, 0,1))
 end
 it "can convert a string using the class alias newNr" do
   MF.newNr("34 3/4").should eql(MF.new(34, 3,4))
 end
 it "can convert a mixed fraction instance to a float value" do
   mf = MF.convertStr("34 3/4")
   mf.to_f.should eql(34.75)
   mf = MF.convertStr("-34 3/4")
   mf.to_f.should eql(-34.75)
 end
 it "can discriminate close numbers" do
   mf1 = MF.newNr("1/32")
   mf2 = MF.newNr("3/64", 64)
   p (mcd1 = MF.commonDen(mf1))
   p (mcd2 = MF.commonDen(mf2))
   p mcd1 - mcd2
   p (mf1 - mf2).to_s
   mg1 = MF.newNr("4/128",128)
   mg2 = MF.newNr("1/328")
   p (mcd1 = MF.commonDen(mg1))
   p (mcd2 = MF.commonDen(mg2))
   p (mg2-mg1).to_s
 end # can discriminate close numbers
 it "can convert small numbers to decimals and back" do
   mf = MF.newNr("1/1048", 2096)
   mf1 = MF.newNr("1/1047", 1048)
   (mf1.fraction_part == Rational(1,1048)).should be_true
   (mfdec = mf.to_f).should be_close(0.0009, 0.5)
  MF.convertDec(mfdec, 1048).should eql(MF.new(0, 1,1048))
 end # can convert small numbers to decimals and back
 it "can convert a decimal number to MF" do
   MF.convertDec(3.15, 64).should eql(MF.new(3, 9,64))
   MF.convertDec(-3.15, 64).should eql(MF.new(-3, -9,64))
 end
 it "can take a large base for accurate measurements" do
   MF.convertDec(Math.sqrt(2), 1000000).should eql(MF.new(1, 414213, 1000000))
 end
 it "can rebase a fraction with denominator not greater than base" do
   MF.new(1, 3, 64).rebase(32).should eql(MF.new(1, 1, 32))
   MF.new(-1, -3, 64).rebase(32).should eql(MF.new(-1, -1, 32))
 end
 it "can round up" do
   mf1 = MF.newNr("1/32",32)
   nmf1 = MF.newNr("-1/32",32)
   mf2 = MF.newNr("1/64",32)
   mf3 = MF.newNr("1/128",128)
   mf4 = MF.newNr("3/64",32)
   (mf1+mf2).to_s.should eql("1/32")
   (mf1+mf3).to_s.should eql("5/128")
   (mf1+mf2+mf3+mf3+mf3+mf3).to_s.should eql("1/16")
   (mf1-mf2).to_s.should eql("1/32")
   (mf1-mf3).to_s.should eql("3/128")
   (nmf1-mf3).to_s.should eql("-5/128")
   (mf4+mf4).to_s.should eql("1/16")
 end # can round up
 it "convert a mixed fraction to string" do
   @bp.to_s.should eql("26 3/4")
   @neg_bp.to_s.should eql("-26 3/4")
   MF.new(-10,0,1).to_s.should eql("-10")
 end
 it "converts a string decimal to a fraction" do
   frac = MF.newNr("1/128",128)
   puts frac.to_s
   fracdec = MF.newNr(" -2.33", 1024)
   puts fracdec.to_s
 end # converts a string decimal to a fraction
 it "can printout a mixed fraction (MF) quantity" do
  @zero.output
 end
 it "can compare two mixed fractions" do
   (@bo < @bp).should be_true
   (@neg_bp < @bp).should be_true
 end
 it "can add two mixed fractions" do
   (@bp + @bo).whole.should == 47
   (@neg_bp + @bo).whole.should == -6
 end
 it "can subtract two mixed fractions" do
   ans = (@bp - @bo)
   ans.whole.should == 6
   ans.fraction_part.should == Rational(1,4)
   
   ans = (@neg_bp - @bo)
   ans.whole.should == -47
   ans.fraction_part.should == Rational(-1,4)
 end
 it "can multiple a mixed fraction by a scalar" do
   (@bp*(2)).to_s.should eql("53 1/2")
   (@neg_bp*(2)).to_s.should eql("-53 1/2")
 end
 it "can divide a mixed fraction by a scalar" do
   (@bp/(2)).to_s.should eql("13 3/8")
   (@neg_bp/(2)).to_s.should eql("-13 3/8")
 end
 it "can sort two mixed fractions" do
   startMF = [MF.convertStr("21 3/5"), MF.convertStr("3 1/4"), MF.convertStr("11 7/8")]
   endMF = [MF.convertStr("3 1/4"), MF.convertStr("11 7/8"), MF.convertStr("21 3/5")]
   rendMF = [MF.convertStr("21 3/5"), MF.convertStr("11 7/8"), MF.convertStr("3 1/4")]
   rstartMF = [MF.convertStr("11 7/8"), MF.convertStr("3 1/4"), MF.convertStr("21 3/5")]
   
   startMF.sort.should eql(endMF)
   rsort = startMF.sort {|a,b| b<=>a}
   rsort.should eql(rendMF)
   startMF.reverse.should eql(rstartMF)
   startMF.sort.reverse.should eql(rendMF)
   endMF.sort.reverse.should eql(rendMF)
   
   negstartMF = [MF.convertStr("3 1/4"), MF.convertStr("-21 3/5"), MF.convertStr("11 7/8")]
   negendMF = [MF.convertStr("-21 3/5"), MF.convertStr("3 1/4"), MF.convertStr("11 7/8")]
   negstartMF.sort.should eql(negendMF)
   
 end
end

describe LWD do
  before(:each) do
    @zero = MF.zero
    @bp = MF.new(26, 3,4)
    @bo = MF.new(20, 1,2)
    @plate = LWD.new(@bp, @bo, @zero)
    @thickness = MF.new(0, 3,4)
    @plateEdge = LWD.new(@bp,@thickness,@bo)
  end
  it "can build a plate with class LWD" do
    @plate.length.class.should be(MF)
    @plate.length.should respond_to(:output)
    @plate.depth.should be(@zero)
  end
  it "can make a plate with string dimensions" do
    LWD.make("3/8", "3/4", "10 1/2").should eql(LWD.new(MF.new(0, 3,8), MF.new(0, 3,4), MF.new(10, 1,2)))
  end
  it "can convert dimensions of a plate to a string" do
    puts "#{@plate.to_s}"
  end
  it "can printout dimensions of a plate" do
    @plate.output
  end
  it "can add a dimension to the length" do
    @plate.length = @plate.length + 4
    @plate.length.whole.should == 30
    @plate.length.fraction_part.should == Rational(3,4)
  end
  it "can add two plates together" do
    addingDim = LWD.new(@zero, MF.new(0, 1,2), @zero)
    @plate = @plate + addingDim
    @plate.width.whole.should == 21
    @plate.width.fraction_part.should == Rational(0,1)
  end
  it "can join two plates in width direction" do
   # addingDim = LWD.new( MF.new(0, 1,2), MF.new(0, 1,2),  MF.new(0, 1,2))
    addingDim = LWD.make("1/2", "1/2", "1/2")
    @plate = @plate.join_at(addingDim, :width)
    @plate.length.should eql(@bp)
    @plate.width.should eql(@bo + addingDim.width)
    @plate.depth.should eql(addingDim.depth)
  end
  it "can join a plate multiple times in width direction" do
    addingDim = LWD.new( MF.new(0, 1,2), MF.new(0, 1,2),  MF.new(0, 1,2))
    @plate = @plate.join_many(3,addingDim, :width)
    @plate.length.should eql(@bp)
    @plate.width.should eql(@bo + addingDim.width*3)
    @plate.depth.should eql(addingDim.depth)
  end
  it "can subtract one plate from another plate" do
    subtractingDim = LWD.new(@zero, MF.new(20, 3,4), @zero)
    @plate = @plate - subtractingDim
    @plate.width.whole.should == 0
    @plate.width.fraction_part.should eql( Rational(-1,4))
  end
  it "can cut one plate from another when throughcuts on a face" do
    removeDim = LWD.new( MF.new(0, 1,2), @thickness,  @bo) #throughcut on wd face
    plateEdge = @plateEdge.cut_out(removeDim)
    plateEdge.length.should eql(@bp - removeDim.length)
    plateEdge.width.should eql(@thickness)
    plateEdge.depth.should eql(@bo) 
    removeDim = LWD.new( MF.new(0, 1,2), @thickness-MF.new(0, 1,8),  @bo) #no throughcut on wd face
    plateEdge = @plateEdge.cut_out(removeDim)
    plateEdge.length.should eql(@bp)
    removeDim = LWD.new(MF.new(0, 1,2), @thickness,  @bo-MF.new(0, 1,8)) #no throughcut on wd face
    plateEdge = @plateEdge.cut_out(removeDim)
    plateEdge.length.should eql(@bp)
    removeDim = LWD.new(@bp, MF.new(0, 1,2),  @bo) # throughcut on ld face
    plateEdge = @plateEdge.cut_out(removeDim) 
    plateEdge.width.should eql(@thickness - MF.new(0, 1,2))
    removeDim = LWD.new(@bp, MF.new(0, 1,2),  @bo-MF.new(0, 1,8)) #no throughcut on ld face
    plateEdge = @plateEdge.cut_out(removeDim)
    plateEdge.width.should eql(@thickness)
  end
  it "can cut one plate from another in the specific direction multiple times" do
    cutDim = LWD.new( MF.new(0, 1,2), @thickness,  @bo)
    plateEdge = @plateEdge.cut_out(cutDim *2) #:width
    puts "@plateEdge is #{@plateEdge.to_s}"
    puts "cutDim * 2 is #{(cutDim*2).to_s}"
    puts "plateEdge is #{plateEdge.to_s}"
    plateEdge.length.should eql(@bp - cutDim.length - cutDim.length)
    plateEdge.width.should eql(@thickness)
    plateEdge.depth.should eql(@bo)
  end
  it "can cut a rabbel as a non-throughcut" do
    cutDim = LWD.new(@thickness, MF.new(0, 1,2), @bo)
    plateEdge = @plateEdge.cut_out(cutDim) #:width
    plateEdge.length.should eql(@bp)
    plateEdge.width.should eql(@thickness)
    plateEdge.depth.should eql(@bo)   
  end
  it "can multiply a rational times all dimensions" do
    newPlate = @plate * 2/4
    newPlate.should == LWD.new(@bp*1/2, @bo*1/2, @zero*1/2)
    newPlateZero = @plate * @zero
    newPlateZero.should == LWD.new(@zero, @zero, @zero)
  end
  it "can divide dimensions by a rational" do
    newPlate = @plate / 2
    newPlate.should == LWD.new(@bp/2, @bo/2, @zero/2)
    newPlateZero = @plate / 0
    newPlateZero.should == newPlateZero
  end
  it "can show a flat face view" do
    face = @plateEdge = LWD.new(@bp,@thickness,@bo).face_view
    face.output
    face.should eql(LWD.new(@bp,@bo,@thickness))
  end
  it "can tally a list of lwd with face-views" do
    result = lwd_tally(@plateEdge,@plateEdge,@plateEdge,@plate)
    face_plateEdge = LWD.new(@bp, @bo, @thickness)
    face_plate = LWD.new(@bp, @bo, @zero)
    result[face_plate].should eql(1)
    result[face_plateEdge].should eql(3)
  end
end
