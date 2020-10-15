module Cenit
  module Admin

    document_type :Config do

      belongs_to :user, class_name: User.name, inverse_of: nil
      belongs_to :tenant, class_name: Tenant.name, inverse_of: nil

      field :data, type: Hash, default: {
        "subjects": {
          "Menu": {
            "type": "Menu",
            "key": "Menu"
          }
        },
        "tabs": [
          "Menu"
        ],
        "tabIndex": 0,
        "navigation": [
          {
            "key": "Menu"
          }
        ]
      }
    end
  end
end