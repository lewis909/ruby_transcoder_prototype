require 'fileutils'
require 'Nokogiri'



Dir['F:/Transcoder/staging/prep/*.xml'].each do |f|

  rename = File.basename("#{f}", '.xml')

  doc = Nokogiri::XML(File.read("#{f}"))

  puts doc

  repo_get = doc.xpath('//source_filename/text()')

  puts repo_get

  prep = "F:/Transcoder/staging/prep/#{rename}.mp4"
  staging = 'F:/Transcoder/staging/'

  FileUtils.copy "F:/Transcoder/repo/#{repo_get}.mp4", prep
  FileUtils.mv Dir.glob("F:/Transcoder/staging/prep/#{rename}.xml"), staging
  FileUtils.mv Dir.glob("F:/Transcoder/staging/prep/#{rename}.mp4"), staging



end

