port module Page.Home exposing  (Model, Msg, init, subscriptions, toSession, update, view)

import Session exposing (Session)
import Html exposing (Html,  button, div, fieldset, h1, input, li, text, textarea, ul, br,p, label, span, th, tr, thead, td, table, tbody, img, small, h5, a, h3, h2,h4)
import Html.Attributes exposing (attribute, class, placeholder, type_, value, id, style, size, src, name, autocomplete, scope, alt)
import Html.Events exposing (onInput, onSubmit, onClick)
import Http
import Task exposing (Task)
import Http.Legacy
import Api exposing (Cred)
import Api.Endpoint as Endpoint
import Url.Builder
import Dict exposing (Dict)
import Api.Calls exposing (fetchFeed)
import List.Extra as LE
import Json.Encode as E
import Json.Decode exposing (dict, list, string, Decoder, field, map4, decodeString, errorToString, nullable, float, int, Value, decodeValue, at, index, map3, map2)
import Json.Decode.Pipeline
import Route exposing (Route)
import Api2.Data exposing (Currency, decoderCurrency, CurrencyResponse, decoderCurrencyResponse, Action, ActionResponse, decoderActionResponse, KrakenResponse, KrakenMetaResponse, decoderKrakenMeta, AssetMetaInfo, AssetPairInfo, dataDecoder, decoderKraken, ExchangeRequestResponse, TransactionRequest)
import Api2.Happy exposing (fetchMetaInfoGroup, fetchMetaInfo2, DetailedError(..), exchangeRequest, getActions, getActiveCurrencies2, getMonetaryCurrencies2, fetchMetaInfoGroupCsv, exchangeRequestVerification, getBaseUrl) 
import Round
import Asset
import Page.Home.Services as ServicesP
import Page.Home.Pros as ProsP
import Page.Home.Packages as PackagesP
import Page.Home.Naview as Nav
import Page.Exchange.Transactions as TransactionsP
import Page.Exchange.TransactionsView as TransView

import Svg exposing (svg, rect)
import Svg.Attributes

port receiveValHome : (E.Value -> msg) -> Sub msg
port sendReq2 : E.Value -> Cmd msg

type alias AssetPairCurrency = 
    {
        alternateName : String
    ,   primaryName : String
    ,   wsName : String
    ,   base : Currency
    ,   quote : Currency
    ,   decimals : Int
    }


type alias Model = 
    {
        name : String
        , session : Session
        , priceInfo : Maybe AssetMetaInfo
        , pairName : Maybe String
        , textIndex : Int
        , assetPairs :  Maybe (Dict String Api2.Data.AssetPairInfo) 
        , feed : Status CurrencyResponse
        , message : String
        , feedMeta : Maybe (Dict String AssetMetaInfo)
        , tradablePairs : Status (Dict String AssetPairInfo)
        , assetPairsCurr : Status (List AssetPairCurrency)
        , servicesModel : ServicesP.Model 
        , prosModel : ProsP.Model
        , packagesModel : PackagesP.Model
        , modelTransaction : TransactionsP.Model
    }


init : Session -> (Model, Cmd Msg)
init session = 
       let
          (model, cmds) = ServicesP.init session
          (modelPros, cmdsP) = ProsP.init session
          (modelPackages, cmdsPackages) = PackagesP.init session
          (modelTransactions, cmdsTr) = TransactionsP.init session Nothing
          _ = Debug.log "init" "function" 
          md = 
            { name =  "Nikos"
            , modelTransaction = modelTransactions
            , session = session
            , priceInfo = Nothing
            , pairName = Nothing
            , textIndex = 1
            , assetPairs = Nothing
            , feed = Loading
            , message = ""
            , feedMeta = Nothing
            , tradablePairs = Loading
            , assetPairsCurr = Loading
            , servicesModel = model
            , prosModel = modelPros
            , packagesModel = modelPackages
            }
       in
       ( md , Cmd.batch
           [getActiveCurrencies2 md.session CompletedFeedLoad
           , Cmd.map (\serCom -> (ServicesMsg serCom)) cmds
           , Cmd.map (\serCom -> (ProsMsg serCom)) cmdsP
           , Cmd.map (\serCom -> (PackageMsg serCom)) cmdsPackages
           , Cmd.map (\serCom -> (TransactionsMsg serCom)) cmdsTr

           ]
       )


