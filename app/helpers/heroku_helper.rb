module HerokuHelper
  
  # Note that these are not fast requests -- seems like they typically take a few seconds.
  
  def heroku_connection
    Heroku::API.new(:api_key => ENV['HEROKU_API_KEY'])
  end
  
  def heroku_workers(heroku=heroku_connection)
    processes = heroku.get_ps('joslink').body
    processes.map {|p| {:process => p['process'], :elapsed => p['elapsed']} if p['process'] =~ /work/i}.compact
  end
  
  def heroku_add_worker(n=1)
    heroku_connection.post_ps_scale('joslink', 'worker', "+#{n}")
  end

  def heroku_set_workers(n=1)
    heroku_connection.post_ps_scale('joslink', 'worker', "#{n}")
  end

  def heroku_remove_worker(n=1)
    heroku_connection.post_ps_scale('joslink', 'worker', "-#{n}")
  end

  def heroku_remove_all_workers
    heroku_connection.post_ps_scale('joslink', 'worker', "0")
  end
        
end

    
