module Page.Withdraw exposing (Model, Msg, init, subscriptions, toSession, update, view)

import Api
import Api2.Data exposing (Currency, CurrencyResponse, Withdraw, WithdrawResponse, decoderCurrency, decoderCurrencyResponse, decoderWithdrawResponse, BankDetails, Wallet, decoderKraken, KrakenResponse, KrakenMetaResponse, AssetPairInfo, AssetMetaInfo)
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, decodeString, errorToString, field, float, int, list, map5, nullable, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Json.Encode as E
import Paginate exposing (..)
import Session exposing (Session)
import Dict exposing (Dict)
import Api2.Happy exposing(getBaseUrl, fetchMetaInfoGroupCsv)
import Asset
import Round
import Array exposing (Array)
import Color exposing (Color, fromRgba)
import LowLevel.Command exposing (arcTo, clockwise, largestArc, moveTo)
import Path
import Shape exposing (Arc, defaultPieConfig)
import SubPath exposing (SubPath)
import TypedSvg exposing (circle, g, svg)
import TypedSvg.Attributes exposing (fill, stroke, transform, viewBox)
import TypedSvg.Attributes.InPx exposing (cx, cy, r)
import TypedSvg.Core exposing (Svg)
import TypedSvg.Types exposing (Paint(..), Transform(..))
import List.Extra 
import Svg
import Svg.Attributes
import Route exposing (Route)
import Browser.Navigation as Navigat


type Status a
    = Loading
    | LoadingSlowly
    | Loaded a
    | Failed


type alias Model =
    { 
      session : Session
    , treasury : Status (List Treasury)
    , feedMeta : Maybe (Dict String AssetMetaInfo)
    , assetPairTrea : Status (List AssetPairTreasury)
    }


init : Session -> ( Model, Cmd Msg )
init session =
    let
        md =
            {
              session = session 
            , treasury = Loading
            , feedMeta = Nothing
            , assetPairTrea = Loading
            }

    in
    ( md, Cmd.batch 
          [ getTreasuries md
          ] )

type alias AssetPairTreasury = 
    {
        alternateName : String
    ,   primaryName : String
    ,   wsName : String
    ,   base : Currency
    ,   pairDecimal : Int
    ,   treasury : Treasury
    }


type alias TreasuryResponse = 
    {
        data : List Treasury
    }

type alias Treasury =
    {
        balance: Float
    ,   user : User
    ,   currency : Currency    
    }

type alias User = 
    {
       firstName : String
    ,  lastName : String
    }

decoderTreasuryResponse : Json.Decode.Decoder TreasuryResponse
decoderTreasuryResponse = 
    Json.Decode.succeed TreasuryResponse
    |> Json.Decode.Pipeline.required "data" (Json.Decode.list decoderTreasury)


decoderTreasury : Json.Decode.Decoder Treasury 
decoderTreasury = 
    Json.Decode.succeed Treasury
    |> Json.Decode.Pipeline.required "balance" float
    |> Json.Decode.Pipeline.required "user" decoderUser
    |> Json.Decode.Pipeline.required "currency" decoderCurrency


decoderUser : Json.Decode.Decoder User
decoderUser =
    Json.Decode.succeed User
    |> Json.Decode.Pipeline.required "first_name" myNullable
    |> Json.Decode.Pipeline.required "last_name" myNullable


