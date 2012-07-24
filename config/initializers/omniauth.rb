Rails.application.config.middleware.use OmniAuth::Builder do

  provider :github, '770dd04ac1351df0e14b', '95e7076294ad1c6a08e47adb4d42df07d3edfd3d', scope: 'user'
  #provider :twitter, "xTAwY5XFfMYLPq5xR7IzA", "Q8v9UVQS5vYU2lhe3nFB8i534JY0p9rWPynW7zt0I"

  OmniAuth.config.on_failure = Proc.new do |env|
    new_path = "/auth/failure"
    [302, {'Location' => new_path, 'Content-Type'=> 'text/html'}, []]
  end

end

