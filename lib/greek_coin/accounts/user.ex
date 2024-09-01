defmodule GreekCoin.Accounts.User do 
  use Ecto.Schema

  import Ecto.Changeset

  alias GreekCoin.Localization.Country
  alias GreekCoin.Accounts.Credential
  alias GreekCoin.Funds.Treasury 
  alias GreekCoin.Accounts.Address
  alias GreekCoin.Accounts.LoginAttempt 

  schema "users" do            
    
    field :user_name, :string     
    field :first_name, :string  
    field :last_name, :string  
    field :status, :string
    field :role, :string
    field :mobile, :string
    field :auth2fa, :boolean, default: false
    field :clearance_level, :integer, default: 0

    field :id_pic_front, :string
    field :id_pic_front_comment, :string
    field :id_pic_back, :string
    field :id_pic_back_comment, :string
    field :ofi_bill_file, :string
    field :ofi_bill_file_comment, :string
    field :selfie_pic, :string
    field :selfie_pic_comment, :string


    has_one :credential, Credential, on_replace: :delete
    has_many :withdrawalls, GreekCoin.Funds.Withdraw
    has_one :address , Address, on_replace: :update 
    belongs_to :country, Country
    has_many :treasuries, Treasury
    has_many :login_attempts, LoginAttempt

    timestamps()
  end


  def changeset(user, attrs) do
    user
    |> cast(attrs, [:user_name, :first_name, :last_name, :status, :mobile, :id_pic_front, :id_pic_front_comment, :id_pic_back, 
      :id_pic_back_comment, :ofi_bill_file, :ofi_bill_file_comment, :selfie_pic, :selfie_pic_comment, :country_id, :auth2fa, :clearance_level])
    |> cast_assoc(:address, with: &Address.changeset/2, required: false, on_replace: :update)
  end
    
  def registration_changeset(user, params) do
    user                       
    |> cast(params, [:user_name, :first_name, :last_name, :status, :country_id, :role, :clearance_level]) 
    |> cast_assoc(:credential, with: &Credential.changeset/2, required: false)
  end

  def admin_only_changeset(user, params) do
    user
    |> cast(params, [:user_name, :first_name, :last_name, :mobile, :id_pic_front, :id_pic_front_comment, :id_pic_back, 
      :id_pic_back_comment, :ofi_bill_file, :ofi_bill_file_comment, :selfie_pic, :selfie_pic_comment, :country_id, :auth2fa, :clearance_level, :role])
    |> cast_assoc(:address, with: &Address.changeset/2, required: false, on_replace: :update)
    |> cast_assoc(:credential, with: &Credential.changeset/2, required: false)

  end

end
