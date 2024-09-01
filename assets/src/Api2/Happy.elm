module Api2.Happy exposing(..)

import Json.Encode as E
import Session exposing (Session)
import Api
import Http
import Http.Detailed
import Api2.Data exposing (..)
import Url.Builder
import Api.Endpoint as Endpoint
import Json.Decode exposing (dict, list, string, Decoder, field, map4, decodeString, errorToString, nullable, float, int, Value, decodeValue, at, index, map3, map2)
import Api2.Base exposing (baseUrl)

type ErrorDetailed
    = BadUrl String
    | Timeout
    | NetworkError
    | BadStatus Http.Metadata String
    | BadBody String

type DetailedError body
    = BadUrll String
    | Timeoutt  
    | NetworkErrorr                                                     
    | BadStatuss Http.Metadata body              
    | BadBodys Http.Metadata body String 

getBaseUrl : String
getBaseUrl =
    baseUrl


getMonetaryCurrencies2 : Session -> ((Result Http.Error (CurrencyResponse)) -> msg) -> Cmd msg
getMonetaryCurrencies2 session msg  =
    Http.request
    {
     headers =
         case Session.cred session of
             Just cred ->
                 [ Api.credHeader cred]
             Nothing ->
                 []
    , method = "GET"
    , body = Http.emptyBody
    , url = (getBaseUrl++"/kraken/monetary")
    , expect = Http.expectJson  {--CompletedMonetaryLoad--} msg decoderCurrencyResponse
    , timeout = Nothing
    , tracker = Nothing
    }

getActiveCurrencies2 : Session -> ((Result Http.Error (CurrencyResponse))-> msg)->Cmd msg
getActiveCurrencies2 session msg=
    Http.request
    {
     headers =
         case Session.cred session of
             Just cred ->
                 [ Api.credHeader cred]
             Nothing ->
                 []
    , method = "GET"
    , body = Http.emptyBody
    , url =  (getBaseUrl ++ "/kraken/krakenpairs")
    , expect = Http.expectJson  msg{--CompletedFeedLoad--} decoderCurrencyResponse
    , timeout = Nothing
    , tracker = Nothing
    }


getActions : Session -> ((Result Http.Error (ActionResponse)) -> msg) -> Cmd msg
getActions session msg=
    Http.request
    {
     headers =
         case Session.cred session of
             Just cred ->
                 [ Api.credHeader cred]
             Nothing ->
                 []
    , method = "GET"
    , body = Http.emptyBody
    , url = (getBaseUrl ++ "/kraken/actions")
    , expect = Http.expectJson  {--CompletedActionLoad--} msg decoderActionResponse
    , timeout = Nothing
    , tracker = Nothing
    }


exchangeRequest : Session -> Currency -> Currency -> Int -> Float -> Float -> Float ->((Result (DetailedError String) (Http.Metadata, ExchangeRequestResponse)) -> msg) -> String -> Cmd msg
exchangeRequest session  srcCur tgtCur action amount rate fee msg pair=     
    let
       body =
           encodeRequestTransaction srcCur.id tgtCur.id action amount rate fee pair
           |> Http.jsonBody
    in
    Http.request
    {
     headers =
         case Session.cred session of
             Just cred ->
                 [ Api.credHeader cred]      
             Nothing ->
                 []
    , method = "POST"
    , body = body
    , url = (getBaseUrl ++ "/api/v1/transaction/sellbuy")
    , expect = expectJson  msg decoderExchangeRequestResponse 
    , timeout = Nothing
    , tracker = Nothing
    }

exchangeRequestVerification : Session -> String ->((Result (DetailedError String) (Http.Metadata, ExchangeRequestResponse)) -> msg)  -> Cmd msg
exchangeRequestVerification session token msg=     
    let
       body =
              E.object
               [ ("token", E.string token)]

           |> Http.jsonBody
    in
    Http.request
    {
     headers =
         case Session.cred session of
             Just cred ->
                 [ Api.credHeader cred]      
             Nothing ->
                 []
    , method = "POST"
    , body = body
    , url = (getBaseUrl ++ "/api/v1/transaction/verify")
    , expect = expectJson  {--CompletedTransactionRequestSubmited--}msg decoderExchangeRequestResponse 
    , timeout = Nothing
    , tracker = Nothing
    }

