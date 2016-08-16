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
