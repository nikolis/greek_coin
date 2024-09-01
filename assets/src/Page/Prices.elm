port module Page.Prices exposing (Model, Msg, init, subscriptions, toSession, update, view)

{-| The homepage. You can get here via either the / or /#/ routes.
-}

import Api exposing (Cred)
import Api.Endpoint as Endpoint
import Browser.Dom as Dom
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (attribute, class, scope, disabled, style, href)
import Http
import Loading
import Log
import Page
import Session exposing (Session)
import Task exposing (Task)
import Time
import Url.Builder
import Username exposing (Username)
import Json.Decode exposing (dict, list, string, Decoder, field, map4, decodeString, errorToString, nullable, float, int, Value, decodeValue, at, index, map3, map2)
import Json.Decode.Pipeline exposing (optional, hardcoded)
import Dict exposing (Dict)
import Paginate exposing (..)
import Json.Encode as E
import Http.Legacy
import Page.Home.Naview as Nav
import Svg exposing (svg, rect)
import Svg.Attributes
import Api2.Data exposing (Currency, decoderCurrency, CurrencyResponse, decoderCurrencyResponse, Action, ActionResponse, decoderActionResponse, KrakenResponse, KrakenMetaResponse, decoderKrakenMeta, AssetMetaInfo, AssetPairInfo, dataDecoder, decoderKraken, ExchangeRequestResponse, TransactionRequest)
import Api2.Happy exposing (fetchMetaInfoGroup, fetchMetaInfo2, DetailedError(..), exchangeRequest, getActions, getActiveCurrencies2, getMonetaryCurrencies2, fetchMetaInfoGroupCsv, exchangeRequestVerification, getBaseUrl) 
import Page.Home.Packages as PackagesP
import Page.Exchange.Transactions as TransactionsP
import Page.Exchange.TransactionsView as TransView

import Round

port send : E.Value -> Cmd msg
port receive : (E.Value -> msg) -> Sub msg

type alias AssetPairCurrency =
    {
        alternateName : String
    ,   primaryName : String
    ,   wsName : String
    ,   base : Currency
    ,   quote : Currency
    ,   decimals : Int
    }


-- MODEL
encode : RegisterTopic -> E.Value
encode reTo = 
    E.object
    [ ("event", E.string reTo.event)
    , ("pair", (E.list E.string) reTo.pair)
    , ("subscription", E.dict (\top -> top) E.string  reTo.subscription)
    ]


type alias RegisterTopic = 
    { event : String
    , pair : List String
    , subscription : Dict String String
    }
        

type alias Model =
    { session : Session
    , timeZone : Time.Zone
    , modelTransaction : TransactionsP.Model
    , priceInfo : Maybe AssetMetaInfo
    , assetPairs :  Maybe (Dict String Api2.Data.AssetPairInfo) 
    , feed : Status CurrencyResponse
    , feedMeta : Maybe (Dict String AssetMetaInfo)
    , tradablePairs : Status (Dict String AssetPairInfo)
    , assetPairsCurr : Status (List AssetPairCurrency)
    , packagesModel : PackagesP.Model
    }

init : Session -> ( Model, Cmd Msg )
init session =
    let
        (modelTransactions, cmdsTr) = TransactionsP.init session Nothing
        (modelPackages, cmdsPackages) = PackagesP.init session

        md = 
         { session = session
         , feed = Loading
         , feedMeta = Nothing
         , assetPairs = Nothing
         , priceInfo = Nothing
         , tradablePairs = Loading
         , assetPairsCurr = Loading
         , timeZone = Time.utc
         , modelTransaction = modelTransactions
         , packagesModel = modelPackages
         }
    in
    ( md
    , Cmd.batch
        [ Task.perform GotTimeZone Time.here
        , Task.perform (\_ -> PassedSlowLoadThreshold) Loading.slowThreshold
        , Cmd.map (\serCom -> (TransactionsMsg serCom)) cmdsTr
        , getActiveCurrencies2 md.session CompletedFeedLoad
        ]
    )

type Status a
    = Loading
    | LoadingSlowly
    | Loaded a
    | Failed


getTradableAssetPairs :  Cmd Msg
getTradableAssetPairs =
    Http.request
    {
     headers = []
    , method = "GET"
    , body = Http.emptyBody
    , url = (getBaseUrl ++ "/kraken/krakenpairs/raw")
    , expect = Http.expectJson TradablePairs decoderKraken
    , timeout = Nothing
    , tracker = Nothing
    }

-- VIEW

