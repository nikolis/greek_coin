defmodule GreekCoin.Security do

  @aws_key_id  "AKIA4Z4GRTRXJ73CBUXC"
  @aws_secret_key "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"
  @aws_region  "eu-central-1"
  @authorization "AWS4-HMAC-SHA256" 
  @request "aws4_request"
  @service "s3"
  @valid_period "604799"

  def uri_encode(input) do
    String.replace(input, "/", "%2F")
  end
  
  def hex_sha_canonical_request_uri(path) do
    can_req = canonical_request_uri(path)
    :crypto.hash(:sha256,can_req)
    |> Base.encode16
    |> String.downcase
  end

  def get_image_presigned_uri(path) do
    "https://greekcoinuserimages.s3.amazonaws.com/"<>path
    <>"?X-Amz-Algorithm=AWS4-HMAC-SHA256&"
    <>"X-Amz-Credential="<>@aws_key_id<>uri_encode("/")<>current_date()<>uri_encode("/")<>@aws_region<>uri_encode("/")<>@service<>uri_encode("/")<>@request
    <>"&X-Amz-Date="<>date_time_aws_8601()<>"&X-Amz-Expires="<>@valid_period<>"&X-Amz-SignedHeaders=host"
    <>"&X-Amz-Signature="<>signature_uri(path)
  
  end
  
  def signature_uri(path) do
    key = signing_key()
    str = string_to_sign_uri(path)
    :crypto.hmac(:sha256,  key, str)
    |> Base.encode16()
    |> String.downcase()
  end
 
  def string_to_sign_uri(path) do
    @authorization<> "\n"<>
    date_time_aws_8601() <> "\n" <>
    scope() <> "\n"<>
    hex_sha_canonical_request_uri(path)
  end
  

  def canonical_request_uri(path) do
    "GET\n" <>
      "/"<>path <> "\n"<>
        canonical_uri_parameters()<>"\n"<>
    canonical_headers(temp_headers_uri)<>"\n\n"<>
    signed_headers(temp_headers_uri)<>"\n"<>
    "UNSIGNED-PAYLOAD" 
  end 

  def canonical_uri_parameters() do
    "X-Amz-Algorithm=AWS4-HMAC-SHA256&"
    <>"X-Amz-Credential="<>@aws_key_id<>uri_encode("/")<>current_date()<>uri_encode("/")<>@aws_region<>uri_encode("/")<>@service<>uri_encode("/")<>@request
    <>"&X-Amz-Date="<>date_time_aws_8601()<>"&X-Amz-Expires="<>@valid_period<>"&X-Amz-SignedHeaders=host"
  end

  
  def temp_headers_uri() do
    [
      {"host", "greekcoinuserimages.s3.amazonaws.com"}
    ]
  end

  def temp_headers_real(date_time) do
    [
      {"host", "greekcoinuserimages.s3.amazonaws.com"},
      {"x-amz-content-sha256","e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},
      {"x-amz-date", date_time},
      {"content-type", "application/x-www-form-urlencoded"}
    ] 
  end

  def temp_headers_real_upload(date_time, file_hash) do
    [
      {"host", "greekcoinuserimages.s3.amazonaws.com"},
      {"x-amz-content-sha256", String.downcase(file_hash)},
      {"x-amz-date", date_time},
      {"content-type", "application/x-www-form-urlencoded"}
    ] 
  end
  
  def read_the_file(file_name) do
    bytes = elem(File.read(file_name),1)
    :crypto.hash(:sha256, bytes) 
  end
  
  def get_authorization_header_upload(path, file_hash) do
    #file_hash = read_the_file(file)
    dt=date_time_aws_8601()
    headers = temp_headers_real_upload(dt, file_hash)
    string_to= string_to_sign_upload(path, headers, file_hash, dt)
    req_sig = signature(string_to)
    auth_header = 
    @authorization<>" "<>"Credential="<>@aws_key_id<>"/"<>current_date()<>"/"<>
    @aws_region<>"/"<>"s3/"<>@request<>",SignedHeaders="<>signed_headers(headers)<>",Signature="<>req_sig
    %{auth_header: auth_header,
      date: dt,
      path: path,
      hash: file_hash}  
  end


  def get_authorization_header(path, payload) do
    dt=date_time_aws_8601()
    headers = temp_headers_real(dt)
    string_to= string_to_sign(path, headers, payload, dt)
    req_sig = signature(string_to)
    @authorization<>" "<>"Credential="<>@aws_key_id<>"/"<>current_date()<>"/"<>
    @aws_region<>"/"<>"s3/"<>@request<>",SignedHeaders="<>signed_headers(headers)<>",Signature="<>req_sig
  end
  
  def string_to_sign_upload(path, headers, hashed_payload, date_use) do
    @authorization<> "\n"<>
    date_use <> "\n" <>
    scope() <> "\n"<>
    hex_sha_canonical_request_upload(path, headers, hashed_payload)
  end
 

  def string_to_sign(path, headers, payload, date_use) do
    @authorization<> "\n"<>
    date_use <> "\n" <>
    scope() <> "\n"<>
    hex_sha_canonical_request(path, headers, payload)
  end
  
  def hex_sha_canonical_request_upload(path, headers, payload) do
    can_req = canonical_request_upload(path, headers, payload)
    :crypto.hash(:sha256,can_req)
    |> Base.encode16
    |> String.downcase
  end


  def hex_sha_canonical_request(path, headers, payload) do
    can_req = canonical_request(path, headers, payload)
    :crypto.hash(:sha256,can_req)
    |> Base.encode16
    |> String.downcase
  end

  def canonical_request_upload(path, headers, hashed_payload) do
    "PUT\n" <>
      path <> "\n"<>
        ""<>"\n"<>
    canonical_headers(headers)<>"\n\n"<>
    signed_headers(headers)<>"\n"<>
    hashed_payload 
  end 
  
  def canonical_request(path, headers, payload) do
    "GET\n" <>
      path <> "\n"<>
        ""<>"\n"<>
    canonical_headers(headers)<>"\n\n"<>
    signed_headers(headers)<>"\n"<>
    hashed_payload(payload) 
  end 


  def canonical_headers(the_list) do
    the_list
    |> List.keysort(0)
    |> Enum.reverse
    |> Enum.map(fn x -> String.downcase(elem(x,0)) <>":" <> String.trim(elem(x,1))end)
    |> Enum.reduce( fn y, acc -> y <> "\n" <> acc end) 
  end

  
  def signed_headers(the_list) do
    the_list
    |> List.keysort(0)
    |> Enum.reverse
    |> Enum.map(fn y -> elem(y, 0)end)
    |> Enum.reduce(fn x, acc -> x <> ";"<> acc end)
  end

  
  def hashed_payload(payload) do
    res =
    if String.length(payload) == 0 do
      :crypto.hash(:sha256,"")
    else 
      bytes = elem(File.read(payload),1)
      :crypto.hash(:sha256, bytes)
    end
    res
    |> Base.encode16
    |> String.downcase
  end


  def scope() do
    current_date() <>"/"<> @aws_region <> "/s3" <> "/aws4_request"
  end

  
  def date_time_aws_8601() do
    date_str = DateTime.to_iso8601(DateTime.truncate(DateTime.utc_now, :second))
    date_str = String.replace(date_str, "-", "")
    date_str = String.replace(date_str, ":", "")
    date_str
  end

  def signature(string_to_sign) do
    key = signing_key()
    :crypto.hmac(:sha256,  key, string_to_sign)
    |> Base.encode16()
    |> String.downcase()
  end
  
  def signing_key() do
    key = "AWS4"<>@aws_secret_key
    k_date = :crypto.hmac(:sha256, key, current_date())
    k_region = :crypto.hmac(:sha256, k_date, @aws_region)
    k_service = :crypto.hmac(:sha256, k_region, @service)
    :crypto.hmac(:sha256, k_service, @request)
  end


  def exmple_string_to_sign() do
    """
    AWS4-HMAC-SHA256
    20130524T000000Z
    20130524/us-east-1/s3/aws4_request
    7344ae5b7ee6c3e7e6b0fe0640412a37625d1fbfff95c48bbb2dc43964946972
    """
    end

  def current_date() do
    Date.utc_today
    |> Date.to_string
    |> String.replace("-","")
  end

end
