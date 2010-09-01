require 'lib/drugsearch' # apparently this runs from the root of the project dir


describe DrugResolver do

  it "should resolve 'mefloquine' to a603030" do
    DrugResolver.resolve_drug_id('mefloquine').should == "a603030"
  end
  
  it "should return nil for real drugs that don't have medline plus drug information" do
    DrugResolver.resolve_drug_id('LYSERGIC ACID DIETHYLAMIDE').should be_nil
  end
  
  it "should return nil for a non-existent drug" do
    DrugResolver.resolve_drug_id('madeup').should be_nil
  end
end

describe SideEffectScraper do
  
  before(:all) do
    @mefloquine_results = SideEffectScraper.get_side_effects('a603030')
    @tylenol_results = SideEffectScraper.get_side_effects('a681004')
    @amphotericin_results = SideEffectScraper.get_side_effects('a682643')
    @metformin_results = SideEffectScraper.get_side_effects('a696005')
  end
  
  it "mefloquine (a603030) should return a hash with a drug name and a set of side effects" do
    @mefloquine_results.should have_key(:drug_name)
    @mefloquine_results.should have_key(:effect_lists)
  end
  
  it "mefloquine (a603030) should return a hash with two sets of side effects" do
    @mefloquine_results[:effect_lists].size.should == 2
  end
  
  it "mefloquine's two groups of side effects should have different warning sentences" do
    
    sent1 = @mefloquine_results[:effect_lists][0][:warning_sentence]
    sent2 = @mefloquine_results[:effect_lists][1][:warning_sentence]
    
    sent1.should_not == sent2
    
  end
  
  it "Amphotericin (a682643) should return a hash with three sets of side effects" do
    @amphotericin_results[:effect_lists].size.should == 3
  end
  
  it "Metformin should return a hash with SIX sets of effects" do
    @metformin_results[:effect_lists].size.should == 6
  end
  
  it "tylenol (a681004) should only have one group of side effects" do
    @tylenol_results[:effect_lists].size.should == 1
  end

  it "Metformin should have an \"extra hazard\" flag" do
    
    @metformin_results[:extra_hazard].should_not be_nil
    
  end
 
# as of 11/2/2009, Tylenol's record DOES have an extra hazard flag. 
#  it "tylenol should NOT have an \"extra hazard\" flag" do
#    @tylenol_results[:extra_hazard].should be_nil
#  end
  
  it "should return nil for non-existent medlineplus ids" do
    SideEffectScraper.get_side_effects('asdf').should be_nil
  end
  
end