responseToJson : Json.Decode.Decoder a -> Http.Response String -> Result (DetailedError String) ( Http.Metadata, a)
responseToJson decoder responseString =
    resolve
        (\( metadata, body ) ->
            Result.mapError Json.Decode.errorToString
                (Json.Decode.decodeString (Json.Decode.map (\res -> ( metadata, res )) decoder) body)
        )
        responseString

encodeRequestTransaction : Int -> Int -> Int -> Float -> Float -> Float -> String-> E.Value
encodeRequestTransaction srcCur tgtCur actId  ammount rate fee pair= 
   E.object
   [ ("request_transaction", E.object
    [ ("src_currency_id", E.int srcCur)
    , ("tgt_currency_id", E.int tgtCur)
    , ("action_id", E.int actId)
    , ("src_amount", E.float ammount)
    , ("exchange_rate", E.float rate)
    , ("fee", E.float fee)
    , ("pair", E.string pair)
    ]
  )]

expectJson : (Result (DetailedError String) ( Http.Metadata, a ) -> msg) -> Json.Decode.Decoder a -> Http.Expect msg
expectJson toMsg decoder =
    Http.expectStringResponse toMsg (responseToJson decoder)

resolve : (( Http.Metadata, body ) -> Result String a) -> Http.Response body -> Result (DetailedError body) a
resolve toResult response =
    case response of
        Http.BadUrl_ url ->
            Err (BadUrll url)

        Http.Timeout_ ->
            Err Timeoutt

        Http.NetworkError_ ->
            Err NetworkErrorr

        Http.BadStatus_ metadata body ->
            Err (BadStatuss metadata body)

        Http.GoodStatus_ metadata body ->
            Result.mapError (BadBodys metadata body) (toResult ( metadata, body ))


fetchMetaInfoGroupCsv :  String -> (Result Http.Error KrakenMetaResponse -> msg) ->Cmd msg
fetchMetaInfoGroupCsv   pairs msg= 
    let
        paths = ["public","Ticker"]
        query =  [(Url.Builder.string "pair"  pairs)]
        endpoint = Endpoint.craken_public_url paths query
    in
    Http.request
    {
     headers = []
    , method = "GET"
    , body = Http.emptyBody
    , url =   (Endpoint.unwrap endpoint)
    , expect = Http.expectJson  {--GetMetaInfoGroup--}msg decoderKrakenMeta
    , timeout = Nothing
    , tracker = Nothing
    }

currenciesToCsvPairs : List Currency -> String
currenciesToCsvPairs currencies =
    let
        cnct =
            \new exist ->
               case String.slice 0 1 new.title of
                   "X" ->
                     exist++ ","++ (new.title ++ "ZEUR")
                   _ ->
                     exist++ ","++ (new.title ++ "EUR")
    in
  List.foldr cnct "XXBTZEUR" currencies 

fetchMetaInfoGroup : List Currency -> (Result Http.Error KrakenMetaResponse -> msg) ->Cmd msg
fetchMetaInfoGroup   currencies msg= 
    let
        paths = ["public","Ticker"]
        currenciesCs = currenciesToCsvPairs currencies
        query =  [(Url.Builder.string "pair"  currenciesCs)]
        endpoint = Endpoint.craken_public_url paths query
    in
    Http.request
    {
     headers = []
    , method = "GET"
    , body = Http.emptyBody
    , url =   (Endpoint.unwrap endpoint)
    , expect = Http.expectJson  {--GetMetaInfoGroup--}msg decoderKrakenMeta
    , timeout = Nothing
    , tracker = Nothing
    }

fetchMetaInfo2 :  String -> (Result Http.Error KrakenMetaResponse -> msg) -> Cmd msg
fetchMetaInfo2   assetPair msg= 
    Http.request
    {
     headers = []
    , method = "GET"
    , body = Http.emptyBody
    , url = "https://api.kraken.com/public/Ticker" ++ (Url.Builder.toQuery ([Url.Builder.string "pair" assetPair]))
    , expect = Http.expectJson  {-- GetMetaInfo --} msg decoderKrakenMeta
    , timeout = Nothing
    , tracker = Nothing
    }


