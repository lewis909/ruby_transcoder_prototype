require 'fileutils'
require 'Nokogiri'
load 'config.rb'

class Job_prep

  def check_file

    time = Time.now.getutc

    watchfolder_1 = TranscodeNode.tn1 # F:/Transcoder/staging/node_1
    watchfolder_2 = TranscodeNode.tn2 # F:/Transcoder/staging/node_2
    watchfolder_3 = TranscodeNode.tn3 # F:/Transcoder/staging/node_3
    watchfolder_4 = TranscodeNode.tn4 # F:/Transcoder/staging/node_4

    if !Dir.glob('F:/Transcoder/staging/prep/*.xml').empty?

      Dir['F:/Transcoder/staging/prep/*.xml'].each do |f|

        rename = File.basename("#{f}", '.xml')

        doc = Nokogiri::XML(File.read("#{f}"))

        puts ''
        p "#{time}: Checking #{rename}.xml"
        puts''
        puts doc
        puts ''
        puts '-------------------------------------------------------------------'
        puts''


        repo_get = doc.xpath('//source_filename/text()')

        #puts repo_get

        prep = "F:/Transcoder/staging/prep/#{rename}.mp4"

        node_1 = Dir["#{watchfolder_1}"+'*']
        node_2 = Dir["#{watchfolder_2}"+'*']
        node_3 = Dir["#{watchfolder_3}"+'*']
        node_4 = Dir["#{watchfolder_4}"+'*']

        nc_1 =  node_1.count
        nc_2 =  node_2.count
        nc_3 =  node_3.count
        nc_4 =  node_4.count

        #loadmax =[nc_1,nc_2,nc_3,nc_4].max
        loadmin =[nc_1,nc_2,nc_3,nc_4].min

        if loadmin == nc_1

          FileUtils.copy "F:/Transcoder/repo/#{repo_get}.mp4", prep
          FileUtils.mv Dir.glob("F:/Transcoder/staging/prep/#{rename}.xml"), watchfolder_1
          FileUtils.mv Dir.glob("F:/Transcoder/staging/prep/#{rename}.mp4"), watchfolder_1

          puts "#{time}:#{rename}.xml moved to Node 1"

        elsif loadmin == nc_2

          FileUtils.copy "F:/Transcoder/repo/#{repo_get}.mp4", prep
          FileUtils.mv Dir.glob("F:/Transcoder/staging/prep/#{rename}.xml"), watchfolder_2
          FileUtils.mv Dir.glob("F:/Transcoder/staging/prep/#{rename}.mp4"), watchfolder_2

          puts "#{time}:#{rename}.xml moved to Node 2"

        elsif loadmin == nc_3

          FileUtils.copy "F:/Transcoder/repo/#{repo_get}.mp4", prep
          FileUtils.mv Dir.glob("F:/Transcoder/staging/prep/#{rename}.xml"), watchfolder_3
          FileUtils.mv Dir.glob("F:/Transcoder/staging/prep/#{rename}.mp4"), watchfolder_3

          puts "#{time}:#{rename}.xml moved to Node 3"

        elsif loadmin == nc_4

          FileUtils.copy "F:/Transcoder/repo/#{repo_get}.mp4", prep
          FileUtils.mv Dir.glob("F:/Transcoder/staging/prep/#{rename}.xml"), watchfolder_4
          FileUtils.mv Dir.glob("F:/Transcoder/staging/prep/#{rename}.mp4"), watchfolder_4

          puts "#{time}:#{rename}.xml moved to Node 4"

        end

        puts 'Files successfully moved to staging area.'

      end

    else
      puts 'No valid files found'
    end

  end

end


