class User < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :password_digest
      t.string :password_confirmation
      t.string :email
      t.string :unconfirmed_email
      t.datetime :confirmed_at
      t.string :phone_number
      t.string :stripe_customer_id
      t.string :guid
      t.boolean :admin, default: false
      t.boolean :active, default: false
      t.text :password_reset_token
      t.datetime :password_reset_sent_at
      t.text :invitation_token
      t.datetime :invitation_sent_at
      t.datetime :invitation_accepted_at
      t.boolean :invitation_accepted
      t.string :uid
      t.string :provider
      t.string :avatar_url
      t.text :webauthn_id

      t.timestamps null: false
    end
  end
end
