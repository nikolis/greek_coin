module Page.Legal.FeeTable exposing (..)

import Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (class, classList, href, style)
import Page.Home.Naview as Nav
import Svg exposing (svg, rect)
import Svg.Attributes
import Page.Home.Packages exposing (viewGettingStarted)
import Page.Home.Packages as PackagesP
import Page.Exchange.Transactions as TransactionsP
import Page.Exchange.TransactionsView as TransView
import Api2.Data exposing (Currency, decoderCurrency, CurrencyResponse, decoderCurrencyResponse, Action, ActionResponse, decoderActionResponse, KrakenResponse, KrakenMetaResponse, decoderKrakenMeta, AssetMetaInfo, AssetPairInfo, dataDecoder, decoderKraken, ExchangeRequestResponse, TransactionRequest)
import Api2.Happy exposing (fetchMetaInfoGroup, fetchMetaInfo2, DetailedError(..), exchangeRequest, getActions, getActiveCurrencies2, getMonetaryCurrencies2, fetchMetaInfoGroupCsv, exchangeRequestVerification, getBaseUrl) 
import Http
import Dict exposing (Dict)

type alias Model =  
    {
      session : Session
    , modelTransaction : TransactionsP.Model
    , priceInfo : Maybe AssetMetaInfo
    , assetPairs :  Maybe (Dict String Api2.Data.AssetPairInfo) 
    , feed : Status CurrencyResponse
    , feedMeta : Maybe (Dict String AssetMetaInfo)
    , tradablePairs : Status (Dict String AssetPairInfo)
    , assetPairsCurr : Status (List AssetPairCurrency)
 
    }

init : Session -> (Model, Cmd Msg)
init session = 
    let
        (modelTransactions, cmdsTr) = TransactionsP.init session Nothing
        md = 
            { session = session
            , modelTransaction = modelTransactions
            , feedMeta = Nothing
            , assetPairs = Nothing
            , priceInfo = Nothing
            , tradablePairs = Loading
            , assetPairsCurr = Loading
           , feed = Loading
            }
    in
    (md, Cmd.batch [ Cmd.map (\serCom -> (TransactionsMsg serCom)) cmdsTr , getActiveCurrencies2 md.session CompletedFeedLoad  ])


type Msg = 
  GotSession Session
  | TransactionsMsg TransactionsP.Msg
  | TradablePairs (Result Http.Error (KrakenResponse))
  | CompletedFeedLoad (Result Http.Error (CurrencyResponse))
  | GetMetaInfoGroup (Result Http.Error (KrakenMetaResponse))

type alias AssetPairCurrency =
    {
        alternateName : String
    ,   primaryName : String
    ,   wsName : String
    ,   base : Currency
    ,   quote : Currency
    ,   decimals : Int
    }


type Status a
    = Loading
    | LoadingSlowly
    | Loaded a
    | Failed

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




view : Model -> {title : String, content: Html Msg}
view model = 
    { title = "Fee Table"
    , content = 
        div[class ""]
        [ 
         div[style "margin-left" "-15px",style "background-image" "url(\"images/crupto_2.png\")", style "background-repeat" "no-repeat", style "background-size" "cover", style "margin-top" "-5px", style "padding-right" "100px"]
         [
             div[class "col", style "margin-right" "10vw"]
             [
              Nav.naview model.session 2
             ]
         , div[class "row"]
           [
               div[class "col", style "margin-left" "10vw"]
               [
                 span[style "font-size" "3rem", style "font-weight" "bold", style "color""white"][text "Fee Table"]
{--               , span[style "font-size" "2rem", style "color" "rgba(255,158,46,1)"][text "Let's schedule together"]
               , br[][]
               , span[style "font-size" "2rem", style "color" "rgba(255,158,46,1)"][text "your next step in Cryptocurrency"]--}
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
               
               , div[class "col-6"][]
           ]
         ]
       , div[class "container"]
         [
             div[class "row"]
             [
                 div[class "col"]
                 [
                 ]
             ]

          ,  div[class "row", style "margin-top" "60px"]
             [
                 div[class "col"]
                 [
                   Html.map(\transMsg -> TransactionsMsg transMsg) (TransView.currencyTableExpanded  model.modelTransaction 5)
                 ]
             ]
          ]
     ]
 }


viewSteper : Model -> Html Msg
viewSteper model=
          div[class "container_profile_header" ]
          [
            div [class "center_exchange"]
            [
              h1 [][ span[][ text "Fee Table"]]
            ]
          ]
 

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
    case msg of 
      GotSession session ->
         ( { model | session = session }, Cmd.none
         )

      GetMetaInfoGroup (Ok krakenResponse) ->
            case model.feed of
                Loaded feedPairs ->
                    ({model | feedMeta = Just krakenResponse.assetInfo}, Cmd.none)
                _ ->
                    ({model | feedMeta = Just krakenResponse.assetInfo}, Cmd.none)


      GetMetaInfoGroup (Err error) ->
          let
              _ = Debug.log "error" error
          in
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

      TransactionsMsg transMsg ->
           let
               (transM, comTrans) = TransactionsP.update transMsg model.modelTransaction
           in
           ({model | modelTransaction = transM}, Cmd.map(\transCom -> (TransactionsMsg transCom)) comTrans)
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
                    (transModelNew, cmdsT) = TransactionsP.update(TransactionsP.GotAssetPairCurr  assetPairCurr) model.modelTransaction
                 in
                 ({model |  assetPairsCurr = Loaded assetPairCurr, modelTransaction = transModelNew}, Cmd.batch [fetchMetaInfoGroupCsv theStringFinal GetMetaInfoGroup])
               _ ->
                ({model | tradablePairs = Loaded resp.assetPairs}, Cmd.none)

      TradablePairs (Err httpErr) ->
           (model, Cmd.none)




toSession : Model -> Session
toSession model = 
    model.session


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)
