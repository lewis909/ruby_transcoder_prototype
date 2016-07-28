require 'securerandom'
require 'fileutils'
require 'thread'
require 'Nokogiri'
require 'mysql2'
require 'digest'
#load 'config.rb'

class Job_transcode

  def initialize(node_path, node_number, dbc)

    @node_path = node_path
    @node_number = node_number
    @dbc = dbc

    def start

      watchfolder = @node_path

      time = Time.now.getutc

      if !Dir.glob("#{watchfolder}"+'*.mp4').empty?

        Dir["#{watchfolder}"+'*.mp4'].each do |f|

          next if File.exist?(f,) && File.exist?("#{watchfolder}"+'*.xml')

          file_name = File.basename("#{f}", '.mp4')
          #tar_file_name = File.basename("#{f}")
          xml = file_name+'.xml'

          #timestamp = time.to_s[0,19].gsub(/ /,'-').gsub(/:/,'')
          new_folder = SecureRandom.uuid

          dbc = @dbc

          if File.exists?("#{watchfolder}#{file_name}.mp4") && File.exist?("#{watchfolder}#{xml}")
            puts ''
            puts "#{time} #{@node_number}: - Files ready starting the transcode process."
            puts ''

            FileUtils::mkdir_p("F:/Transcoder/processing_temp/#{file_name}_#{new_folder}/conform/temp")
            temp_folder = "F:/Transcoder/processing_temp/#{file_name}_#{new_folder}"
            conform_folder = "F:/Transcoder/processing_temp/#{file_name}_#{new_folder}/conform"
            temp = "F:/Transcoder/processing_temp/#{file_name}_#{new_folder}/conform/temp/"

            FileUtils.mv Dir.glob("#{f}"), temp_folder
            FileUtils.mv Dir.glob("#{watchfolder}#{xml}"), temp
            File.rename("#{temp}#{xml}","#{temp}core_xml.xml")

            doc = Nokogiri::XML(File.read("#{temp}core_xml.xml"))

            #xml variables

            task_id = doc.xpath('//manifest/@task_id').to_s
            conform_get = doc.xpath('//conform_profile/text()')
            transcode_get= doc.xpath('//transcode_profile/text()')
            profile = doc.xpath('//transcode_profile/@profile_name').to_s
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


            puts ''
            puts "#{time} #{@node_number}: Processing Task #{task_id}"
            puts ''
            puts "#{time} #{@node_number}: Task ID(#{task_id}) Parsing #{xml}"
            puts ''

            def tc_dur_to_sec(hours, mins, secs)
              hours.to_i * 3600 + mins.to_i * 60 + secs.to_i
            end

            if seg_number == '1'

              seg_conform = "-ss #{seg_1_start} -t #{seg_1_dur} #{conform_folder}/s1_#{file_name}.mp4"

              conform = conform_get.to_s.gsub(/S_PATH/,"#{temp_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/SEG_CONFORM/,"#{seg_conform}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"c_#{task_id}")

              conform_s1_dur_get = seg_1_dur.split(':')

              con_dur =  tc_dur_to_sec(*conform_s1_dur_get)

            elsif seg_number == '2'

              seg_conform = "-ss #{seg_1_start} -t #{seg_1_dur} #{conform_folder}/s1_#{file_name}.mp4 -ss #{seg_2_start} -t #{seg_2_dur} #{conform_folder}/s2_#{file_name}.mp4"

              conform = conform_get.to_s.gsub(/S_PATH/,"#{temp_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/SEG_CONFORM/,"#{seg_conform}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"c_#{task_id}")

              conform_s1_dur_get = seg_1_dur.split(':')

              conform_s2_dur_get = seg_2_dur.split(':')

              con_dur =  tc_dur_to_sec(*conform_s1_dur_get) + tc_dur_to_sec(*conform_s2_dur_get)

            elsif seg_number == '3'

              seg_conform = "-ss #{seg_1_start} -t #{seg_1_dur} #{conform_folder}/s1_#{file_name}.mp4 -ss #{seg_2_start} -t #{seg_2_dur} #{conform_folder}/s2_#{file_name}.mp4 -ss #{seg_3_start} -t #{seg_3_dur} #{conform_folder}/s3_#{file_name}.mp4"

              conform = conform_get.to_s.gsub(/S_PATH/,"#{temp_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/SEG_CONFORM/,"#{seg_conform}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"c_#{task_id}")

              conform_s1_dur_get = seg_1_dur.split(':')

              conform_s2_dur_get = seg_2_dur.split(':')

              conform_s3_dur_get = seg_3_dur.split(':')

              con_dur =  tc_dur_to_sec(*conform_s1_dur_get) + tc_dur_to_sec(*conform_s2_dur_get) + tc_dur_to_sec(*conform_s3_dur_get)

            elsif seg_number =='4'

              seg_conform = "-ss #{seg_1_start} -t #{seg_1_dur} #{conform_folder}/s1_#{file_name}.mp4 -ss #{seg_2_start} -t #{seg_2_dur} #{conform_folder}/s2_#{file_name}.mp4 -ss #{seg_3_start} -t #{seg_3_dur} #{conform_folder}/s3_#{file_name}.mp4 -ss #{seg_4_start} -t #{seg_4_dur} #{conform_folder}/s4_#{file_name}.mp4"

              conform = conform_get.to_s.gsub(/S_PATH/,"#{temp_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/SEG_CONFORM/,"#{seg_conform}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"c_#{task_id}")

              conform_s1_dur_get = seg_1_dur.split(':')

              conform_s2_dur_get = seg_2_dur.split(':')

              conform_s3_dur_get = seg_3_dur.split(':')

              conform_s4_dur_get = seg_4_dur.split(':')

              con_dur =  tc_dur_to_sec(*conform_s1_dur_get) + tc_dur_to_sec(*conform_s2_dur_get) + tc_dur_to_sec(*conform_s3_dur_get) + tc_dur_to_sec(*conform_s4_dur_get)


            end

            #puts conform

            #Conform Process

            conform_query = dbc.query("UPDATE task SET status ='Conforming' WHERE task_id ='#{task_id}'")
            conform_query

            puts ''
            puts "#{time} #{@node_number}: Task ID(#{task_id}) Conform started"
            puts ''

            system("#{conform}")

            seg_list = Dir[conform_folder + '/*.mp4']

            File.open("#{conform_folder}/#{file_name}_conform_list.txt", 'w+') do |f|

              seg_list.each { |element| f.puts('file ' + "'" + element +"'") }

            end

            File.open("F:/Transcoder/logs/transcode_logs/temp/#{task_id}_dur.txt", 'w+') do |cd|

              cd.puts con_dur

            end

            puts ''
            puts "#{time} #{@node_number}: Task ID(#{task_id}) Conform complete"
            puts ''

            #Transcode process

            conform_list = "#{file_name}_conform_list.txt"

            transcode = transcode_get.to_s.gsub(/T_PATH/,"#{conform_folder}").gsub(/CONFORM_LIST/,"#{conform_list}").gsub(/F_NAME/,"#{file_name}").gsub(/TRC_PATH/,"#{temp}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"t_#{task_id}").gsub('/','\\')

            #puts transcode_get
            #puts transcode

            puts ''
            puts "#{time} #{@node_number}: Task ID(#{task_id}) Transcode started"
            puts ''

            transcode_start = dbc.query("UPDATE task SET status ='Transcoding' WHERE task_id ='#{task_id}'")
            transcode_start

            system("#{transcode}")

            puts ''
            puts "##{time} #{@node_number}: Task ID(#{task_id}) Transcode complete"
            puts ''

            #Metadata Process

            t_file_name = "#{file_name}.mp4"
            file_size = File.size("#{temp}#{file_name}.mp4")
            md5 = Digest::MD5.hexdigest("#{temp}#{file_name}.mp4")

            i_file_name ='test'
            i_file_size = 'test'
            i_md5 = 'test'

            builder = Nokogiri::XML::Builder.new do |xml|
              xml.file_data {
                xml.video_file {
                  xml.file_name "#{t_file_name}"
                  xml.file_size "#{file_size}"
                  xml.md5_checksum "#{md5}"
                }
                xml.image_1 {
                  xml.file_name "#{i_file_name}"
                  xml.file_size "#{i_file_size}"
                  xml.md5_checksum "#{i_md5}"
                }
              }
            end

            File.open("#{temp}file_data.xml", 'w+') do |fd|
              fd.puts builder.to_xml
            end

            FileUtils.copy "F:/Transcoder/xslt_repo/#{profile}/#{profile}.xsl", temp

            xslt = "java -jar C:/SaxonHE9-7-0-7J/saxon9he.jar #{temp}core_xml.xml #{temp}google.xsl > #{temp}#{file_name}.xml"

            system("#{xslt}")

            transcode_complete = dbc.query("UPDATE task SET status ='Complete' WHERE task_id ='#{task_id}'")
            transcode_complete

            FileUtils.mv "#{temp}#{file_name}.mp4", "#{target_path}"
            FileUtils.mv "#{temp}#{file_name}.xml", "#{target_path}"

            puts "#{time} #{@node_number}: Task #{task_id} Complete"

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