view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Prices"
    , content =
        div [ class "" ]
            [
              div[ style "margin-left" "-15px",style "background-image" "url(\"images/crupto_2.png\")", style "background-repeat" "no-repeat", style "background-size" "cover", style "margin-top" "-5px", style "padding-right" "100px"]
              [
               div[class "col", style "margin-right" "10vw"]
               [
                Nav.naview model.session 2
               ]
           , div[class "row justify-content-center"]
             [
                 div[class "col-xxl-4 col-md-6 col-lg-4 col-xl-3 col-sm-12 col-xs-12 "]
                 [
                   span[style "font-size" "3rem", style "font-weight" "bold", style "color""white"][text "Prices"]
                 , br[][]
                 , span[style "font-size" "2rem", style "color" "rgba(255,158,46,1)"][text "Buy, Sell and Exchange"]
                 , br[][]
                 , span[style "font-size" "2rem", style "color" "rgba(255,158,46,1)"][text "Cryptocurrencies"]
                 , br[][]
                 , svg[style "margin-top" "3vh"]
                   [
                     rect
                     [ Svg.Attributes.fill "rgba(255,158,46,1)"
                     , Svg.Attributes.rx "7"
                     , Svg.Attributes.ry "7"
                     , Svg.Attributes.x "0"
                     , Svg.Attributes.y "0"
                     , Svg.Attributes.width "125"
                     , Svg.Attributes.height "14"
                     ][]
                   ] 
                 ]
               , div[class "col-xxl-4 col-md-8 col-lg-5 col-xl-4 col-sm-12 col-xs-12", style "margin-top" "6vh"][ Html.map(\transMsg -> TransactionsMsg transMsg) (TransView.view model.modelTransaction TransactionsP.LoginMode)]
               , div[class "col-xl-2"] []
           ]
         ]
         ,   Html.map(\transMsg -> TransactionsMsg transMsg) (TransView.viewPackages model.modelTransaction TransactionsP.LoginMode)
         , div[class "row", style "margin-top" "100px"]
           [
              {--pricesTable model.assetPairsCurr model--}
             Html.map(\transMsg -> TransactionsMsg transMsg) (TransView.pricesTableExpanded  model.modelTransaction 5)

           ]
         , div[class "row", style "margin-bottom" "10vh"]
           (List.map(\arg -> Html.map(\packMsg -> PackageMsg packMsg) arg) (PackagesP.viewGettingStarted))
           {--(Html.map(\packMsg -> PackageMsg packMsg) (PackagesP.viewGettingStarted))--}
           
       ]
    }


-- UPDATE


type Msg =
     GotTimeZone Time.Zone
    | GotSession Session
    | PassedSlowLoadThreshold
    | Receive Value
    | TransactionsMsg TransactionsP.Msg
    | CompletedFeedLoad (Result Http.Error (CurrencyResponse))
    | TradablePairs (Result Http.Error (KrakenResponse))
    | GetMetaInfoGroup (Result Http.Error (KrakenMetaResponse))
    | PackageMsg PackagesP.Msg 

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetMetaInfoGroup (Ok krakenResponse) ->
            case model.feed of
                Loaded feedPairs ->
                    let
                        packMo = model.packagesModel 
                        packMoNew = {packMo | feedMeta = Just krakenResponse.assetInfo}
                    in
                    ({model | feedMeta = Just krakenResponse.assetInfo, packagesModel = packMoNew}, Cmd.none)
                _ ->
                    let
                        packMo = model.packagesModel 
                        packMoNew = {packMo | feedMeta = Just krakenResponse.assetInfo}
                    in  
                    ({model | feedMeta = Just krakenResponse.assetInfo, packagesModel = packMoNew}, Cmd.none)


        GetMetaInfoGroup (Err error) ->
            ( model, Cmd.none)

        PackageMsg servMsg ->
           let
               (serM, comSer) = PackagesP.update  servMsg model.packagesModel
           in
           ({model |packagesModel  = serM}, Cmd.map (\serCom -> (PackageMsg serCom)) comSer)

        TransactionsMsg transMsg ->
           let
               (transM, comTrans) = TransactionsP.update transMsg model.modelTransaction
           in
           ({model | modelTransaction = transM}, Cmd.map(\transCom -> (TransactionsMsg transCom)) comTrans) 

        GotTimeZone tz ->
            ( { model | timeZone = tz }, Cmd.none )

        GotSession session ->
            ( { model | session = session }, Cmd.none )

        PassedSlowLoadThreshold ->
            (model, Cmd.none)

        CompletedFeedLoad (Ok feed) ->
            ( { model | feed = Loaded feed }
              ,
               Cmd.batch[
                 getTradableAssetPairs
               {--, sendSubscribeMessage  feed.currencies--}
              ]
            )

        CompletedFeedLoad (Err error) ->
            ( { model | feed = Failed }, Cmd.none )

        Receive value ->
            let
                decodedMessage = decodeValue dataDecoder value
            in
            case decodedMessage of
                Ok data ->
                    case model.feedMeta of
                        Just dictMeta ->
                            let
                                the_list = String.split "/" data.pair
                                get_val = getValOfList the_list
                                name =
                                  case get_val of
                                    Just content ->
                                       let
                                         (a, b) = content
                                       in
                                       (("X"++a) ++ ("Z" ++b))

                                    Nothing ->
                                      ""
                                newFeedMeta = Dict.insert name data.metaInf dictMeta
                                packModel = model.packagesModel
                                packModelNew = { packModel | feedMeta = Just newFeedMeta}
                                md = {model | feedMeta = Just newFeedMeta , packagesModel = packModelNew }
                            in
                         (md, Cmd.none)
                        Nothing ->
                            (model, Cmd.none)

                Err error ->
                    (model, Cmd.none)

        TradablePairs (Ok resp) ->
          case model.feed of
               Loaded curResp ->
                 let
                    md = { model | tradablePairs = Loaded resp.assetPairs}
                    listOfAssetPairs = Dict.toList resp.assetPairs
                    listFilter = List.filter (\(name, assetPair) -> ( 
                        (List.any (\curr -> curr.title == assetPair.base) curResp.currencies ) 
                        &&  (List.any (\curr -> curr.title == assetPair.quote) curResp.currencies) )
                        ) listOfAssetPairs

                    assetPairCurrPre= listFrom  listFilter curResp.currencies
                    assetPairCurr = List.filter (\assetPair -> not (String.contains ".d" assetPair.alternateName )) assetPairCurrPre
                    csvPairs = List.foldr (\pair preb -> pair.alternateName ++ "," ++preb) "" assetPairCurr 
                    theStringFinal = String.slice 0 ((String.length csvPairs)-1) csvPairs 
                    listOfStringForSub = List.map (\apcr -> apcr.wsName ) assetPairCurr 
                    packModel = model.packagesModel
                    (transModelNew, cmdsT) = TransactionsP.update(TransactionsP.GotAssetPairCurr  assetPairCurr) model.modelTransaction
                    (packModelNew, cmds) = PackagesP.update (PackagesP.GotAssetPairCurrs assetPairCurr) model.packagesModel
                 in
                 ({model |  assetPairsCurr = Loaded assetPairCurr, packagesModel = packModelNew, modelTransaction = transModelNew}, Cmd.batch [fetchMetaInfoGroupCsv theStringFinal GetMetaInfoGroup, sendSubscribeMessageString listOfStringForSub ])
               _ ->
                ({model | tradablePairs = Loaded resp.assetPairs}, Cmd.none)

        TradablePairs (Err httpErr) ->
           (model, Cmd.none)

