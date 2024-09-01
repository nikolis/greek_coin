module Page.Exchange.TransactionsPage exposing (Model, Msg, init, subscriptions, toSession, update, view, initPre,viewModal)

import Html exposing (..)
import Html.Attributes exposing (attribute, class, disabled, href, id, placeholder, type_, value, size, style, scope, alt, src, value)
import Html.Events exposing (onInput, onSubmit, onClick, on)
import Http
import Loading
import Session exposing (Session)
import Task exposing (Task)
import Dict exposing (Dict)
import Paginate exposing (..)
import Api.Calls exposing (..)
import Json.Encode as E
import Json.Decode exposing (string, decodeString, float, int, Value, decodeValue, Decoder)
import Json.Decode.Pipeline
import Round
import Bootstrap.Modal as Modal
import Bootstrap.Button as Button
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid as Grid
import Asset
import Animation exposing (percent, px, turn)
import  Animation.Messenger
import Api2.Data exposing (Currency, decoderCurrency, CurrencyResponse, decoderCurrencyResponse, Action, ActionResponse, decoderActionResponse, KrakenResponse, KrakenMetaResponse, decoderKrakenMeta, AssetMetaInfo, AssetPairInfo, dataDecoder, decoderKraken, ExchangeRequestResponse, TransactionRequest)
import Api2.Happy exposing (DetailedError(..), exchangeRequest, getActiveCurrencies2, fetchMetaInfoGroupCsv, getActions, getBaseUrl) 
import Html.Events.Extra exposing (targetValueIntParse)
import Page.Exchange.Transactions as TransP
import Page.Exchange.TransactionsView as TransView
import Svg exposing (svg, rect)
import Svg.Attributes

type alias Model =
    {
         session : Session
        , modelTransaction : TransP.Model 
        , feed : Status CurrencyResponse
        , assetPairsCurr : Status (List AssetPairCurrency)
        , feedMeta : Maybe (Dict String AssetMetaInfo)
        , actions : List Action
        , showDialog : Bool
        , modalVisibility : Modal.Visibility
        , style : Animation.State
        , tradablePairs : Status (Dict String AssetPairInfo)
        , resetParam : Bool
        , resetParamFirst : Bool
        , config : Maybe Preconfiguration
    }

init : Session -> ( Model, Cmd Msg )
init session =
      let
          (transModel, cmd) = TransP.init session  Nothing
          md = 
            {
             session = session
            , modelTransaction = transModel
            , resetParam = False
            , resetParamFirst = False
            , feed = Loading
            , feedMeta = Nothing
            , assetPairsCurr = Loading
            , actions = []
            , showDialog = False
            , modalVisibility = Modal.hidden
            , tradablePairs = Loading
            , config = Nothing
            , style =  Animation.style
              [ Animation.left (px 0.0)
              , Animation.opacity 0.0
              ]
            }
       in
       ( md , Cmd.batch
           [ getActiveCurrencies2 md.session CompletedFeedLoad
           , (Cmd.map (\tr -> (TransactionMsg tr)) cmd)
           ]
       )

initPre : Session -> Int -> String -> ( Model, Cmd Msg )
initPre session id ammount=
      let
          preConfig = case String.toFloat ammount of
                Just number ->
                    Just (Preconfiguration id number)
                Nothing ->
                    Nothing

          (transModel, cmd) = TransP.init session preConfig 
          md = 
            {
             resetParam = False
            , modelTransaction = transModel
            , resetParamFirst = False
            , session = session
            , feed = Loading
            , feedMeta = Nothing
            , assetPairsCurr = Loading
            , actions = []
            , showDialog = False
            , modalVisibility = Modal.hidden
            , tradablePairs = Loading
            , config = preConfig
            , style =  Animation.style
              [ Animation.left (px 0.0)
              , Animation.opacity 0.0
              ]
            }
            
       in
       ( md , Cmd.batch
           [ getActiveCurrencies2 md.session CompletedFeedLoad
           , (Cmd.map (\tr -> (TransactionMsg tr)) cmd)
           ]
       )

