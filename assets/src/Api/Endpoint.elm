module Api.Endpoint exposing (Endpoint, follow, login, profiles, request, tags, user, users, asset_pairs, kraken_meta_info, uploadImmageUrl, getViewUrl, fund_balance, userTransactions, craken_public_url, unwrap)

import CommentId exposing (CommentId)
import Http
import Url.Builder exposing (QueryParameter)
import Username exposing (Username)
import Http.Legacy
import Api2.Base exposing (baseUrl)
{-| Http.request, except it takes an Endpoint instead of a Url.
-}
request :
    { body : Http.Legacy.Body
    , expect : Http.Legacy.Expect a
    , headers : List Http.Legacy.Header
    , method : String
    , timeout : Maybe Float
    , url : Endpoint
    , withCredentials : Bool
    }
    -> Http.Legacy.Request a
request config =
    Http.Legacy.request
        { body = config.body
        , expect = config.expect
        , headers = config.headers
        , method = config.method
        , timeout = config.timeout
        , url = unwrap config.url
        , withCredentials = config.withCredentials
        }



-- TYPES


{-| Get a URL to the Conduit API.

This is not publicly exposed, because we want to make sure the only way to get one of these URLs is from this module.

-}
type Endpoint
    = Endpoint String


unwrap : Endpoint -> String
unwrap (Endpoint str) =
    str  


url : List String -> List QueryParameter -> Endpoint
url paths queryParams =
    -- NOTE: Url.Builder takes care of percent-encoding special URL characters.
    -- See https://package.elm-lang.org/packages/elm/url/latest/Url#percentEncode
    Url.Builder.crossOrigin "https://conduit.productionready.io"
        ("api" :: paths)
        queryParams
        |> Endpoint


url2 : List String -> List QueryParameter -> Endpoint
url2 paths queryParams = 
    Url.Builder.crossOrigin baseUrl
    ("api/v1" :: paths)
    queryParams
    |> Endpoint


kraken_local_url : List String -> List QueryParameter -> Endpoint 
kraken_local_url paths queryParams = 
    Url.Builder.crossOrigin baseUrl
    ("kraken" :: paths)
    queryParams
    |> Endpoint


craken_public_url : List String -> List QueryParameter -> Endpoint
craken_public_url  paths queryParams =
    Url.Builder.crossOrigin "https://api.kraken.com"
    ("0" :: paths)
    queryParams
    |> Endpoint

-- ENDPOINTS


login : Endpoint
login =
    url2 [ "users", "login" ] []


uploadImmageUrl : Endpoint
uploadImmageUrl  = 
    url2 [ "users", "immage"] []

getViewUrl : Endpoint
getViewUrl  = 
    url2 [ "users", "immage","view"] []


user : Endpoint
user =
    url2 [ "self" ] []


users : Endpoint
users =
    url2 [ "users" ] []

userTransactions : Endpoint
userTransactions =
    url2 [ "transaction" ,"user", "transactions"] []


follow : Username -> Endpoint
follow uname =
    url [ "profiles", Username.toString uname, "follow" ] []


-- ARTICLE ENDPOINTS
fund_balance : List QueryParameter  -> Endpoint
fund_balance parameters = 
   url2 ["transaction", "funds"] []

asset_pairs : Endpoint
asset_pairs = 
   kraken_local_url[ "krakenpairs/raw"] [] 

kraken_meta_info : List QueryParameter -> Endpoint
kraken_meta_info params= 
    craken_public_url["public", "Ticker"] params

profiles : Username -> Endpoint
profiles uname =
    url [ "profiles", Username.toString uname ] []


feed : List QueryParameter -> Endpoint
feed params =
    url [ "articles", "feed" ] params


tags : Endpoint
tags =
    url [ "tags" ] []