listFrom : List (String, AssetPairInfo) -> List Currency -> List AssetPairCurrency
listFrom  asetPairs currencies =
    let
        someList = List.map (\(name, assetPair) ->  
            case listOfAssetPair2listOfAssetPairCurr  assetPair  currencies of
                (Just curr, Just curr2) ->
                    Just (AssetPairCurrency assetPair.alternate_name name assetPair.ws_name curr curr2 assetPair.pairDecimal)
                (_ , _) ->
                    Nothing
         ) asetPairs

        filteredList = List.filterMap (\pair -> 
             case pair of
                 Just sthing ->
                     Just sthing
                 Nothing ->
                     Nothing
         ) someList
    in
    filteredList
   
getValOfList : List String -> Maybe (String, String) 
getValOfList theList =
  let
    first = List.head theList 
  in
  case List.tail theList of
     Just secList ->
         let
             second = List.head secList
         in
         case first of 
             Just sthing ->
                 case second of 
                     Just sthing2 ->
                        Just (sthing, sthing2)
                     Nothing ->
                         Nothing
             Nothing ->
                 Nothing
     Nothing ->
         Nothing




listOfAssetPair2listOfAssetPairCurr : AssetPairInfo -> List Currency -> (Maybe Currency, Maybe Currency)
listOfAssetPair2listOfAssetPairCurr assetPair  currencies = 
   let
      tupleList = List.map (\currency -> (currency.title, currency )) currencies 
      dictOfCurrencies = Dict.fromList tupleList
   in
   (Dict.get assetPair.base dictOfCurrencies, Dict.get assetPair.quote dictOfCurrencies)


articlesPerPage : Int
articlesPerPage =
    10


scrollToTop : Task x ()
scrollToTop =
    Dom.setViewport 0 0
        -- It's not worth showing the user anything special if scrolling fails.
        -- If anything, we'd log this to an error recording service.
        |> Task.onError (\_ -> Task.succeed ())


-- SUBSCRIPTIONS
sendSubscribeMessageString : List String -> Cmd Msg
sendSubscribeMessageString pairs = 
    let
       dictS = (Dict.fromList [ ("name", "ticker")])
       subs = RegisterTopic "subscribe" pairs dictS
       json_subs = encode subs
       command = (send json_subs)
    in
    command

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
    [ Session.changes GotSession (Session.navKey model.session)
    , receive Receive
    , Sub.map (\subTrans -> TransactionsMsg subTrans) (TransactionsP.subscriptions model.modelTransaction)
    ]

-- EXPORT

toSession : Model -> Session
toSession model =
    model.session
