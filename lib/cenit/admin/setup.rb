module Cenit
  module Admin

    DEFAULT_URI = 'http://localhost:3000'

    setup do
      app = self.app
      config = app.configuration
      redirect_uris = config.redirect_uris || []
      unless redirect_uris.include?(DEFAULT_URI)
        redirect_uris << DEFAULT_URI
        config.redirect_uris = redirect_uris
        app.save
      end
    end
  end
end