getAvailableBanks : Session -> ((Result Http.Error (BankResponse)) -> msg) -> Cmd msg
getAvailableBanks session msg =
    Http.request
    {
     headers =
         case Session.cred session of
             Just cred ->
                 [ Api.credHeader cred]
             Nothing ->
                 []
    , method = "GET"
    , body = Http.emptyBody
    , url = (getBaseUrl ++ "/api/v1/users/available/banks")
    , expect = Http.expectJson  msg decoderBankResponse
    , timeout = Nothing
    , tracker = Nothing
    }

getMonetaryCurrencies : Session -> ((Result Http.Error (CurrencyResponse)) -> msg) -> Cmd msg
getMonetaryCurrencies session msg =
    Http.request
    {
     headers =
         case Session.cred (session) of
             Just cred ->
                 [ Api.credHeader cred]
             Nothing ->
                 []
    , method = "GET"
    , body = Http.emptyBody
    , url =  (getBaseUrl ++ "/kraken/currencies/all")
    , expect = Http.expectJson  msg decoderCurrencyResponse
    , timeout = Nothing
    , tracker = Nothing
    }


getActiveCurrencies :Session -> ((Result Http.Error (CurrencyResponse)) -> msg)->Cmd msg
getActiveCurrencies session  msg=
    Http.request
    {
     headers =
         case Session.cred session of
             Just cred ->
                 [ Api.credHeader cred]
             Nothing ->
                 []
    , method = "GET"
    , body = Http.emptyBody
    , url = (getBaseUrl ++ "/kraken/currencies/all")
    , expect = Http.expectJson  msg decoderCurrencyResponse
    , timeout = Nothing
    , tracker = Nothing
    }

getDepositRequest : Session -> ((Result Http.Error (UserDeposits)) -> msg) -> Cmd msg
getDepositRequest session msg=    
    Http.request               
    {
     headers =                 
         case Session.cred session of
             Just cred ->      
                 [ Api.credHeader cred]      
             Nothing ->
                 []            
    , method = "GET"           
    , body = Http.emptyBody    
    , url = (getBaseUrl ++ "/api/v1/transaction/user/deposit")
    , expect = Http.expectJson  msg userDepositsDecoder
    , timeout = Nothing        
    , tracker = Nothing        
    }

simpleIdEnc : Float -> Currency -> String ->E.Value
simpleIdEnc ammount currency  bankId=
    E.object
        [ ( "deposit",  (encodeDeposit ammount currency bankId) )
        ]

encodeDeposit : Float -> Currency -> String  -> E.Value
encodeDeposit ammount currency bankId = 
    E.object 
      [
        ( "currency_id", E.int currency.id)
      , ( "ammount", E.float ammount)
      , ( "bank_details_id", E.string bankId)
      ]


simpleIdEnc2 : Float -> Currency  ->E.Value
simpleIdEnc2 ammount currency =
    E.object
        [ ( "deposit",  (encodeDeposit2 ammount currency) )
        ]

encodeDeposit2 : Float -> Currency  -> E.Value
encodeDeposit2 ammount currency = 
    E.object 
      [
        ( "currency_id", E.int currency.id),
        ( "ammount", E.float ammount)
      ]


createDepositRequest : Session -> ((Result (Http.Detailed.Error String) ( Http.Metadata, Deposit )) ->msg) ->Float -> Currency -> Maybe String -> Cmd msg
createDepositRequest session msg ammount currency bankIdM=     
    let
       body =
           case bankIdM of
               Just bankId ->
                   simpleIdEnc ammount currency bankId
                   |> Http.jsonBody

               Nothing ->
                   simpleIdEnc2 ammount currency
                   |> Http.jsonBody

    in
    Http.request
    {
     headers =
         case Session.cred (session) of
             Just cred ->
                 [ Api.credHeader cred]      
             Nothing ->
                 []
    , method = "POST"
    , body = body
    , url = (getBaseUrl ++ "/api/v1/transaction/deposit")
    , expect = Http.Detailed.expectJson  msg depositDecoder
    , timeout = Nothing
    , tracker = Nothing
    }