getTreasuries : Model -> Cmd Msg
getTreasuries model =
    Http.request
        { headers =
            case Session.cred model.session of
                Just cred ->
                    [ Api.credHeader cred ]

                Nothing ->
                    []
        , method = "GET"
        , body = Http.emptyBody
        , url = (getBaseUrl ++ "/api/v1/transaction/treasury")
        , expect = Http.expectJson CompletedTreasuryLoad decoderTreasuryResponse
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


iconWallet : Html msg
iconWallet =
    Html.img
        [ Asset.src Asset.walletIcon
        , style "width" "30vw"
        , style "height" "30vh"
        , style "margin-bottom" "5vh"
        , style "margin-top" "5vh"
        , alt ""
        ]
        []

walletView : Model -> Html Msg
walletView model =
  case model.assetPairTrea of
      Loaded assetPair ->
           table[class "table"]
           [
               thead[]
               [
                   tr[]
                   [
                       th[scope "col"] [span[style "color" "rgba(112,112,112,1)"][text "Currency"]]
                   ,   th[scope "col"] [span[style "color" "rgba(112,112,112,1)"][text "Price"]]
                   ,   th[scope "col"] [span[style "color" "rgba(112,112,112,1)"][text "Daily Change"]]
                   ,   th[scope "col"] [span[style "color" "rgba(112,112,112,1)"][text "Balance"]]
                   ,   th[scope "col"] [span[style "color" "rgba(112,112,112,1)"][text "Value"]]
                   ]
               ]
            ,  tbody[]
                   (List.map (\trs -> 
                       tr[]
                       [
                         td[][img[src trs.base.url, style "margin-right" "1.4vw"][], span[style "text-transform" "uppercase", style "font-weight" "bold"][text  trs.base.alias_]]
                       , 
                          case calculateGettingSelling (getValueFromPair model trs) 1 trs.base.fee of
                            Just numb -> 
                                td[][span[style "font-weight" "bold"][text ((Round.round trs.pairDecimal numb)++" €")]]
                            Nothing ->
                                td[][span[style "font-weight" "bold"][text "n/a"]]
                       , td[][span[][text (findCurrencyChange trs model)]]

                       , td[][span[style "font-weight" "bold"][text (String.fromFloat trs.treasury.balance)]]
                       ,
                         case calculateGettingSelling (getValueFromPair model trs) trs.treasury.balance trs.base.fee of
                            Just numb -> 
                                td[][span[style "font-weight" "bold"][text ((Round.round trs.pairDecimal numb)++" €")]]
                            Nothing ->
                                td[][span[style "font-weight" "bold"][text "n/a"]]
                       ]
                       ) assetPair
                   )
           ]
      _ ->
          div[][]


findCurrencyChange : AssetPairTreasury -> Model -> String
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

walletViewDetailed : Model -> Html Msg
walletViewDetailed model =
  let
       eur = 
           case model.treasury of 
               Loaded list ->
                   let
                      listSort = List.filter (\item -> item.currency.alias_sort == "EUR") list
                      _ = Debug.log "list" listSort
                   in
                   List.map(\item1 -> 
                       tr[ ]
                       [
                          td[][img[src item1.currency.url, style "margin-right" "1.4vw"][], span[style "text-transform" "uppercase", style "font-weight" "bold"][text  item1.currency.alias_]]
                       , td[][span[style "font-weight" "bold"][text (String.fromFloat item1.balance)]]                       
                       , td[][span[style "font-weight" "bold"][text (String.fromFloat item1.balance)]]

                       ]

                      ) listSort
               _ ->
                   []
  in
  case model.assetPairTrea of
      Loaded assetPair ->
           table[class "table"]
           [
               thead[]
               [
                   tr[]
                   [
                       th[scope "col"] [span[style "color" "rgba(112,112,112,1)"][text "Currency"]]
                   ,   th[scope "col"] [span[style "color" "rgba(112,112,112,1)"][text "Balance"]]
                   ,   th[scope "col"] [span[style "color" "rgba(112,112,112,1)"][text "Value"]]
                   ]
               ]
            ,  tbody[]
                   ((List.map (\trs -> 
                       tr[]
                       [
                         td[][img[src trs.base.url, style "margin-right" "1.4vw"][], span[style "text-transform" "uppercase", style "font-weight" "bold"][text  trs.base.alias_]]
                       , td[][span[style "font-weight" "bold"][text (String.fromFloat trs.treasury.balance)]]
                       ,
                         case calculateGettingSelling (getValueFromPair model trs) trs.treasury.balance trs.base.fee of
                            Just numb -> 
                                td[][span[style "font-weight" "bold"][text ((Round.round trs.pairDecimal numb)++" €")]]
                            Nothing ->
                                td[][span[style "font-weight" "bold"][text "n/a"]]
                       ]
                       ) assetPair
                   ) ++ eur)
           ]
      _ ->
          div[][]



getValueFromPair2 : (Dict String AssetMetaInfo) -> AssetPairTreasury -> Maybe Float
getValueFromPair2 dict assetPair =
           case Dict.get  assetPair.primaryName dict of
               Just price ->
                  String.toFloat price.b.price
               Nothing ->
                   case Dict.get assetPair.alternateName dict of
                       Just price ->
                           String.toFloat price.b.price
                       Nothing ->
                           Nothing


viewTotal : Model -> Html Msg
viewTotal  model = 
    case model.feedMeta of 
        Nothing ->
            div[][img[src "images/history.svg"][]]

        Just feedMeta ->
            case model.assetPairTrea of
                Loaded assetPerT ->
                    case model.treasury of
                        Loaded treasuries ->
                          case List.isEmpty treasuries  of
                            False ->
                              let
                                maybeFloats = List.map(\aspt -> (calculateGettingSelling (getValueFromPair model aspt) aspt.treasury.balance aspt.base.fee)) assetPerT
                                sumOfCurrencies = List.foldr (\a b -> 
                                   case a of
                                       Just numb ->
                                          let
                                              _ = Debug.log "badf" numb
                                          in
                                          numb+b
                                       Nothing ->
                                           b) 0 maybeFloats
                                eurDeposits = List.filter(\treasury ->  (String.contains treasury.currency.alias_sort "EUR")) treasuries
                                eurBalance = 
                                    case List.head eurDeposits of
                                        Just dep->
                                           Round.roundNum 2 dep.balance
                                        Nothing ->
                                            0
    
                              in
                              div[style "border"  "2px solid rgb(239, 239, 239)", style "border-radius" "20px", style "padding" "7%", style "height" "100%"]
                              [ 
                                span[style "color" "rgba(112,112,112,1)", style "font-weight" "bold", style "font-size" "1.25rem"][text "Current Crypto Portfolio Value"]
                              , p[style "color" "rgba(0,99,166,1)", style "font-size" "3rem",style "margin-top" ""][text ((Round.round 2 sumOfCurrencies) ++ " €")]
                              , span[style "color" "rgba(112,112,112,1)", style "font-weight" "bold", style "font-size" "1.25rem"][text "Balance in Euros"]
                              , p[style "color" "rgba(0,99,166,1)", style "font-size" "3rem",style "margin-top" ""][text ((Round.round 2 (eurBalance)) ++ " €")] 
                              , span[style "color" "rgba(112,112,112,1)", style "font-weight" "bold", style "font-size" "1.25rem"][text "Total Account Value"]
                              , p[style "color" "rgba(0,99,166,1)", style "font-size" "3rem",style "margin-top" ""][text ((Round.round 2 (eurBalance + sumOfCurrencies))++" €")] 
                              ]
                            True ->
                                div[][text "sfafsdasdf"]

                        _ ->
                         div[][text "empty"]
                _ ->
                    div[][h1[][text "Nothing 252"]]


getValueFromPair : Model -> AssetPairTreasury -> Maybe Float
getValueFromPair model assetPair =
    case model.feedMeta of
        Nothing ->
            Nothing
        Just dict ->
           case Dict.get  assetPair.primaryName dict of
               Just price ->
                  String.toFloat price.b.price
               Nothing ->
                   case Dict.get assetPair.alternateName dict of
                       Just price ->
                           String.toFloat price.b.price
                       Nothing ->
                           Nothing

calculateGettingSelling : Maybe Float -> Float -> Float  -> Maybe Float
calculateGettingSelling rateM quantity fee  = 
  case rateM of 
      Just rate ->
       let
         _ = Debug.log "rate: " rate
         _ = Debug.log "quantity" quantity
         _ = Debug.log "fee" fee
         semi = rate * quantity
         full = semi - (semi * (fee/100))
       in
       Just full
      Nothing ->
       Nothing
          


myNullable :  Json.Decode.Decoder String
myNullable  =
    Json.Decode.oneOf
    [ Json.Decode.string
    , Json.Decode.null ""
    ]


type Msg
    = GotSession Session
    | CompletedTreasuryLoad (Result Http.Error TreasuryResponse)
    | TradablePairs (Result Http.Error (KrakenResponse))
    | GetMetaInfoGroup (Result Http.Error (KrakenMetaResponse))
    | ToExchangePage
    
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToExchangePage ->
           (model, Navigat.load (Route.routeToString Route.NewArticle ))

        GetMetaInfoGroup (Ok krakenResponse) ->
           let
              md = {model | feedMeta = Just krakenResponse.assetInfo} 
           in
         (md, Cmd.none)

        GetMetaInfoGroup (Err error) ->
            let
                _ = Debug.log "errr" error
            in
            ( model, Cmd.none)

        GotSession session ->
            ( { model | session = session }, Cmd.none )

        CompletedTreasuryLoad (Ok result) ->
            case List.isEmpty result.data of
                True ->
                  ({model | treasury = Loaded result.data}, Cmd.none)

                False ->
                  ({model | treasury = Loaded result.data}, (getTradableAssetPairs))

        CompletedTreasuryLoad (Err error) ->
             let
                 _ = Debug.log "Treasurey error " error
             in
            (model, Cmd.none)

        TradablePairs (Ok resp)  ->
            case model.treasury of
                Loaded treasuries ->
                  let
                    currencies = List.map(\treas -> treas.currency ) treasuries
                    listOfAssetPairs = Dict.toList resp.assetPairs
                    listFilter = List.filter (\(name, assetPair) -> ( 
                        (List.any (\curr -> curr.title == assetPair.base) currencies) 
                        &&  (List.any (\curr -> curr.title == assetPair.quote  || (String.contains "EUR" assetPair.quote)) currencies) )
                        ) listOfAssetPairs

                    assetPairCurrPre= listFrom  listFilter treasuries
                    assetPairCurr = List.filter (\assetPair ->  (not (String.contains ".d" assetPair.alternateName )) && (String.contains "EUR" assetPair.alternateName) ) assetPairCurrPre
                    
                     
                    csvPairs = List.foldr (\pair preb -> pair.alternateName ++ "," ++preb) "" assetPairCurr 
                    theStringFinal = String.slice 0 ((String.length csvPairs)-1) csvPairs
                    _ = Debug.log "the string final" theStringFinal
                  in
                  case String.isEmpty theStringFinal of
                      True ->
                         ({model| assetPairTrea = Loaded assetPairCurr, treasury = Loaded []}, Cmd.none)
                      False ->
                         ({model| assetPairTrea = Loaded assetPairCurr }, fetchMetaInfoGroupCsv theStringFinal GetMetaInfoGroup)
                _ ->
                  (model, Cmd.none)

        TradablePairs (Err error) ->
            (model, Cmd.none)

listFrom : List (String, AssetPairInfo) -> List Treasury -> List AssetPairTreasury
listFrom  asetPairs currencies =
    let
        someList = List.map (\(name, assetPair) ->  
            case listOfAssetPair2listOfAssetPairCurr  assetPair  currencies of
                Just (curr, treasury) ->
                    Just (AssetPairTreasury assetPair.alternate_name name assetPair.ws_name curr assetPair.pairDecimal treasury)
                Nothing ->
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


listOfAssetPair2listOfAssetPairCurr : AssetPairInfo ->  List Treasury -> (Maybe (Currency, Treasury))
listOfAssetPair2listOfAssetPairCurr assetPair  currencies = 
   let
      tupleList = List.map (\treasury -> (treasury.currency.title, (treasury.currency, treasury ))) currencies 
      dictOfCurrencies = Dict.fromList tupleList
   in
   (Dict.get assetPair.base dictOfCurrencies)


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Withdraw"
    , content = 
        case model.feedMeta of
            Nothing ->
                case model.treasury of
                   Loaded list ->
                      case  List.isEmpty list of
                          True ->
                             viewEmpty model
                          False ->
                              viewLoading model
                   _  ->
                        viewLoading model

            Just sdf ->
               viewContent model
    }


viewEmpty : Model -> Html Msg
viewEmpty model = 
       div[class "container-xxl", style "margin-top" "5vh", style "margin-left" "10%", style "margin-right" "10%"] 
          [
            div[class "row"]
            [
              div[class "col"]
              [
                 span[style "color" "rgba(0,99,166,1)", style "font-size" "3.5rem", style "font-weight" "bolder", style "text-shadow" "1px 0 rgba(0,99,166,1)"][text "WALLET"]
              ,  br[][]
              ,  img[Html.Attributes.src "/images/line.svg"][]
              ]
            ]
         , div[class "row"]
            [
              div[class "col"][]

            , div[class "col"]
               [
                   viewTotal model
               ,   div[style "text-align" "center"]
                   [
                       span[style "font-weight" "bolder"][text "Here you will be able to evaluate"]
                   ,   br[][]
                   ,   span[style "font-weight" "bolder"][text "Portfolio value"]
                   ]
                   
               ,  div[class "d-flex justify-content-center", style "margin-top" "50px", style "margin-bottom" "150px"]
                 [ 
                      button [type_ "button", style "width" "30%" , style "margin" "auto", style "padding" "10px 3px", onClick ToExchangePage, class "btn btn-primary primary_button"][text "START"]
                 ]
               ]
            , div[class "col"][]
            ]
         ]

viewLoading : Model -> Html Msg
viewLoading model = 
       div[class "container-xxl", style "margin-top" "5vh", style "margin-left" "10%", style "margin-right" "10%"] 
          [
            div[class "row"]
            [
              div[class "col"]
              [
                 span[style "color" "rgba(0,99,166,1)", style "font-size" "3.5rem", style "font-weight" "bolder", style "text-shadow" "1px 0 rgba(0,99,166,1)"][text "WALLET"]
              ,  br[][]
              ,  img[Html.Attributes.src "/images/line.svg"][]
              ]
            ]
         , div[class "row", style "margin-bottom" "120px"]
            [
              div[class "col"][]

            , div[class "col"]
               [
                   img[src "images/loading.svg"][]
               ,   div[style "text-align" "center"]
                   [
                       span[style "font-weight" "bolder"][text "Wallet Loading.."]
                   ]
               ]
            , div[class "col"][]
            ]
         ]



viewContent : Model -> Html Msg
viewContent model = 
       let
        pieData =
              data    |> Shape.pie { defaultPieConfig | outerRadius = radius }
       in
       div[class "container-xxl", style "margin-top" "5vh", style "margin-left" "10%", style "margin-right" "10%"] 
          [
            div[class "row"]
            [
              div[class "col"]
              [
                 span[style "color" "rgba(0,99,166,1)", style "font-size" "3.5rem", style "font-weight" "bolder", style "text-shadow" "1px 0 rgba(0,99,166,1)"][text "WALLET"]
              ,  br[][]
              ,  img[Html.Attributes.src "/images/line.svg"][]
              ]
            ]
         , div[class "row"]
            [
              div[class "col col-xl col-lg-4 order-lg-1 order-mg-1 col-md-5", style "margin-top" "50px"]
               [
                   viewTotal model
               ]
            , div[class "col-5 col-xl-5 col-lg-9 order-lg-5 col-md-9 order-md-9", style "margin-top" "50px"]
              [
                  walletViewDetailed model
              ]
            , div[class "col col-xl col-lg-5 order-lg-2 order-md-2 col-md-5", style "margin-top" "50px"]
                  (pieChart model)
                
            ]
          , div[class "row", style "margin-top"  "50px"]
            [
                div[class "col-12"]
                [
                   walletView model
                ]
            ]
 
          ]




pieChart : Model -> List ( Html Msg)
pieChart model =
    case model.assetPairTrea of
        Loaded assetPair ->
            case model.feedMeta of 
                Just feedMeta ->
                    let
                        prices = List.map (\pair -> ((getValueFromPair2 feedMeta pair), pair.treasury.balance, pair) ) assetPair
                        endPrices = List.map (\(pr, am, pair) -> 
                            case  pr of
                              Just priceFl ->
                                  (priceFl * am, pair)
                              Nothing ->
                                  (0, pair)
                              ) prices
                        sortedList = List.sortBy Tuple.first endPrices 
                        (useList, combList) = List.Extra.splitAt 5 sortedList
                        endList = {--endNumb ::--} List.map Tuple.first useList
                        pieData =  endList  |> Shape.pie { defaultPieConfig | outerRadius = radius }
                        dataInd = List.indexedMap Tuple.pair endList
                   
                    in
                    
                      svg [ viewBox 0 0 w h]
                      [ {--circular pieData--}
                        annular pieData
                      ] ::
                       (List.map (\(index, dat) -> 
                           div[class "row" , style "width" "40%", style "margin-right" "auto", style "margin-left" "auto"]
                           [
                             div[class "col-1"]
                             [
                               svg
                               [ width 120
                               , height 120
                               , viewBox 0 0 120 120
                               , style "width" "25px" , style "height" "25px"
                               ]
                               [
                                Svg.circle 
                                [
                                  Svg.Attributes.cx "50", Svg.Attributes.cy "50" , Svg.Attributes.r "50",
                                  (case (Array.get index colors) of
                                    Just color ->
                                      Svg.Attributes.fill (Color.toCssString color)
                                    Nothing ->
                                      Svg.Attributes.fill "black"
                                  )
                                ][]
                               ]
                             ]
                          , div[class "col"]
                            [
                                span[]
                                [
                                  text 
                                  (
                                    case List.Extra.getAt index useList of
                                        Just (pr, item) ->
                                            item.base.alias_
                                        Nothing ->
                                            ""
                                  )
                                ]
                            ]
                          ] 
                       ) dataInd)

                _ ->
                    []
        _ ->
            []


w : Float
w =
    700


h : Float
h =
    350


rgba255 : Int -> Int -> Int -> Float -> Color
rgba255 r g b a =
    Color.fromRgba { red = toFloat r / 255, green = toFloat g / 255, blue = toFloat b / 255, alpha = a }


radius : Float
radius =
    Basics.min (w / 2) h / 2 - 10


dot : SubPath
dot =
    SubPath.with (moveTo ( 5, 5 ))
        [ arcTo
            [ { radii = ( 5, 5 )
              , xAxisRotate = 0
              , arcFlag = largestArc
              , direction = clockwise
              , target = ( 5, 5 )
              }
            ]
        ]


annular : List Arc -> Svg msg
annular arcs =
    let
        makeSlice index datum =
            Path.element (Shape.arc { datum | innerRadius = radius - 70 })
                [ fill <| Paint <| Maybe.withDefault Color.black <| Array.get index colors
                ]
    in
    g [ transform [ Translate (2 * radius + 20) radius ] ]
        [ g [] <| List.indexedMap makeSlice arcs
        ]

colors : Array Color
colors =
    Array.fromList
        [ rgba255 23 190 207 1
        , rgba255 0 99 166 1
        , rgba255 255 158 46 1
        , rgba255 255 158 255 1
        , rgba255 214 39 40 1
        , rgba255 148 103 189 1
        , rgba255 140 86 75 1
        , rgba255 227 119 194 1
        , rgba255 128 128 128 1
        , rgba255 188 189 34 1
        ]

data : List Float
data =
    [ 30, 1, 2, 3, 5, 8, 13 ]
    


toSession : Model -> Session
toSession model =
    model.session

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
    [
      Session.changes GotSession (Session.navKey model.session)
    ]
