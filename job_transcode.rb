require 'securerandom'
require 'fileutils'
require 'thread'
require 'Nokogiri'
require 'mysql2'
#load 'config.rb'

class Job_transcode

  def initialize(node_path, node_number)

    @node_path = node_path
    @node_number = node_number

    def start

      watchfolder = @node_path

      time = Time.now.getutc

      if !Dir.glob("#{watchfolder}"+'*.mp4').empty?

        Dir["#{watchfolder}"+'*.mp4'].each do |f|

          next if File.exist?(f,) && File.exist?("#{watchfolder}"+'*.xml')

          file_name = File.basename("#{f}", '.mp4')
          xml = file_name+'.xml'

          time = Time.now.getutc
          #timestamp = time.to_s[0,19].gsub(/ /,'-').gsub(/:/,'')
          new_folder = SecureRandom.uuid

          dbc = Mysql2::Client.new(:host => 'localhost',:username => 'lewis_transcode', :password => 'tool4602', :database => 'media_hub')

          if File.exists?("#{watchfolder}#{file_name}.mp4") && File.exist?("#{watchfolder}#{xml}")
            puts ''
            puts "#{time} #{@node_number}: - Files ready starting the transcode process."
            puts ''

            FileUtils::mkdir_p("F:/Transcoder/processing_temp/#{file_name}_#{new_folder}/conform/temp")
            temp_folder = "F:/Transcoder/processing_temp/#{file_name}_#{new_folder}"
            conform_folder = "F:/Transcoder/processing_temp/#{file_name}_#{new_folder}/conform"
            temp = "F:/Transcoder/processing_temp/#{file_name}_#{new_folder}/conform/temp"

            FileUtils.mv Dir.glob("#{f}"), temp_folder
            FileUtils.mv Dir.glob("#{watchfolder}#{xml}"), temp_folder

            doc = Nokogiri::XML(File.read("F:/Transcoder/processing_temp/#{file_name}_#{new_folder}/#{xml}"))

            task_id = doc.xpath('//manifest/@task_id').to_s

            puts ''
            puts "#{time} #{@node_number}:  Processing Task #{task_id}"
            puts ''
            puts "#{time} #{@node_number}: Parsing xml"
            puts ''
            #puts doc
            #puts ''

            conform_get = doc.xpath('//conform_profile/text()')

            puts conform_get

            transcode_get= doc.xpath('//transcode_profile/text()')
            target_path= doc.xpath('//target_path/text()')

            seg_number = doc.xpath('//number_of_segments/text()').to_s

            seg_1_start = doc.xpath('//segment_1/@seg_1_start').to_s
            seg_1_dur = doc.xpath('//segment_1/@seg_1_dur').to_s

            seg_2_start = doc.xpath('//segment_2/@seg_2_start').to_s
            seg_2_dur = doc.xpath('//segment_2/@seg_2_dur').to_s

            seg_3_start = doc.xpath('//segment_3/@seg_3_start').to_s
            seg_3_dur = doc.xpath('//segment_3/@seg_3_dur').to_s

            seg_4_start = doc.xpath('//segment_4/@seg_4_start').to_s
            seg_4_dur = doc.xpath('//segment_4/@seg_4_dur').to_s

            if seg_number == '1'

              seg_conform = "-ss #{seg_1_start} -t #{seg_1_dur} #{conform_folder}/s1_#{file_name}.mp4"

              conform = conform_get.to_s.gsub(/S_PATH/,"#{temp_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/SEG_CONFORM/,"#{seg_conform}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"c_#{task_id}")

              conform_s1_dur_get = seg_1_dur.split(':')

              s1_1 = conform_s1_dur_get[0].to_i * 3600
              s1_2 = conform_s1_dur_get[1].to_i * 60
              s1_3 = conform_s1_dur_get[2].to_i
              s1_4 = conform_s1_dur_get[3].to_i

              s1_dur_in_sec = s1_1 + s1_2 + s1_3 + s1_4

              con_dur = s1_dur_in_sec

            elsif seg_number == '2'

              seg_conform = "-ss #{seg_1_start} -t #{seg_1_dur} #{conform_folder}/s1_#{file_name}.mp4 -ss #{seg_2_start} -t #{seg_2_dur} #{conform_folder}/s2_#{file_name}.mp4"

              conform = conform_get.to_s.gsub(/S_PATH/,"#{temp_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/SEG_CONFORM/,"#{seg_conform}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"c_#{task_id}")

              conform_s1_dur_get = seg_1_dur.split(':')

              s1_1 = conform_s1_dur_get[0].to_i * 3600
              s1_2 = conform_s1_dur_get[1].to_i * 60
              s1_3 = conform_s1_dur_get[2].to_i
              s1_4 = conform_s1_dur_get[3].to_i

              s1_dur_in_sec = s1_1 + s1_2 + s1_3 + s1_4

              conform_s2_dur_get = seg_2_dur.split(':')

              s2_1 = conform_s2_dur_get[0].to_i * 3600
              s2_2 = conform_s2_dur_get[1].to_i * 60
              s2_3 = conform_s2_dur_get[2].to_i
              s2_4 = conform_s2_dur_get[3].to_i

              s2_dur_in_sec = s2_1 + s2_2 + s2_3 + s2_4

              con_dur = s1_dur_in_sec + s2_dur_in_sec


            elsif seg_number == '3'

              seg_conform = "-ss #{seg_1_start} -t #{seg_1_dur} #{conform_folder}/s1_#{file_name}.mp4 -ss #{seg_2_start} -t #{seg_2_dur} #{conform_folder}/s2_#{file_name}.mp4 -ss #{seg_3_start} -t #{seg_3_dur} #{conform_folder}/s3_#{file_name}.mp4"

              conform = conform_get.to_s.gsub(/S_PATH/,"#{temp_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/SEG_CONFORM/,"#{seg_conform}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"c_#{task_id}")

              conform_s1_dur_get = seg_1_dur.split(':')

              s1_1 = conform_s1_dur_get[0].to_i * 3600
              s1_2 = conform_s1_dur_get[1].to_i * 60
              s1_3 = conform_s1_dur_get[2].to_i
              s1_4 = conform_s1_dur_get[3].to_i

              s1_dur_in_sec = s1_1 + s1_2 + s1_3 + s1_4

              conform_s2_dur_get = seg_2_dur.split(':')

              s2_1 = conform_s2_dur_get[0].to_i * 3600
              s2_2 = conform_s2_dur_get[1].to_i * 60
              s2_3 = conform_s2_dur_get[2].to_i
              s2_4 = conform_s2_dur_get[3].to_i

              s2_dur_in_sec = s2_1 + s2_2 + s2_3 + s2_4

              conform_s3_dur_get = seg_3_dur.split(':')

              s3_1 = conform_s3_dur_get[0].to_i * 3600
              s3_2 = conform_s3_dur_get[1].to_i * 60
              s3_3 = conform_s3_dur_get[2].to_i
              s3_4 = conform_s3_dur_get[3].to_i

              s3_dur_in_sec = s3_1 + s3_2 + s3_3 + s3_4

              con_dur = s1_dur_in_sec + s2_dur_in_sec + s3_dur_in_sec

            elsif seg_number =='4'

              seg_conform = "-ss #{seg_1_start} -t #{seg_1_dur} #{conform_folder}/s1_#{file_name}.mp4 -ss #{seg_2_start} -t #{seg_2_dur} #{conform_folder}/s2_#{file_name}.mp4 -ss #{seg_3_start} -t #{seg_3_dur} #{conform_folder}/s3_#{file_name}.mp4 -ss #{seg_4_start} -t #{seg_4_dur} #{conform_folder}/s4_#{file_name}.mp4"

              conform = conform_get.to_s.gsub(/S_PATH/,"#{temp_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/SEG_CONFORM/,"#{seg_conform}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"c_#{task_id}")

              conform_s1_dur_get = seg_1_dur.split(':')

              s1_1 = conform_s1_dur_get[0].to_i * 3600
              s1_2 = conform_s1_dur_get[1].to_i * 60
              s1_3 = conform_s1_dur_get[2].to_i
              s1_4 = conform_s1_dur_get[3].to_i

              s1_dur_in_sec = s1_1 + s1_2 + s1_3 + s1_4

              conform_s2_dur_get = seg_2_dur.split(':')

              s2_1 = conform_s2_dur_get[0].to_i * 3600
              s2_2 = conform_s2_dur_get[1].to_i * 60
              s2_3 = conform_s2_dur_get[2].to_i
              s2_4 = conform_s2_dur_get[3].to_i

              s2_dur_in_sec = s2_1 + s2_2 + s2_3 + s2_4

              conform_s3_dur_get = seg_3_dur.split(':')

              s3_1 = conform_s3_dur_get[0].to_i * 3600
              s3_2 = conform_s3_dur_get[1].to_i * 60
              s3_3 = conform_s3_dur_get[2].to_i
              s3_4 = conform_s3_dur_get[3].to_i

              s3_dur_in_sec = s3_1 + s3_2 + s3_3 + s3_4

              conform_s4_dur_get = seg_4_dur.split(':')

              s4_1 = conform_s4_dur_get[0].to_i * 3600
              s4_2 = conform_s4_dur_get[1].to_i * 60
              s4_3 = conform_s4_dur_get[2].to_i
              s4_4 = conform_s4_dur_get[3].to_i

              s4_dur_in_sec = s4_1 + s4_2 + s4_3 + s4_4

              con_dur = s1_dur_in_sec + s2_dur_in_sec + s3_dur_in_sec + s4_dur_in_sec


            end

            puts conform

            conform_query = dbc.query("UPDATE task SET status ='Conforming' WHERE task_id ='#{task_id}'")
            conform_query

            puts ''
            puts "#{time} #{@node_number}: Task ID(#{task_id}) Conform started"
            puts ''

            system("#{conform}")

            seg_list = Dir[conform_folder + '/*.mp4']

            File.open("#{conform_folder}/#{file_name}_conform_list.txt", "w+") do |f|

              seg_list.each { |element| f.puts('file ' + "'" + element +"'") }

            end

            File.open("F:/Transcoder/logs/transcode_logs/#{task_id}_dur.txt", "w+") do |cd|

              cd.puts con_dur

            end

            Dir["#{conform_folder}"+'/*.mp4'].each do |x|

              seg_name = File.basename("#{x}", '.mp4')

              get_seg_dur = "ffprobe -show_entries format=duration #{conform_folder}/#{seg_name}.mp4 > #{temp}/#{seg_name}.txt"

              p "#{get_seg_dur}"

              system("#{get_seg_dur}")

            end

            puts ''
            puts "#{time} #{@node_number}: Task ID(#{task_id}) Conform complete"
            puts ''

            conform_list = "#{file_name}_conform_list.txt"

            transcode = transcode_get.to_s.gsub(/T_PATH/,"#{conform_folder}").gsub(/CONFORM_LIST/,"#{conform_list}").gsub(/F_NAME/,"#{file_name}").gsub(/TRC_PATH/,"#{target_path}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"t_#{task_id}").gsub('/','\\')

            puts transcode_get
            puts transcode

            puts ''
            puts "#{time} #{@node_number}: Task ID(#{task_id}) Transcode started"
            puts ''

            transcode_start = dbc.query("UPDATE task SET status ='Transcoding' WHERE task_id ='#{task_id}'")
            transcode_start

            system("#{transcode}")

            puts ''
            puts "##{time} #{@node_number}: Task ID(#{task_id}) Transcode complete"
            puts ''

            transcode_complete = dbc.query("UPDATE task SET status ='Complete' WHERE task_id ='#{task_id}'")
            transcode_complete

            sleep(3)

          else

            puts "#{time} #{@node_number}: no files to process"

          end


        end

      else

        puts "#{time} #{@node_number}: no files to process"

      end

    end

  end

end