getCurrency : Model -> String -> Maybe Currency
getCurrency model title =
    case model.feed of
        Loaded currencies ->
            let
              dic = Dict.fromList (List.map (\cur -> (cur.title, cur)) currencies.currencies)
            in
            Dict.get title dic
        _ ->
            Nothing

type Status a
    = Loading
    | LoadingSlowly
    | Loaded a
    | Failed

encodeRequestTransaction : Int -> Int -> Int -> Float -> Float -> Float -> E.Value
encodeRequestTransaction srcCur tgtCur actId  ammount rate fee = 
   E.object
   [ ("request_transaction", E.object
    [ ("src_currency_id", E.int srcCur)
    , ("tgt_currency_id", E.int tgtCur)
    , ("action_id", E.int actId)
    , ("src_amount", E.float ammount)
    , ("exchange_rate", E.float rate)
    , ("fee", E.float fee)
    ]
  )]


exchangeRequest : Model -> Currency -> Currency  -> Float -> Float -> Float -> Cmd Msg
exchangeRequest model  srcCur tgtCur  amount rate fee=     
    let
       body =
           encodeRequestTransaction srcCur.id tgtCur.id 2 amount rate fee
           |> Http.jsonBody
    in
    Http.request
    {
     headers =
         case Session.cred (model.session) of
             Just cred ->
                 let
                     _ = Debug.log "cred" (Api.credHeader cred)
                 in
                 [ Api.credHeader cred]      
             Nothing ->
                 []
    , method = "POST"
    , body = body
    , url = (getBaseUrl ++ "/api/v1/transaction/sellbuy")
    , expect = Http.expectJson  CompletedTransactionRequestSubmited string
    , timeout = Nothing
    , tracker = Nothing
    }

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


type  Msg = 
    GetMetaInfo (Result Http.Legacy.Error (KrakenMetaResponse))
    | ServicesMsg ServicesP.Msg
    | ProsMsg ProsP.Msg
    | ChangeText Int
    | OnClick
    | CompletedFeedLoad (Result Http.Error (CurrencyResponse))
    | CompletedTransactionRequestSubmited (Result Http.Error (String))
    | Receive Value
    | GetMetaInfoGroup (Result Http.Error (KrakenMetaResponse))
    | TradablePairs (Result Http.Error (KrakenResponse))
    | PackageMsg PackagesP.Msg
    | TransactionsMsg TransactionsP.Msg

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [receiveValHome Receive, Sub.map (\transMsg -> TransactionsMsg transMsg) (TransactionsP.subscriptions model.modelTransaction)]

type alias RegisterTopic = 
    { event : String
    , pair : List String
    , subscription : Dict String String
    }

encode : RegisterTopic -> E.Value
encode reTo = 
    E.object
    [ ("event", E.string reTo.event)
    , ("pair", (E.list E.string) reTo.pair)
    , ("subscription", E.dict (\top -> top) E.string  reTo.subscription)
    ]


type alias Item =
    { value : String
    , text : String
    , enabled : Bool
    }

type alias Options msg =
    { items : List Item
    , emptyItem : Maybe Item
    , onChange : Maybe String -> msg
    }

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