type alias Preconfiguration = 
    {
      currencyId : Int
    , ammount : Float
    }

type alias AssetPairCurrency = 
    {
        alternateName : String
    ,   primaryName : String
    ,   wsName : String
    ,   base : Currency
    ,   quote : Currency
    ,   decimals : Int
    }


type ActionWindow 
    = Buy
    | Sell
    | Exchange


-- MODEL
type Status a
    = Loading
    | LoadingSlowly
    | Loaded a
    | Failed


type alias Config msg =
    { closeMessage : Maybe msg
    , containerClass : Maybe String
    , header : Maybe (Html msg)
    , body : Maybe (Html msg)
    , footer : Maybe (Html msg)
    }

{-- Api Calls --}


type Msg
    = GotSession Session
    | GetMetaInfo (Result Http.Error (KrakenMetaResponse))
    | GetMetaInfoGroup (Result Http.Error (KrakenMetaResponse))
    | CompletedFeedLoad (Result Http.Error (CurrencyResponse))
    | Receive Value
    | OrderBuy
    | Acknowledge
    | CancelRequestAknowledge
    | ShowModal
    | Animate Animation.Msg 
    | Show
    | TradablePairs (Result Http.Error (KrakenResponse))
    | Event Int
    | TransactionMsg TransP.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
       TransactionMsg transM ->
           let
               (trM, command) = TransP.update transM model.modelTransaction 
           in
           ({model | modelTransaction = trM}, Cmd.map(\transMsg -> TransactionMsg transMsg) command)
       Event string ->
           (model, Cmd.none)


       Show ->
        let
            newStyle =
                Animation.interrupt
                    [ Animation.to
                        [ Animation.left (px 0.0)
                        , Animation.opacity 1.0
                        ]
                    ]
                    model.style
        in
        ({ model | style = newStyle }, Cmd.none)

       Animate animMsg ->
         ({ model | style = Animation.update animMsg model.style
        }, Cmd.none)

       
       ShowModal ->
            ( { model | modalVisibility = Modal.shown }
            , Cmd.none
            )

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
                    
                    (trMod, cmds ) = TransP.update (TransP.GotAssetPairCurr assetPairCurr) model.modelTransaction

                 in
                 ({model | assetPairsCurr = Loaded assetPairCurr, modelTransaction = trMod }, Cmd.batch [fetchMetaInfoGroupCsv theStringFinal GetMetaInfoGroup ])
               _ ->
                ({model | tradablePairs = Loaded resp.assetPairs}, Cmd.none)

       TradablePairs (Err httpErr) ->
           (model, Cmd.none)

       CompletedFeedLoad (Ok feed) ->
            ( { model | feed = Loaded feed}
              ,
               Cmd.batch[
                 getTradableAssetPairs
              ]
            )

       CompletedFeedLoad (Err error) ->
            ( { model | feed = Failed }, Cmd.none )

       OrderBuy ->
         (model, Cmd.none)

       GetMetaInfo (Ok krakenResponse) ->
            let
                modelTr = model.modelTransaction
                model_new = 
                        {model |  feedMeta = Just krakenResponse.assetInfo}
            in
            {--update (ChangeFromNumb  (String.fromFloat model_new.fromNumber)) model_new --}
            (model_new, Cmd.none)

       GetMetaInfo (Err error) ->
            ( model, Cmd.none)

       GotSession session ->
           ({model |session = session}, Cmd.none)

       GetMetaInfoGroup (Ok krakenResponse) ->
            let
                modelTr = model.modelTransaction
                model_new = 
                        {model |  feedMeta = Just krakenResponse.assetInfo}
            in
           (model_new, Cmd.none)

       GetMetaInfoGroup (Err error) ->
            ( model, Cmd.none)

       Receive value ->
            let
                decodedMessage = decodeValue dataDecoder value
            in
            case decodedMessage of 
                Ok data ->
                  case model.assetPairsCurr of 
                    Loaded assetPairs ->
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
                                       
                                         list =   List.filter (\assetPairCurr -> (String.contains a assetPairCurr.base.title && String.contains b assetPairCurr.quote.title) ) assetPairs
                                         head = List.head list
                                       in
                                       case head of
                                           Nothing ->
                                               ""
                                           Just assetPair ->
                                               assetPair.primaryName
                                      
                                    Nothing ->
                                      ""
                                newFeedMeta = Dict.insert name data.metaInf dictMeta
                                md = {model | feedMeta = Just newFeedMeta }
                            in
                            {--update (ChangeFromNumb (String.fromFloat model.fromNumber)) md--}
                            (model, Cmd.none)
                        Nothing ->
                            (model, Cmd.none)
                    _ ->
                        (model, Cmd.none)
                    
                Err error ->
                    (model, Cmd.none)

       Acknowledge ->
            ( { model | showDialog = False }
            , Cmd.none
            )

       CancelRequestAknowledge ->
            ( { model | showDialog = False }
            , Cmd.none
            )

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


