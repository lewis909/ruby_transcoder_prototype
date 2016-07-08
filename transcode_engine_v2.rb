load 'job_prep.rb'
load 'job_transcode.rb'

def file_prep
  puts 'Starting File Fetch'

  job_prep = Job_prep.new
  job_prep.check_file
puts 'Fetch complete'
end

def transcode_1

  sleep(2)

  job_transcode = Job_transcode.new
  job_transcode.start

end

def transcode_2

  sleep(3)

  job_transcode = Job_transcode.new
  job_transcode.start

end

def transcode_3

  sleep(4)

  job_transcode = Job_transcode.new
  job_transcode.start

end

def transcode_4

  sleep(5)

  job_transcode = Job_transcode.new
  job_transcode.start

end

prep_1 = Thread.new{file_prep}
transcode1 = Thread.new{transcode_1}
transcode2 = Thread.new{transcode_2}
transcode3 = Thread.new{transcode_3}
transcode4 = Thread.new{transcode_4}

prep_1.join
transcode1.join
transcode2.join
transcode3.join
transcode4.join





