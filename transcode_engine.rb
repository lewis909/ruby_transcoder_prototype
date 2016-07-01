require 'securerandom'
require 'fileutils'
require 'thread'
require 'Nokogiri'
require 'mysql2'

def process_1

  Dir['F:/Transcoder/staging/*.mp4'].each do |f|

    next if File.exist?(f,) && File.exist?('F:/Transcoder/staging/*.xml')

    file_name = f[22,256].gsub(/.mp4/,'')
    xml = file_name+'.xml'

    time = Time.now.getutc
    #timestamp = time.to_s[0,19].gsub(/ /,'-').gsub(/:/,'')
    new_folder = SecureRandom.uuid


    dbc = Mysql2::Client.new(:host => 'localhost',:username => 'lewis_transcode', :password => 'tool4602', :database => 'media_hub')


    if File.exists?("F:/Transcoder/staging/#{file_name}.mp4") && File.exist?("F:/Transcoder/staging/#{xml}")
      puts ''
      puts "#{time} - Files ready starting the transcode process."
      puts ''

      FileUtils::mkdir_p("F:/Transcoder/processing_temp/#{file_name}_#{new_folder}/conform")
      temp_folder = "F:/Transcoder/processing_temp/#{file_name}_#{new_folder}"
      conform_folder ="F:/Transcoder/processing_temp/#{file_name}_#{new_folder}/conform"

      FileUtils.mv Dir.glob("#{f}"), temp_folder
      FileUtils.mv Dir.glob("F:/Transcoder/staging/#{xml}"), temp_folder

      doc = Nokogiri::XML(File.read("F:/Transcoder/processing_temp/#{file_name}_#{new_folder}/#{xml}"))

      task_id = doc.xpath('//manifest/@task_id').to_s

      puts ''
      puts "Node 1: Processing Task #{task_id}"
      puts ''



      puts ''
      puts 'Node 1: Parsing xml'
      puts ''
      puts doc
      puts ''

      conform_get = doc.xpath('//conform_profile/text()')

      puts conform_get

      #conform = conform_get.to_s.gsub(/S_PATH/,"#{temp_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/CONFORM_TARGET_DIR/,"#{conform_folder}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"c_#{task_id}")

      transcode_get= doc.xpath('//transcode_profile/text()')
      target_path= doc.xpath('//target_path/text()')


      seg_number = doc.xpath('//number_of_segments/text()').to_s

      puts "#{seg_number}"

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

        puts "Number of Segments #{seg_conform}"

        conform = conform_get.to_s.gsub(/S_PATH/,"#{temp_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/SEG_CONFORM/,"#{seg_conform}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"c_#{task_id}")

      elsif seg_number == '2'

        seg_conform = "-ss #{seg_1_start} -t #{seg_1_dur} #{conform_folder}/s1_#{file_name}.mp4 -ss #{seg_2_start} -t #{seg_2_dur} #{conform_folder}/s2_#{file_name}.mp4"

        puts "Number of Segments #{seg_conform}"

        conform = conform_get.to_s.gsub(/S_PATH/,"#{temp_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/SEG_CONFORM/,"#{seg_conform}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"c_#{task_id}")


      elsif seg_number == '3'

        seg_conform = "-ss #{seg_1_start} -t #{seg_1_dur} #{conform_folder}/s1_#{file_name}.mp4 -ss #{seg_2_start} -t #{seg_2_dur} #{conform_folder}/s2_#{file_name}.mp4 -ss #{seg_3_start} -t #{seg_3_dur} #{conform_folder}/s3_#{file_name}.mp4"

        puts "Number of Segments #{seg_conform}"

        conform = conform_get.to_s.gsub(/S_PATH/,"#{temp_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/SEG_CONFORM/,"#{seg_conform}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"c_#{task_id}")

      elsif seg_number =='4'

        seg_conform = "-ss #{seg_1_start} -t #{seg_1_dur} #{conform_folder}/s1_#{file_name}.mp4 -ss #{seg_2_start} -t #{seg_2_dur} #{conform_folder}/s2_#{file_name}.mp4 -ss #{seg_3_start} -t #{seg_3_dur} #{conform_folder}/s3_#{file_name}.mp4 -ss #{seg_4_start} -t #{seg_4_dur} #{conform_folder}/s4_#{file_name}.mp4"

        puts "Number of Segments #{seg_conform}"

        conform = conform_get.to_s.gsub(/S_PATH/,"#{temp_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/SEG_CONFORM/,"#{seg_conform}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"c_#{task_id}")


      end




      puts conform

      conform_query = dbc.query("UPDATE task SET status ='Conforming' WHERE task_id ='#{task_id}'")
      conform_query

      puts ''
      puts "Node 1: #{time} Conform started"
      puts ''

      system("#{conform}")

      puts ''
      puts "Node 1: #{time} Conform complete"
      puts ''

      seg_list = Dir[conform_folder + '/*']

      File.open("#{conform_folder}/#{file_name}_conform_list.txt", "w+") do |f|
        seg_list.each { |element| f.puts('file ' + "'" + element +"'") }
      end

      conform_list = "#{file_name}_conform_list.txt"

      transcode = transcode_get.to_s.gsub(/T_PATH/,"#{conform_folder}").gsub(/CONFORM_LIST/,"#{conform_list}").gsub(/F_NAME/,"#{file_name}").gsub(/TRC_PATH/,"#{target_path}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"t_#{task_id}").gsub('/','\\')


      puts transcode_get
      puts transcode

      puts ''
      puts "Node 1: #{time} Transcode started"
      puts ''


      transcode_query = dbc.query("UPDATE task SET status ='Transcoding' WHERE task_id ='#{task_id}'")
      transcode_query

      system("#{transcode}")

      puts ''
      puts "Node 1: #{time} Transcode complete"
      puts ''


      transcode_query = dbc.query("UPDATE task SET status ='Complete' WHERE task_id ='#{task_id}'")
      transcode_query

      sleep(3)

    else

      puts 'Node 1: No files to transcode'

    end


  end

  time = Time.now.getutc

  puts "Node 1: #{time} This run has completed without error"

end

def process_2

  Dir['F:/Transcoder/staging/*.mp4'].each do |f|

    sleep(2)

    next if File.exist?(f,) && File.exist?('F:/Transcoder/staging/*.xml')

    file_name = f[22,256].gsub(/.mp4/,'')
    xml = file_name+'.xml'

    time = Time.now.getutc
    #timestamp = time.to_s[0,19].gsub(/ /,'-').gsub(/:/,'')
    new_folder = SecureRandom.uuid


    dbc = Mysql2::Client.new(:host => 'localhost',:username => 'lewis_transcode', :password => 'tool4602', :database => 'media_hub')


    if File.exists?("F:/Transcoder/staging/#{file_name}.mp4") && File.exist?("F:/Transcoder/staging/#{xml}")
      puts ''
      puts "#{time} - Files ready starting the transcode process."
      puts ''

      FileUtils::mkdir_p("F:/Transcoder/processing_temp/#{file_name}_#{new_folder}/conform")
      temp_folder = "F:/Transcoder/processing_temp/#{file_name}_#{new_folder}"
      conform_folder ="F:/Transcoder/processing_temp/#{file_name}_#{new_folder}/conform"

      FileUtils.mv Dir.glob("#{f}"), temp_folder
      FileUtils.mv Dir.glob("F:/Transcoder/staging/#{xml}"), temp_folder

      doc = Nokogiri::XML(File.read("F:/Transcoder/processing_temp/#{file_name}_#{new_folder}/#{xml}"))

      task_id = doc.xpath('//manifest/@task_id').to_s

      puts ''
      puts "Node 2: Processing Task #{task_id}"
      puts ''



      puts ''
      puts 'Parsing xml'
      puts ''
      puts doc
      puts ''

      conform_get = doc.xpath('//conform_profile/text()')

      puts conform_get

      #conform = conform_get.to_s.gsub(/S_PATH/,"#{temp_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/CONFORM_TARGET_DIR/,"#{conform_folder}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"c_#{task_id}")

      transcode_get= doc.xpath('//transcode_profile/text()')
      target_path= doc.xpath('//target_path/text()')


      seg_number = doc.xpath('//number_of_segments/text()').to_s

      puts "#{seg_number}"

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

        puts "Number of Segments #{seg_conform}"

        conform = conform_get.to_s.gsub(/S_PATH/,"#{temp_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/SEG_CONFORM/,"#{seg_conform}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"c_#{task_id}")

      elsif seg_number == '2'

        seg_conform = "-ss #{seg_1_start} -t #{seg_1_dur} #{conform_folder}/s1_#{file_name}.mp4 -ss #{seg_2_start} -t #{seg_2_dur} #{conform_folder}/s2_#{file_name}.mp4"

        puts "Number of Segments #{seg_conform}"

        conform = conform_get.to_s.gsub(/S_PATH/,"#{temp_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/SEG_CONFORM/,"#{seg_conform}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"c_#{task_id}")


      elsif seg_number == '3'

        seg_conform = "-ss #{seg_1_start} -t #{seg_1_dur} #{conform_folder}/s1_#{file_name}.mp4 -ss #{seg_2_start} -t #{seg_2_dur} #{conform_folder}/s2_#{file_name}.mp4 -ss #{seg_3_start} -t #{seg_3_dur} #{conform_folder}/s3_#{file_name}.mp4"

        puts "Number of Segments #{seg_conform}"

        conform = conform_get.to_s.gsub(/S_PATH/,"#{temp_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/SEG_CONFORM/,"#{seg_conform}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"c_#{task_id}")

      elsif seg_number =='4'

        seg_conform = "-ss #{seg_1_start} -t #{seg_1_dur} #{conform_folder}/s1_#{file_name}.mp4 -ss #{seg_2_start} -t #{seg_2_dur} #{conform_folder}/s2_#{file_name}.mp4 -ss #{seg_3_start} -t #{seg_3_dur} #{conform_folder}/s3_#{file_name}.mp4 -ss #{seg_4_start} -t #{seg_4_dur} #{conform_folder}/s4_#{file_name}.mp4"

        puts "Number of Segments #{seg_conform}"

        conform = conform_get.to_s.gsub(/S_PATH/,"#{temp_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/SEG_CONFORM/,"#{seg_conform}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"c_#{task_id}")


      end




      puts conform

      conform_query = dbc.query("UPDATE task SET status ='Conforming' WHERE task_id ='#{task_id}'")
      conform_query

      puts ''
      puts "Node 2: #{time} Conform started"
      puts ''

      system("#{conform}")

      puts ''
      puts "Node 2: #{time} Conform complete"
      puts ''

      seg_list = Dir[conform_folder + '/*']

      File.open("#{conform_folder}/#{file_name}_conform_list.txt", "w+") do |f|
        seg_list.each { |element| f.puts('file ' + "'" + element +"'") }
      end

      conform_list = "#{file_name}_conform_list.txt"

      transcode = transcode_get.to_s.gsub(/T_PATH/,"#{conform_folder}").gsub(/CONFORM_LIST/,"#{conform_list}").gsub(/F_NAME/,"#{file_name}").gsub(/TRC_PATH/,"#{target_path}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"t_#{task_id}").gsub('/','\\')


      puts transcode_get
      puts transcode

      puts ''
      puts "Node 2: #{time} Transcode started"
      puts ''


      transcode_query = dbc.query("UPDATE task SET status ='Transcoding' WHERE task_id ='#{task_id}'")
      transcode_query

      system("#{transcode}")

      puts ''
      puts "Node 2: #{time} Transcode complete"
      puts ''


      transcode_query = dbc.query("UPDATE task SET status ='Complete' WHERE task_id ='#{task_id}'")
      transcode_query

      sleep(3)

    else

      puts 'Node 2: No files to transcode'

    end


  end

  time = Time.now.getutc

  puts "Node 2: #{time} This run has completed without error"

end

def process_3

  sleep(3)

  Dir['F:/Transcoder/staging/*.mp4'].each do |f|

    next if File.exist?(f,) && File.exist?('F:/Transcoder/staging/*.xml')

    file_name = f[22,256].gsub(/.mp4/,'')
    xml = file_name+'.xml'

    time = Time.now.getutc
    #timestamp = time.to_s[0,19].gsub(/ /,'-').gsub(/:/,'')
    new_folder = SecureRandom.uuid


    dbc = Mysql2::Client.new(:host => 'localhost',:username => 'lewis_transcode', :password => 'tool4602', :database => 'media_hub')


    if File.exists?("F:/Transcoder/staging/#{file_name}.mp4") && File.exist?("F:/Transcoder/staging/#{xml}")
      puts ''
      puts "#{time} - Files ready starting the transcode process."
      puts ''

      FileUtils::mkdir_p("F:/Transcoder/processing_temp/#{file_name}_#{new_folder}/conform")
      temp_folder = "F:/Transcoder/processing_temp/#{file_name}_#{new_folder}"
      conform_folder ="F:/Transcoder/processing_temp/#{file_name}_#{new_folder}/conform"

      FileUtils.mv Dir.glob("#{f}"), temp_folder
      FileUtils.mv Dir.glob("F:/Transcoder/staging/#{xml}"), temp_folder

      doc = Nokogiri::XML(File.read("F:/Transcoder/processing_temp/#{file_name}_#{new_folder}/#{xml}"))

      task_id = doc.xpath('//manifest/@task_id').to_s

      puts ''
      puts "Node 3: Processing Task #{task_id}"
      puts ''



      puts ''
      puts 'Parsing xml'
      puts ''
      puts doc
      puts ''

      conform_get = doc.xpath('//conform_profile/text()')

      puts conform_get

      #conform = conform_get.to_s.gsub(/S_PATH/,"#{temp_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/CONFORM_TARGET_DIR/,"#{conform_folder}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"c_#{task_id}")

      transcode_get= doc.xpath('//transcode_profile/text()')
      target_path= doc.xpath('//target_path/text()')


      seg_number = doc.xpath('//number_of_segments/text()').to_s

      puts "#{seg_number}"

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

        puts "Number of Segments #{seg_conform}"

        conform = conform_get.to_s.gsub(/S_PATH/,"#{temp_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/SEG_CONFORM/,"#{seg_conform}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"c_#{task_id}")

      elsif seg_number == '2'

        seg_conform = "-ss #{seg_1_start} -t #{seg_1_dur} #{conform_folder}/s1_#{file_name}.mp4 -ss #{seg_2_start} -t #{seg_2_dur} #{conform_folder}/s2_#{file_name}.mp4"

        puts "Number of Segments #{seg_conform}"

        conform = conform_get.to_s.gsub(/S_PATH/,"#{temp_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/SEG_CONFORM/,"#{seg_conform}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"c_#{task_id}")


      elsif seg_number == '3'

        seg_conform = "-ss #{seg_1_start} -t #{seg_1_dur} #{conform_folder}/s1_#{file_name}.mp4 -ss #{seg_2_start} -t #{seg_2_dur} #{conform_folder}/s2_#{file_name}.mp4 -ss #{seg_3_start} -t #{seg_3_dur} #{conform_folder}/s3_#{file_name}.mp4"

        puts "Number of Segments #{seg_conform}"

        conform = conform_get.to_s.gsub(/S_PATH/,"#{temp_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/SEG_CONFORM/,"#{seg_conform}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"c_#{task_id}")

      elsif seg_number =='4'

        seg_conform = "-ss #{seg_1_start} -t #{seg_1_dur} #{conform_folder}/s1_#{file_name}.mp4 -ss #{seg_2_start} -t #{seg_2_dur} #{conform_folder}/s2_#{file_name}.mp4 -ss #{seg_3_start} -t #{seg_3_dur} #{conform_folder}/s3_#{file_name}.mp4 -ss #{seg_4_start} -t #{seg_4_dur} #{conform_folder}/s4_#{file_name}.mp4"

        puts "Number of Segments #{seg_conform}"

        conform = conform_get.to_s.gsub(/S_PATH/,"#{temp_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/SEG_CONFORM/,"#{seg_conform}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"c_#{task_id}")


      end




      puts conform

      conform_query = dbc.query("UPDATE task SET status ='Conforming' WHERE task_id ='#{task_id}'")
      conform_query

      puts ''
      puts "Node 3: #{time} Conform started"
      puts ''

      system("#{conform}")

      puts ''
      puts "Node 3: #{time} Conform complete"
      puts ''

      seg_list = Dir[conform_folder + '/*']

      File.open("#{conform_folder}/#{file_name}_conform_list.txt", "w+") do |f|
        seg_list.each { |element| f.puts('file ' + "'" + element +"'") }
      end

      conform_list = "#{file_name}_conform_list.txt"

      transcode = transcode_get.to_s.gsub(/T_PATH/,"#{conform_folder}").gsub(/CONFORM_LIST/,"#{conform_list}").gsub(/F_NAME/,"#{file_name}").gsub(/TRC_PATH/,"#{target_path}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"t_#{task_id}").gsub('/','\\')


      puts transcode_get
      puts transcode

      puts ''
      puts "Node 3: #{time} Transcode started"
      puts ''


      transcode_query = dbc.query("UPDATE task SET status ='Transcoding' WHERE task_id ='#{task_id}'")
      transcode_query

      system("#{transcode}")

      puts ''
      puts "Node 3: #{time} Transcode complete"
      puts ''


      transcode_query = dbc.query("UPDATE task SET status ='Complete' WHERE task_id ='#{task_id}'")
      transcode_query

      sleep(3)

    else

      puts 'Node 3: No files to transcode'

    end


  end

  time = Time.now.getutc

  puts "Node 3: #{time} This run has completed without error"

end

def process_4

  sleep(5)

  Dir['F:/Transcoder/staging/*.mp4'].each do |f|

    next if File.exist?(f,) && File.exist?('F:/Transcoder/staging/*.xml')

    file_name = f[22,256].gsub(/.mp4/,'')
    xml = file_name+'.xml'

    time = Time.now.getutc
    #timestamp = time.to_s[0,19].gsub(/ /,'-').gsub(/:/,'')
    new_folder = SecureRandom.uuid


    dbc = Mysql2::Client.new(:host => 'localhost',:username => 'lewis_transcode', :password => 'tool4602', :database => 'media_hub')


    if File.exists?("F:/Transcoder/staging/#{file_name}.mp4") && File.exist?("F:/Transcoder/staging/#{xml}")
      puts ''
      puts "#{time} - Files ready starting the transcode process."
      puts ''

      FileUtils::mkdir_p("F:/Transcoder/processing_temp/#{file_name}_#{new_folder}/conform")
      temp_folder = "F:/Transcoder/processing_temp/#{file_name}_#{new_folder}"
      conform_folder ="F:/Transcoder/processing_temp/#{file_name}_#{new_folder}/conform"

      FileUtils.mv Dir.glob("#{f}"), temp_folder
      FileUtils.mv Dir.glob("F:/Transcoder/staging/#{xml}"), temp_folder

      doc = Nokogiri::XML(File.read("F:/Transcoder/processing_temp/#{file_name}_#{new_folder}/#{xml}"))

      task_id = doc.xpath('//manifest/@task_id').to_s

      puts ''
      puts "Node 4: Processing Task #{task_id}"
      puts ''



      puts ''
      puts 'Parsing xml'
      puts ''
      puts doc
      puts ''

      conform_get = doc.xpath('//conform_profile/text()')

      puts conform_get

      #conform = conform_get.to_s.gsub(/S_PATH/,"#{temp_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/CONFORM_TARGET_DIR/,"#{conform_folder}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"c_#{task_id}")

      transcode_get= doc.xpath('//transcode_profile/text()')
      target_path= doc.xpath('//target_path/text()')


      seg_number = doc.xpath('//number_of_segments/text()').to_s

      puts "#{seg_number}"

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

        puts "Number of Segments #{seg_conform}"

        conform = conform_get.to_s.gsub(/S_PATH/,"#{temp_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/SEG_CONFORM/,"#{seg_conform}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"c_#{task_id}")

      elsif seg_number == '2'

        seg_conform = "-ss #{seg_1_start} -t #{seg_1_dur} #{conform_folder}/s1_#{file_name}.mp4 -ss #{seg_2_start} -t #{seg_2_dur} #{conform_folder}/s2_#{file_name}.mp4"

        puts "Number of Segments #{seg_conform}"

        conform = conform_get.to_s.gsub(/S_PATH/,"#{temp_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/SEG_CONFORM/,"#{seg_conform}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"c_#{task_id}")


      elsif seg_number == '3'

        seg_conform = "-ss #{seg_1_start} -t #{seg_1_dur} #{conform_folder}/s1_#{file_name}.mp4 -ss #{seg_2_start} -t #{seg_2_dur} #{conform_folder}/s2_#{file_name}.mp4 -ss #{seg_3_start} -t #{seg_3_dur} #{conform_folder}/s3_#{file_name}.mp4"

        puts "Number of Segments #{seg_conform}"

        conform = conform_get.to_s.gsub(/S_PATH/,"#{temp_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/SEG_CONFORM/,"#{seg_conform}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"c_#{task_id}")

      elsif seg_number =='4'

        seg_conform = "-ss #{seg_1_start} -t #{seg_1_dur} #{conform_folder}/s1_#{file_name}.mp4 -ss #{seg_2_start} -t #{seg_2_dur} #{conform_folder}/s2_#{file_name}.mp4 -ss #{seg_3_start} -t #{seg_3_dur} #{conform_folder}/s3_#{file_name}.mp4 -ss #{seg_4_start} -t #{seg_4_dur} #{conform_folder}/s4_#{file_name}.mp4"

        puts "Number of Segments #{seg_conform}"

        conform = conform_get.to_s.gsub(/S_PATH/,"#{temp_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/SEG_CONFORM/,"#{seg_conform}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"c_#{task_id}")


      end




      puts conform

      conform_query = dbc.query("UPDATE task SET status ='Conforming' WHERE task_id ='#{task_id}'")
      conform_query

      puts ''
      puts "Node 4: #{time} Conform started"
      puts ''

      system("#{conform}")

      puts ''
      puts "Node 4: #{time} Conform complete"
      puts ''

      seg_list = Dir[conform_folder + '/*']

      File.open("#{conform_folder}/#{file_name}_conform_list.txt", "w+") do |f|
        seg_list.each { |element| f.puts('file ' + "'" + element +"'") }
      end

      conform_list = "#{file_name}_conform_list.txt"

      transcode = transcode_get.to_s.gsub(/T_PATH/,"#{conform_folder}").gsub(/CONFORM_LIST/,"#{conform_list}").gsub(/F_NAME/,"#{file_name}").gsub(/TRC_PATH/,"#{target_path}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"t_#{task_id}").gsub('/','\\')


      puts transcode_get
      puts transcode

      puts ''
      puts "Node 4: #{time} Transcode started"
      puts ''


      transcode_query = dbc.query("UPDATE task SET status ='Transcoding' WHERE task_id ='#{task_id}'")
      transcode_query

      system("#{transcode}")

      puts ''
      puts "Node 4: #{time} Transcode complete"
      puts ''


      transcode_query = dbc.query("UPDATE task SET status ='Complete' WHERE task_id ='#{task_id}'")
      transcode_query

      sleep(3)

    else

      puts 'Node 4: No files to transcode'

    end


  end

  time = Time.now.getutc

  puts "Node 4: #{time} This run has completed without error"

end

transcode1 = Thread.new{process_1}
transcode2 = Thread.new{process_2}
transcode3 = Thread.new{process_3}
transcode4 = Thread.new{process_4}

transcode1.join
transcode2.join
transcode3.join
transcode4.join