maybeStringsToString : Maybe String -> Maybe String -> String
maybeStringsToString m1 m2 =
    case m1 of
        Just str ->
            case m2 of 
                Just str2 ->
                    str ++ str2
                Nothing ->
                    str
        Nothing ->
            "O kipos den einai anthoris"

maybeStringsToString2 : Maybe String -> Maybe String -> String
maybeStringsToString2 m1 m2 =
    case m1 of
        Just str ->
            case m2 of 
                Just str2 ->
                    str ++ String.slice 0 ((String.length str2)-1) str2
                Nothing ->
                    str
        Nothing ->
            "O kipos den einai anthoris"


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Buy Cryptocurrencies"
    , content =
              div [class "container-xxl"]
              [
                div[class "row justify-content-center",style "margin-bottom" "40px"]
                [
                    div[class "col-9",style "margin-top" "5vh", style "margin-bottom" "4vh"]
                    [
                        span[style "color" "rgba(0,99,166,1)", style "font-size" "3.5rem", style "font-weight" "bolder", style "text-shadow" "1px 0 rgba(0,99,166,1)"][text "EXCHANGE"]
                    , br[][]
                    , img[src "/images/line.svg"][]
                    ]
                ]
              
              , div[class "row justify-content-center"]
                [ 
                  div[class "col col-md-12 col-lg-5 col-xl-5 col-sm-12 col-xs-12", style "margin-bottom" "40px"]
                  [
                    Html.map(\transCom -> TransactionMsg transCom) (TransView.view model.modelTransaction TransP.ScrollBuyMode)
                  ]
                , div[class "col col-xl-5 col-lg-7"]
                  [
                    Html.map(\transCom -> TransactionMsg transCom) (TransView.pricesTable model.modelTransaction 5)
                  ]
                ]
              ,  Html.map(\transCom -> TransactionMsg transCom) (TransView.viewPackages model.modelTransaction TransP.ScrollBuyMode)

             ] 
    }

viewModal : Model -> Maybe (Html Msg)
viewModal model =
    case TransView.viewModal model.modelTransaction of
        Nothing ->
            Nothing
        Just viewSt ->
            Just (Html.map(\transCom -> TransactionMsg transCom) (viewSt))

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
-- SUBSCRIPTIONS


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


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch 
     [
       Session.changes GotSession (Session.navKey model.session)
{--     , receiveVal Receive--}
     , Animation.subscription Animate [ model.style ]
     , Sub.map (\msg -> TransactionMsg msg) (TransP.subscriptions  model.modelTransaction)
     ]

toSession : Model -> Session
toSession model =
    model.session
