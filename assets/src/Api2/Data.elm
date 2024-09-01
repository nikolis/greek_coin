module Api2.Data exposing (..)

import Json.Decode.Pipeline exposing (required, optional, hardcoded)
import Json.Decode exposing (list, string, Decoder, field, map5, decodeString, errorToString, nullable, float, int, dict, index, map3, map2, map4, nullable)
import Dict exposing (Dict)

type Status a
    = Loading
    | LoadingSlowly
    | Loaded a
    | Failed

   
type alias  Action =
    { title : String
    , id : Int
    }

type alias  Currency =
    { title : String
    , alias_ : String
    , id : Int
    , active : Bool
    , fee : Float
    , deposit_fee : Float
    , withdraw_fee : Float
    , active_deposit : Bool
    , active_withdraw : Bool
    , url : String
    , alias_sort : String
    , decimals : Int
    }

type alias Deposit = 
    {
       status: String
      , currency: Currency
      , id: Int
      , alias_: Maybe String
      , bankDetails : Maybe BankDetails
      , wallet : Maybe Wallet
      , updated_at : String
      , comment : Maybe String
    }

type alias Wallet = 
    {
        id: Int
      , public_key: String
    }

type alias Withdraw = 
    {
      ammount: Float
    , status:  String
    , id: Int
    , currency : Currency
    , bankAccountDetails : Maybe BankDetails
    , wallet : Maybe Wallet 
    , updated_at : String
    , comment : Maybe String
    }

type alias BankDetails =
    {
       recipientAddress : String
     , beneficiaryName : String
     , iban : String
     , swift_code : String
     , name : String
     , bankAddress : String
     , id : Int
    }

type alias  Country =
    { name : String
    , id : Int
    }

type alias AssetPair = 
    { name : String
    , info : AssetPairInfo
    }


type alias  AssetPairInfo = 
    { alternate_name : String
    , ws_name : String
    , base : String
    , quote : String
    , pairDecimal : Int
    }


type alias AssetMetaInfoUp = 
    { a : AskArray
    , b : BidArray
    , c : LastClosedTrade
    , v : List String
    , p : List String
    , t : NumberOfTrades
    , l : List String
    , h : List String
    , o : OpenPrice
    }

type alias AssetMetaInfo = 
    { a : AskArray
    , b : BidArray
    , c : LastClosedTrade
    , v : List String
    , p : List String
    , t : NumberOfTrades
    , l : List String
    , h : List String
    , o : OpenPrice
    }

type alias OpenPrice = 
    { last24h : Maybe String
    , today : String
    }

type alias AskArray = 
    { price : String
    , wLotVol : String
    , lotVol : String
    }

type alias BidArray = 
    { price : String
    , wLotVol : String
    , lotVol : String
    }

type alias LastClosedTrade = 
    { price : String
    , lotVol : String
    }


type alias NumberOfTrades = 
    { today : Int 
    , last24h : Int
    }

type alias Treasury =
    { currency: String
    , balance: Float
    }

type alias DataUpdate = 
    { numb : Int 
    , metaInf : AssetMetaInfoUp
    , apiStr : String
    , pair : String
    }

type alias TransactionRequest = 
    {
      exchangeRate: Float
    , id: Int
    , srcAmount: Float
    , status: String
    , tgtCurrency : Currency
    , srcCurrency : Currency
    , updatedAt : String
    , actionId : Int
    }

type alias User =
    { first_name:  String
    , last_name:  String
    , email : String
    , status:  String
    , idPickFront : String
    , idPickFrontComment : String
    , idPickBack : String
    , idPickBackComment :String
    , ofiBillFile : String
    , ofiBillFileComment : String
    , selfiePic : String
    , selfiePicComment : String
    , address:  Address
    , mobile: String
    , auth2fa: Bool 
    , clearanceLevel: Int
    }