update : Msg -> Model -> ( Model, Cmd Msg)
update msg model =
    case msg of
       TransactionsMsg transMsg ->
           let
               (transM, comTrans) = TransactionsP.update transMsg model.modelTransaction
           in
           ({model | modelTransaction = transM}, Cmd.map(\transCom -> (TransactionsMsg transCom)) comTrans) 
       ServicesMsg servMsg ->
           let
               (serM, comSer) = ServicesP.update  servMsg model.servicesModel
           in
           ({model |servicesModel = serM}, Cmd.map (\serCom -> (ServicesMsg serCom)) comSer)
       ProsMsg servMsg ->
           let
               (serM, comSer) = ProsP.update  servMsg model.prosModel
           in
           ({model |prosModel = serM}, Cmd.map (\serCom -> (ProsMsg serCom)) comSer)

       PackageMsg servMsg ->
           let
               (serM, comSer) = PackagesP.update  servMsg model.packagesModel
           in
           ({model |packagesModel  = serM}, Cmd.map (\serCom -> (PackageMsg serCom)) comSer)

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


       CompletedTransactionRequestSubmited (Ok respMsg) ->
           let
              _ = Debug.log "error in the reqerwerwer:  " respMsg
           in 
           ({model | message = respMsg}, Cmd.none)

       CompletedTransactionRequestSubmited (Err error) ->
           let
              _ = Debug.log "error in the reqerwerwer:  " error
           in
           ({model | message = "Not succesfull request"}, Cmd.none)

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


       OnClick ->
           (model, Cmd.none)

       ChangeText num ->
           ({model | textIndex = num}, Cmd.none)
       
       GetMetaInfo (Ok krakenResponse) ->
            let
                packModel = model.packagesModel
                packModelNew = {packModel | feedMeta = Just krakenResponse.assetInfo}
                model_new = 
                        {model |  feedMeta = Just krakenResponse.assetInfo, packagesModel = packModelNew}

            in
            (model_new , Cmd.none)

       GetMetaInfo (Err error) ->
            ( model, Cmd.none)


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

listOfAssetPair2listOfAssetPairCurr : AssetPairInfo -> List Currency -> (Maybe Currency, Maybe Currency)
listOfAssetPair2listOfAssetPairCurr assetPair  currencies = 
   let
      tupleList = List.map (\currency -> (currency.title, currency )) currencies 
      dictOfCurrencies = Dict.fromList tupleList
   in
   (Dict.get assetPair.base dictOfCurrencies, Dict.get assetPair.quote dictOfCurrencies)

type alias ContentPair = 
    { value : String
    , text  : String
    , enabled : Bool
    }

