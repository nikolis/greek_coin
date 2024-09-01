module Api.Data exposing (KrakenResponse, KrakenMetaResponse, AssetPairInfo, AssetMetaInfo, decoderAssetMetaInfoUp, decoderAssetMetaInfo, decoderKrakenMeta, UserFundBalance, decoderUserFundBalance, Treasury, decoderAssetPairInfo, AssetMetaInfoUp, AssetPair, AskArray, BidArray, LastClosedTrade, OpenPrice, NumberOfTrades, dataDecoder, decoderKraken)

import Dict exposing (Dict)
import Json.Decode exposing (dict, list, string, Decoder, field, map4, decodeString, errorToString, nullable, float, int, Value, decodeValue, at, index, map3, map2)
import Json.Decode.Pipeline exposing (required, optional, hardcoded)
import Dict exposing (Dict)

type alias KrakenResponse =
   { errors : List String
   , assetPairs : Dict String AssetPairInfo
   }

type alias KrakenMetaResponse = 
    { errors : List String
    , assetInfo : Dict String AssetMetaInfo
    }

type alias UserFundBalance = 
    {
        funds:  List Treasury
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


decoderAssetPairInfo : Decoder AssetPairInfo
decoderAssetPairInfo = 
    Json.Decode.succeed AssetPairInfo 
      |> Json.Decode.Pipeline.required "altname" string 
      |> optional "wsname" string ""
      |> Json.Decode.Pipeline.required "base" string
      |> Json.Decode.Pipeline.required "quote" string


decoderUserFundBalance : Decoder UserFundBalance
decoderUserFundBalance =
    Json.Decode.succeed UserFundBalance
    |> required "funds" (list decoderTreasuryEntry)

decoderTreasuryEntry : Decoder Treasury
decoderTreasuryEntry = 
    Json.Decode.succeed Treasury
    |> required "currency" string
    |> required "balance" float


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


listCreate : String -> Int -> String -> List String
listCreate a b c =
   [ a, (String.fromInt b), c] 


stringIntDecoder : Decoder (List String)
stringIntDecoder = 
    map3 listCreate 
       (index 0 string)
       (index 1 int)
       (index 2 string)
      
openPriceDecoder : Decoder OpenPrice
openPriceDecoder = 
    map2 OpenPrice
        (index 0 (nullable string))
        (index 1 string)

openPriceDecoderSingl : Decoder OpenPrice
openPriceDecoderSingl = 
    Json.Decode.map (OpenPrice Nothing)
        string