decoderUser : Json.Decode.Decoder User
decoderUser =
    Json.Decode.succeed User
    |> Json.Decode.Pipeline.required "first_name" myNullable
    |> Json.Decode.Pipeline.required "last_name" myNullable
    |> Json.Decode.Pipeline.required "email" Json.Decode.string
    |> Json.Decode.Pipeline.required "status" myNullable
    |> Json.Decode.Pipeline.required "id_pic_front" myNullable
    |> Json.Decode.Pipeline.required "id_pic_front_comment" myNullable
    |> Json.Decode.Pipeline.required "id_pic_back" myNullable
    |> Json.Decode.Pipeline.required "id_pic_back_comment" myNullable
    |> Json.Decode.Pipeline.required "ofi_bill_file" myNullable
    |> Json.Decode.Pipeline.required "ofi_bill_file_comment" myNullable
    |> Json.Decode.Pipeline.required "selfie_pic" myNullable
    |> Json.Decode.Pipeline.required "selfie_pic_comment" myNullable
    |> Json.Decode.Pipeline.required "address" nullableAddress
    |> Json.Decode.Pipeline.required "mobile" myNullable
    |> Json.Decode.Pipeline.required "auth2fa"  Json.Decode.bool
    |> Json.Decode.Pipeline.required "clearance_level" Json.Decode.int

type alias Address =
    { city:  String
    , country:   String
    , address:   String
    , zip:  String
    }

myNullable :  Json.Decode.Decoder String
myNullable  =
    Json.Decode.oneOf
    [ Json.Decode.string
    , Json.Decode.null ""
    ]

nullableAddress : Json.Decode.Decoder Address
nullableAddress =
    Json.Decode.oneOf
    [ Json.Decode.null (Address "" "" "" "")
    , decoderAddress
    ]

decoderAddress : Json.Decode.Decoder Address
decoderAddress =
    Json.Decode.succeed Address
    |> Json.Decode.Pipeline.required "city" myNullable
    |> Json.Decode.Pipeline.required "country" myNullable
    |> Json.Decode.Pipeline.required "address" myNullable
    |> Json.Decode.Pipeline.required "zip" myNullable


type alias UserDeposits = 
    {
        data: List Deposit
    }

type alias BankResponse =
    {
        banks : List BankDetails
    }

type alias CurrencyResponse =    
   {
     currencies : List Currency 
   }

type alias WithdrawResponse =    
   {
     withdrawalls : List Withdraw
   }

type alias KrakenResponse =
   { errors : List String
   , assetPairs : Dict String AssetPairInfo
   }

type alias KrakenMetaResponse = 
    { errors : List String
    , assetInfo : Dict String AssetMetaInfo
    }

type alias ActionResponse =    
   {
     actions : List Action
   }


decoderActionResponse : Decoder ActionResponse
decoderActionResponse = 
    Json.Decode.succeed ActionResponse
      |> Json.Decode.Pipeline.required "data" (Json.Decode.list decoderAction)     

decoderAction : Decoder Action
decoderAction =
    Json.Decode.succeed Action      
      |> Json.Decode.Pipeline.required "title" string
      |> Json.Decode.Pipeline.required "id" int

decoderCurrency : Decoder Currency
decoderCurrency =
    Json.Decode.succeed Currency 
      |> Json.Decode.Pipeline.required "title" string
      |> optional "alias" string ""  
      |> Json.Decode.Pipeline.required "id" int
      |> Json.Decode.Pipeline.required "active" Json.Decode.bool
      |> Json.Decode.Pipeline.required "fee" float
      |> Json.Decode.Pipeline.required "deposit_fee" float
      |> Json.Decode.Pipeline.required "withdraw_fee" float
      |> Json.Decode.Pipeline.required "active_deposit" Json.Decode.bool
      |> Json.Decode.Pipeline.optional "active_withdraw" Json.Decode.bool False
      |> Json.Decode.Pipeline.optional "url" string "" 
      |> optional "alias_sort" string "Crypto"
      |> Json.Decode.Pipeline.required "decimals" int
      

decoderWallet : Decoder Wallet
decoderWallet = 
    Json.Decode.succeed Wallet
      |> Json.Decode.Pipeline.required "id" int
      |> Json.Decode.Pipeline.required "public_key" string

decoderBankResponse : Decoder BankResponse
decoderBankResponse =
    Json.Decode.succeed  BankResponse
      |> Json.Decode.Pipeline.required "data" (Json.Decode.list decoderBankDetails)