view : Model -> { title: String, content : Html Msg}
view model =
    { title = "Home"
    , content =
        div[ ]
        [
         div [class "container-fluid", style "width" "100%" ]
              [
               div[class "row home-page", style "margin-bottom" "10vh",style "padding-bottom" "15%"]
                 [
                    div[class "col", style "width" "100%"]
                    [
                       div[class "row"][Nav.naview model.session 1]
                    ,   div[class "row justify-content-around", style "margin-top" "7vh"]
                        [
                          div[class "col-xxl ", style "margin-top" "8vh"]
                          [
                           p[]
                           [
                            h1[style "font-weight" "bolder", style "color" "rgba(0,99,166,1)",style "text-shadow" "2px 0 rgba(0,99,166,1)", style "font-size" "3.5rem", style "letter-spacing" "2.5px"][text "Crypto Currency"]
                          , h1[style "font-weight" "bolder", style "color" "rgba(0,99,166,1)",style "text-shadow" "2px 0 rgba(0,99,166,1)", style "font-size" "3.5rem", style "letter-spacing" "2.5px"][text "Exchange Platform"]
                           ]
                        , p[style "color" "rgba(255,158,46,1)", style "margin-top" "3.5vh",style "font-size" "2.5rem",style "line-height" "1.2"]
                          [
                            text "You can buy sell exchange"
                          , br[][]
                          , text " cryptocurrencies"
                          ]
                        , p[style "margin-top" "10px"]
                          [
                              svg[]
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
                         ]
                        , div[class "col-xxl-4 col-md-8 col-lg-5 col-xl-4 col-sm-12 col-xs-12"]
                          [
                              Html.map(\transMsg -> TransactionsMsg transMsg) (TransView.view model.modelTransaction TransactionsP.LoginMode)
                          ]
                      ]
                  ]
                   
                  ]
              , div[class "row justify-content-center", style "margin-bottom" "10vh"]
                [
                  div[class "col col-lg-7"][ Html.map (\serCom -> ServicesMsg serCom) (ServicesP.view model.servicesModel)]
                ]
              , div[class "row justify-content-center"]
                [
                   div[class "col col-lg-6"][  Html.map (\serCom -> ProsMsg serCom) (ProsP.view model.prosModel)]
                ]
              ,  Html.map (\serCom -> TransactionsMsg serCom) (TransView.viewPackages model.modelTransaction TransactionsP.LoginMode)
              ,  Html.map (\serCom -> PackageMsg serCom) (PackagesP.view model.packagesModel)
              ]
          ] 
    }

 
viewTableData : Status (List AssetPairCurrency) -> Model -> Html Msg
viewTableData  content model = 
    case content of
       
        Loaded assetPairCurrencies ->
          let
             listOfAssetPairs = List.filter (\assetPair ->  (String.contains  "EUR" assetPair.quote.title)) assetPairCurrencies
             (pairs, rest) = LE.splitAt 6 listOfAssetPairs
          in
          table[class "table table-hover"]
            [
                thead[]
                [
                    tr[]
                    [
                      th[scope "col"][text "Coin"]
                    , th[scope "col"][text "Price"]
                    , th[scope "col"][text "Change from Open"]
                    ]    
                ]

             ,  tbody[]
                (List.map (\assetPair -> 
                    
                        tr[]
                        [
                            td[]
                            [
                              img[style "padding-right" "1vw",src assetPair.base.url][]
                            , text assetPair.base.alias_
                            ]
                        ,   td[][text (findPriceWithFee assetPair.decimals assetPair.base.fee (findCurrencyPrice assetPair model))]
                        ,   td[][text (findCurrencyChange assetPair model)] 
                        ]    
                    ) pairs)

            ]
    
        _ ->
            div[][span [][text "No content"]]

findPriceWithFee : Int -> Float -> String -> String
findPriceWithFee decimals fee price =
    case String.toFloat price of
        Just numbPr ->
            let
               sint = (fee/100)+1
               endVal = sint* numbPr
            in
           (Round.round decimals endVal)


        Nothing ->
            "N/A"

findPriceWithFeeF : Int ->Float -> String -> Maybe Float
findPriceWithFeeF decimals fee price =
    case String.toFloat price of
        Just numbPr ->
            let
               sint = (fee/100)+1
               endVal = sint* numbPr
            in
           Just (Round.roundNum decimals endVal)
        Nothing ->
            Nothing



findCurrencyPrice : AssetPairCurrency -> Model -> String
findCurrencyPrice assetPair model= 
    case model.feedMeta of
        Just dict ->
          case Dict.get assetPair.primaryName dict of
              Just assetMeta ->
                assetMeta.a.price
              Nothing ->
                  case Dict.get assetPair.alternateName dict of
                      Just metaInf ->
                          metaInf.a.price
                      Nothing ->
                          "N/A"
        Nothing ->
            "N/A"

findCurrencyChange : AssetPairCurrency -> Model -> String
findCurrencyChange assetPair model= 
    case model.feedMeta of
        Just dict ->
          case Dict.get assetPair.primaryName dict of
              Just assetMeta ->
                case  String.toFloat assetMeta.a.price of
                    Just number ->
                        case String.toFloat assetMeta.o.today of
                            Just numberOpen ->
                                 (Round.round 2 (((number- numberOpen) / numberOpen )* 100)) ++ "%"
                            Nothing ->
                                "N/A"
                    Nothing ->
                        "N/A"
              Nothing ->
                  case Dict.get assetPair.alternateName dict of
                      Just metaInf ->
                          case  String.toFloat metaInf.a.price of
                            Just number ->
                              case String.toFloat metaInf.o.today of
                                 Just numberOpen ->
                                    (Round.round 2 (((numberOpen - number) / numberOpen )* 100)) ++ "%"
                                 Nothing ->
                                   "N/A"
                            Nothing ->
                              "N/A"
                      Nothing ->
                          "N/A"

        Nothing ->
            "N/A"
      


getStyle: Model -> Int -> String
getStyle model index =
    if model.textIndex == index then
       "btn btn-primary"
    else
       "btn btn-outline-info"


sendSubscribeMessageString : List String -> Cmd Msg
sendSubscribeMessageString pairs = 
    let
       dictS = (Dict.fromList [ ("name", "ticker")])
       subs = RegisterTopic "subscribe" pairs dictS
       json_subs = encode subs
       command = (sendReq2 json_subs)
    in
    command

toSession : Model -> Session
toSession model =
    model.session
