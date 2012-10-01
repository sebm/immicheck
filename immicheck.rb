=begin
immicheck.rb
Copyright (C) 2012 Sebastian Motraghi

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
=end
require 'mechanize'
class ImmiCheck
  def self.check(case_number)
    agent = Mechanize.new

    options = { "appReceiptNum" => case_number }
    page = agent.post("https://egov.uscis.gov/cris/Dashboard/CaseStatus.do", options)

    case_div = page.search("div.caseStatusInfo")

    status_els = case_div.search('h4')
    specific_info_els = case_div.search('.caseStatus')
    general_info_els = case_div.search('#bucketDesc')

    begin
      status_txt = status_els.first.text.strip
      specific_info_txt = specific_info_els.first.text.strip
      general_info_txt  = general_info_els.first.text.strip
    rescue NoMethodError => e
      abort "Could not scrape case status information from USCIS site."
    end

    return {
      :status => status_txt,
      :specific_info => specific_info_txt,
      :general_info => general_info_txt
    }
  end
end

if $0 == __FILE__
  unless ARGV[0]
    abort "Please provide your application number as a parameter."
  end

  puts ImmiCheck.check(ARGV[0])
end