decoderBankDetails : Decoder BankDetails
decoderBankDetails =
    Json.Decode.succeed BankDetails
      |> Json.Decode.Pipeline.required "recipient_address" string
      |> Json.Decode.Pipeline.optional "beneficiary_name" string ""
      |> Json.Decode.Pipeline.required "iban" string
      |> Json.Decode.Pipeline.optional "swift_code" string ""
      |> Json.Decode.Pipeline.required "name" string
      |> Json.Decode.Pipeline.required "bank_address" string
      |> Json.Decode.Pipeline.required "id" int

decoderWithdraw : Decoder Withdraw
decoderWithdraw =
    Json.Decode.succeed Withdraw
      |> Json.Decode.Pipeline.required "ammount" float
      |> Json.Decode.Pipeline.required "status"  string
      |> Json.Decode.Pipeline.required "id" int
      |> Json.Decode.Pipeline.required "currency" decoderCurrency
      |> Json.Decode.Pipeline.required "user_bank_details" (nullable decoderBankDetails)
      |> Json.Decode.Pipeline.required "user_wallet" (nullable decoderWallet)
      |> Json.Decode.Pipeline.required "update_at" string
      |> Json.Decode.Pipeline.required "comment" (nullable string)

decoderWithdrawResponse : Decoder WithdrawResponse
decoderWithdrawResponse = 
    Json.Decode.succeed WithdrawResponse
      |> Json.Decode.Pipeline.required "data" (Json.Decode.list decoderWithdraw)     

decoderCountry : Decoder Country
decoderCountry =
    Json.Decode.succeed Country
      |> Json.Decode.Pipeline.required "name" string
      |> Json.Decode.Pipeline.required "id" int  
  
decoderCurrencyResponse : Decoder CurrencyResponse
decoderCurrencyResponse = 
    Json.Decode.succeed CurrencyResponse
      |> Json.Decode.Pipeline.required "data" (Json.Decode.list decoderCurrency) 



decoderPagination : Decoder Pagination 
decoderPagination = 
    Json.Decode.succeed Pagination
      |> Json.Decode.Pipeline.required "total_count" int  
      |> Json.Decode.Pipeline.required "total_pages" int  
      |> Json.Decode.Pipeline.required "per_page" int  
      |> Json.Decode.Pipeline.required "page" int  



type alias Pagination = 
    {
       total_count : Int
    ,  total_pages : Int
    ,  per_page : Int
    ,  page : Int
    }

depositDecoder : Json.Decode.Decoder Deposit
depositDecoder = 
    Json.Decode.succeed Deposit
      |> Json.Decode.Pipeline.required "status" string
      |> Json.Decode.Pipeline.required "currency" decoderCurrency
      |> Json.Decode.Pipeline.required "id" int
      |> Json.Decode.Pipeline.required "alias" (nullable string)
      |> Json.Decode.Pipeline.required "bank_details" (nullable decoderBankDetails) 
      |> Json.Decode.Pipeline.required "wallet" (nullable decoderWallet)
      |> Json.Decode.Pipeline.required "update_at" string
      |> Json.Decode.Pipeline.required "comment" (nullable string)


userDepositsDecoder : Json.Decode.Decoder UserDeposits
userDepositsDecoder = 
    Json.Decode.succeed UserDeposits
    |> Json.Decode.Pipeline.required "data" (Json.Decode.list depositDecoder)


type alias ExchangeRequestResponse = 
    {
      status : Int
    , token : String
    , transaction : TransactionRequest
    }

decoderExchangeRequestResponse : Decoder ExchangeRequestResponse 
decoderExchangeRequestResponse =
    Json.Decode.succeed ExchangeRequestResponse
    |> required "status" int
    |> required "token" string
    |> required "transaction" decoderTransaction

decoderTransaction : Json.Decode.Decoder TransactionRequest
decoderTransaction =
    Json.Decode.succeed TransactionRequest
      |> required "exchange_rate" float
      |> required "id" int
      |> required "src_amount" float
      |> required "status" string
      |> required "tgt_currency" decoderCurrency
      |> required "src_currency" decoderCurrency
      |> Json.Decode.Pipeline.required "update_at" string
      |> required "action_id" int


