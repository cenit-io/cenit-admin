require 'cenit/admin/version'

module Cenit
  module Admin
    include BuildInApps

    app_name 'Cenit Admin'

    app_key 'admin'

  end
end

require 'cenit/admin/controller'
require 'cenit/admin/code'
require 'cenit/admin/config'
require 'cenit/admin/setup'
