require 'rubygems'
require 'uri'
require 'open-uri'
require 'net/http'
require 'cgi'
require 'nokogiri'

class SideEffectScraper

  @@BASE_URL="http://www.nlm.nih.gov/medlineplus/druginfo/meds/"
  
  def self.get_side_effects(mp_number)
    url = @@BASE_URL + mp_number + ".html"

    begin
      doc = Nokogiri::HTML(open(url))
    rescue OpenURI::HTTPError
      return nil
    rescue
      puts url
      raise
    end

    # try and grab the drug name:
    drug_name = (doc / "html body h3")[0].text


    start_node = doc.xpath('//a[(@name="side-effects") or (@name="side-effect")]').first

    this_node = start_node.next_sibling

    ary = []

    count = 0

    # ary should end up as an array of all the <ul> elements in the side effects section together with 
    # the explanatory text immediately preceding it
    while this_node.name != "a" and count < 100 # don't want it looping forever...
      if this_node.name == "ul"
        ary << [this_node.previous_sibling, this_node]
      end
      this_node = this_node.next_sibling
      count += 1
    end

    side_effects = {}
    side_effects[:drug_name] = drug_name
    effect_arr = []
    
    # extract side effects into a group of warning-sentence/side effect list pairs
    ary.each do |a|

      warning_sentence = a[0].text.strip.split(/\.\s/).last
      effects = (a[1] / "li").collect { |e| e.text.strip }
      effect_arr << {:warning_sentence => warning_sentence, :effects => effects}
    end
    
    side_effects[:effect_lists] = effect_arr
    
    # try and grab any extra hazard that may be present
    extra_hazard = nil
    extra_hazard_el = doc / "html body table[@bordercolor='#FF0000']"
    if extra_hazard_el.size > 0
      extra_hazard = extra_hazard_el.text.strip
    end
    
    side_effects[:extra_hazard] = extra_hazard

    return side_effects
  end

end

class DrugResolver
  @@BASE_URL = 'http://vsearch.nlm.nih.gov/vivisimo/cgi-bin/query-meta'

  def self.resolve_drug_id(drug_name)
    params = {
      'input-form'=>	'simple',
      'query'=>	drug_name,
      'v:project'=>	'medlineplus',
      'v:sources'=>	'medlineplus-bundle'
    }

    url = URI.parse(@@BASE_URL)
    res = Net::HTTP.post_form(url, params)

    doc = Nokogiri::HTML(res.body)

    result = (doc / 'li.source-drugs .document-header a')


    if result.size < 1
      #raise "first result not found..."
      return nil
    end

    # take first result, hope it's our drug
    raw_href = result[0]['href']
    # /vivisimo/cgi-bin/query-meta?v%3afile=viv_sCGqQU&server=search4.nlm.nih.gov&v%3astate=root%7croot&url=http%3a%2f%2fwww.nlm.nih.gov%2fmedlineplus%2fdruginfo%2fmeds%2fa682878.html&rid=Ndoc0&v%3aframe=redirect&

    parts = raw_href.split(/&/)

    # /vivisimo/cgi-bin/query-meta?v%3afile=viv_sCGqQU&
    #server=search4.nlm.nih.gov&
    #v%3astate=root%7croot&
    #url=http%3a%2f%2fwww.nlm.nih.gov%2fmedlineplus%2fdruginfo%2fmeds%2fa682878.html&
    #rid=Ndoc0&
    #v%3aframe=redirect&

    parts = parts.select { |z| z =~ /^url/ }
    if parts.size > 1
      raise "too many urls- something's wrong!"
    end



    url_to_scrape = parts[0].split(/=/)[1]
    clean_url = CGI.unescape(url_to_scrape)
    
    # check to make sure this result is a drug:
    if not clean_url =~ /^http:\/\/www\.nlm\.nih\.gov\/medlineplus\/druginfo\/meds/
      #raise "first result not a drug- try again"
      return nil
    end
    
    medline_plus_article_id = clean_url.split('/').last.split('.')[0]
    return medline_plus_article_id
  end
end