decoderAssetMetaInfoUp : Decoder AssetMetaInfoUp 
decoderAssetMetaInfoUp =
    Json.Decode.succeed AssetMetaInfoUp
    |> required "a" (Json.Decode.oneOf [askArrayDecoder, askArrayDecoderInt])
    |> required "b" (Json.Decode.oneOf [bidArrayDecoder, bidArrayDecoderInt])
    |> required "c" lastClosedTradeDecoder
    |> required "v" (list string)
    |> required "p" (list string)
    |> required "t" numberOfTradesDecoder
    |> required "l" (list string)
    |> required "h" (list string)
    |> required "o" (Json.Decode.oneOf [openPriceDecoder, openPriceDecoderSingl])


decoderKrakenMeta : Decoder KrakenMetaResponse 
decoderKrakenMeta = 
    Json.Decode.succeed KrakenMetaResponse
      |> required "error" (list string)
      |> required "result" (dict decoderAssetMetaInfo)


decoderKraken : Decoder KrakenResponse
decoderKraken = 
    Json.Decode.succeed KrakenResponse
      |> Json.Decode.Pipeline.required "error" (list string)
      |> Json.Decode.Pipeline.required "result" (dict decoderAssetPairInfo)  


decoderAssetMetaInfo : Decoder AssetMetaInfo 
decoderAssetMetaInfo =
    Json.Decode.succeed AssetMetaInfo
    |> required "a" (Json.Decode.oneOf [askArrayDecoder, askArrayDecoderInt]) 
    |> required "b" (Json.Decode.oneOf [bidArrayDecoder, bidArrayDecoderInt])
    |> required "c" lastClosedTradeDecoder
    |> required "v" (list string)
    |> required "p" (list string)
    |> required "t" numberOfTradesDecoder
    |> required "l" (list string)
    |> required "h" (list string)
    |> required "o" (Json.Decode.oneOf [openPriceDecoder, openPriceDecoderSingl])

decoderAssetPairInfo : Decoder AssetPairInfo
decoderAssetPairInfo = 
    Json.Decode.succeed AssetPairInfo 
      |> Json.Decode.Pipeline.required "altname" string 
      |> optional "wsname" string ""
      |> Json.Decode.Pipeline.required "base" string
      |> Json.Decode.Pipeline.required "quote" string
      |> Json.Decode.Pipeline.required "pair_decimals" int



askArrayDecoder : Decoder AskArray
askArrayDecoder = 
    map3 AskArray
        (index 0 string)
        (index 1 string)
        (index 2 string)


askArrayDecoderInt : Decoder AskArray
askArrayDecoderInt  =
    map3 (\a b c-> AskArray a (String.fromInt b) c)
        (index 0 string)
        (index 1 int)
        (index 2 string)

bidArrayDecoder : Decoder BidArray
bidArrayDecoder = 
    map3 AskArray
        (index 0 string)
        (index 1 string)
        (index 2 string)

bidArrayDecoderInt : Decoder BidArray 
bidArrayDecoderInt = 
    map3(\a b c -> BidArray a (String.fromInt b) c)
        (index 0 string)
        (index 1 int)
        (index 2 string)

lastClosedTradeDecoder : Decoder LastClosedTrade
lastClosedTradeDecoder = 
    map2 LastClosedTrade
        (index 0 string)
        (index 1 string)

numberOfTradesDecoder : Decoder NumberOfTrades
numberOfTradesDecoder = 
    map2 NumberOfTrades
        (index 0 int)
        (index 1 int)

dataDecoder : Decoder DataUpdate
dataDecoder = 
    map4 DataUpdate
        (index 0 int)
        (index 1 decoderAssetMetaInfoUp)
        (index 2 string)
        (index 3 string)


openPriceDecoder : Decoder OpenPrice
openPriceDecoder = 
    map2 OpenPrice
        (index 0 (nullable string))
        (index 1 string)

openPriceDecoderSingl : Decoder OpenPrice
openPriceDecoderSingl = 
    Json.Decode.map (OpenPrice Nothing)
        string

decoderUserFundBalance : Decoder UserFundBalance
decoderUserFundBalance =
    Json.Decode.succeed UserFundBalance
    |> required "funds" (list decoderTreasuryEntry)
    |> required "withdraws" (list decoderWithdraw)

decoderTreasuryEntry : Decoder Treasury
decoderTreasuryEntry = 
    Json.Decode.succeed Treasury
    |> required "currency" string
    |> required "balance" float

type alias UserFundBalance = 
    {
        funds:  List Treasury
    ,   withdraws: List Withdraw
    }


