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

      doc = Nokogiri::XML(File.open("F:/Transcoder/processing_temp/#{file_name}_#{new_folder}/#{xml}"))

      task_id_get = doc.xpath('//manifest/@task_id')
      task_id = task_id_get.to_s

      puts ''
      puts "Processing Task #{task_id}"
      puts ''



      puts ''
      puts 'Parsing xml'
      puts ''
      puts doc
      puts ''

      conform_get = doc.xpath('//transcode_profile/text()')

      puts conform_get

      conform = conform_get.to_s.gsub(/S_PATH/,"#{temp_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/CONFORM_TARGET_DIR/,"#{conform_folder}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"c_#{task_id}")

      transcode_get= doc.xpath('//target_profile/text()')
      target_path= doc.xpath('//target_path/text()')

      transcode = transcode_get.to_s.gsub(/C_PATH/,"#{conform_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/TRG_PATH/,"#{target_path}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"t_#{task_id}")

      puts conform

      conform_query = dbc.query("UPDATE task SET status ='Conforming' WHERE task_id ='#{task_id}'")
      conform_query

      puts ''
      puts "#{time} Conform started"
      puts ''

      system("#{conform}")

      puts ''
      puts "#{time} Conform complete"
      puts ''


      puts transcode_get
      puts transcode

      puts ''
      puts "#{time} Transcode started"
      puts ''


      transcode_query = dbc.query("UPDATE task SET status ='Transcoding' WHERE task_id ='#{task_id}'")
      transcode_query

      system("#{transcode}")

      puts ''
      puts "#{time} Transcode complete"
      puts ''


      transcode_query = dbc.query("UPDATE task SET status ='Complete' WHERE task_id ='#{task_id}'")
      transcode_query

      sleep(3)

    else

      puts 'No files to transcode'




    end


  end

  time = Time.now.getutc

  puts "#{time} This run has completed without error"

end



def process_2

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

      doc = Nokogiri::XML(File.open("F:/Transcoder/processing_temp/#{file_name}_#{new_folder}/#{xml}"))

      task_id_get = doc.xpath('//manifest/@task_id')
      task_id = task_id_get.to_s

      puts ''
      puts "Processing Task #{task_id}"
      puts ''



      puts ''
      puts 'Parsing xml'
      puts ''
      puts doc
      puts ''

      conform_get = doc.xpath('//transcode_profile/text()')

      puts conform_get

      conform = conform_get.to_s.gsub(/S_PATH/,"#{temp_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/CONFORM_TARGET_DIR/,"#{conform_folder}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"c_#{task_id}")

      transcode_get= doc.xpath('//target_profile/text()')
      target_path= doc.xpath('//target_path/text()')

      transcode = transcode_get.to_s.gsub(/C_PATH/,"#{conform_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/TRG_PATH/,"#{target_path}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"t_#{task_id}")

      puts conform

      conform_query = dbc.query("UPDATE task SET status ='Conforming' WHERE task_id ='#{task_id}'")
      conform_query

      puts ''
      puts "#{time} Conform started"
      puts ''

      system("#{conform}")

      puts ''
      puts "#{time} Conform complete"
      puts ''


      puts transcode_get
      puts transcode

      puts ''
      puts "#{time} Transcode started"
      puts ''

      transcode_query = dbc.query("UPDATE task SET status ='Transcoding' WHERE task_id ='#{task_id}'")
      transcode_query

      system("#{transcode}")

      puts ''
      puts "#{time} Transcode complete"
      puts ''

      transcode_query = dbc.query("UPDATE task SET status ='Complete' WHERE task_id ='#{task_id}'")
      transcode_query

      sleep(3)

    else

      puts 'No files to transcode'


    end


  end

  time = Time.now.getutc

  puts "#{time} This run has completed without error"

  sleep(4)

end

def process_3

  sleep(4)

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

      doc = Nokogiri::XML(File.open("F:/Transcoder/processing_temp/#{file_name}_#{new_folder}/#{xml}"))
      task_id_get = doc.xpath('//manifest/@task_id')
      task_id = task_id_get.to_s

      puts ''
      puts "Processing Task #{task_id}"
      puts ''

      puts ''
      puts 'Parsing xml'
      puts ''
      puts doc
      puts ''

      conform_get = doc.xpath('//transcode_profile/text()')

      puts conform_get

      conform = conform_get.to_s.gsub(/S_PATH/,"#{temp_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/CONFORM_TARGET_DIR/,"#{conform_folder}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"c_#{task_id}")

      transcode_get= doc.xpath('//target_profile/text()')
      target_path= doc.xpath('//target_path/text()')

      transcode = transcode_get.to_s.gsub(/C_PATH/,"#{conform_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/TRG_PATH/,"#{target_path}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"t_#{task_id}")

      puts conform

      conform_query = dbc.query("UPDATE task SET status ='Conforming' WHERE task_id ='#{task_id}'")
      conform_query

      puts ''
      puts "#{time} Conform started"
      puts ''

      system("#{conform}")

      puts ''
      puts "#{time} Conform complete"
      puts ''


      puts transcode_get
      puts transcode

      puts ''
      puts "#{time} Transcode started"
      puts ''

      transcode_query = dbc.query("UPDATE task SET status ='Transcoding' WHERE task_id ='#{task_id}'")
      transcode_query

      system("#{transcode}")

      puts ''
      puts "#{time} Transcode complete"
      puts ''

      transcode_query = dbc.query("UPDATE task SET status ='Complete' WHERE task_id ='#{task_id}'")
      transcode_query

      sleep(3)

    else

      puts 'No files to transcode'

    end


  end

  time = Time.now.getutc

  puts "#{time} This run has completed without error"

  sleep(5)

end

def process_4

  sleep(2)

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

      doc = Nokogiri::XML(File.open("F:/Transcoder/processing_temp/#{file_name}_#{new_folder}/#{xml}"))

      task_id_get = doc.xpath('//manifest/@task_id')
      task_id = task_id_get.to_s

      puts ''
      puts "Processing Task #{task_id}"
      puts ''



      puts ''
      puts 'Parsing xml'
      puts ''
      puts doc
      puts ''

      conform_get = doc.xpath('//transcode_profile/text()')

      puts conform_get

      conform = conform_get.to_s.gsub(/S_PATH/,"#{temp_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/CONFORM_TARGET_DIR/,"#{conform_folder}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"c_#{task_id}")

      transcode_get= doc.xpath('//target_profile/text()')
      target_path= doc.xpath('//target_path/text()')

      transcode = transcode_get.to_s.gsub(/C_PATH/,"#{conform_folder}").gsub(/F_NAME/,"#{file_name}").gsub(/TRG_PATH/,"#{target_path}").gsub(/2&gt;/,'2>').gsub(/LOG_FILE/,"t_#{task_id}")

      puts conform

      conform_query = dbc.query("UPDATE task SET status ='Conforming' WHERE task_id ='#{task_id}'")
      conform_query

      puts ''
      puts "#{time} Conform started"
      puts ''

      system("#{conform}")

      puts ''
      puts "#{time} Conform complete"
      puts ''


      puts transcode_get
      puts transcode

      puts ''
      puts "#{time} Transcode started"
      puts ''


      transcode_query = dbc.query("UPDATE task SET status ='Transcoding' WHERE task_id ='#{task_id}'")
      transcode_query

      system("#{transcode}")

      puts ''
      puts "#{time} Transcode complete"
      puts ''

      transcode_query = dbc.query("UPDATE task SET status ='Complete' WHERE task_id ='#{task_id}'")
      transcode_query

      sleep(3)

    else

      puts 'No files to transcode'




    end


  end

  time = Time.now.getutc

  puts "#{time} This run has completed without error"

  sleep(2)

end

transcode1 = Thread.new{process_1}
transcode2 = Thread.new{process_2}
transcode3 = Thread.new{process_3}
transcode4 = Thread.new{process_4}



transcode1.join
transcode2.join
transcode3.join
transcode4.join
