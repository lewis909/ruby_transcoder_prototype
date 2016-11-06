module TranscodeNode

  #Source Node Paths

  @transcode_node_1 = 'F:/Transcoder/staging/node_1/'
  @transcode_node_2 = 'F:/Transcoder/staging/node_2/'
  @transcode_node_3 = 'F:/Transcoder/staging/node_3/'
  @transcode_node_4 = 'F:/Transcoder/staging/node_4/'


  def self.tn1

    return @transcode_node_1

  end

  def self.tn2

    return @transcode_node_2

  end

  def self.tn3

    return @transcode_node_3

  end

  def self.tn4

    return @transcode_node_4

  end

  #Database connection

  def self.dbc

    return Mysql2::Client.new(:host => 'localhost',:username => 'lewis_transcode', :password => 'tool4602', :database => 'media_hub')

  end

end

module Ingest_config

  @ingest_in = 'F:/Transcoder/ingest/'
  @ingest_out = 'F:/Transcoder/repo/'
  @image_dir = 'F:/Transcoder/repo/images'

  def self.ingest_in

    return @ingest_in

  end

  def self.ingest_out

    return @ingest_out

  end

  def self.image_dir

    return @image_dir

  end

end
