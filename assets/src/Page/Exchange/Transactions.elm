port module Page.Exchange.Transactions exposing (Model, Msg(..),PackageButtonMode(..), init, update, Status(..), subscriptions, AssetPairCurrencyAnimation, AssetPairCurrency, ActionWindow(..), getPriceFromCurrency, ModalState(..), findCurrencyPrice, findCurrencyChange, getPriceFromCurrencyView)

import Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Api2.Data exposing (Currency, AssetMetaInfo, Action, ExchangeRequestResponse,TransactionRequest, KrakenMetaResponse, CurrencyResponse, KrakenResponse, decoderKraken, AssetPairInfo, dataDecoder)
import Api2.Happy exposing (DetailedError(..),  exchangeRequest, exchangeRequestVerification, getBaseUrl, fetchMetaInfoGroupCsv, getActiveCurrencies2)
import List.Extra as LE 
import Json.Encode as E
import Round
import Dict exposing (Dict)
import Http
import Bootstrap.Modal as Modal
import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Bootstrap.Dropdown as Dropdown
import Route exposing (Route)
import Paginate exposing (..)
import Browser.Navigation as Navigat
import Api2.Data exposing (Withdraw)
import Api.Data exposing (Treasury)
import Api
import Json.Decode exposing (string, decodeString, float, int, Value, decodeValue, Decoder)
import Animation exposing (px)

port sendReq : E.Value -> Cmd msg
port scrolUp : String -> Cmd msg
port receiveVal : (E.Value -> msg) -> Sub msg

type alias Model = 
    {
      session: Session
     , window : ActionWindow
     , config : Maybe Preconfiguration
     , first : Maybe Currency
     , fromNumberString : String
     , toNumberString : String
     , assetPairsCurr : Status (List AssetPairCurrencyAnimation)
     , second : Maybe Currency
     , feedMeta : Maybe (Dict String AssetMetaInfo)
     , changeFirst : Bool
     , toNumberSell : Float
     , actions : List Action
     , modalVisibility : ModalState
     , message : String
     , messageTitle : String
     , modalTransaction : Maybe TransactionRequest
     , showDialog : Bool
     , modalAction : Int
     , modalToken : String
     , myDrop1State : Dropdown.State
     , myDrop2State : Dropdown.State
     , myDropStatePackages : Dropdown.State
     , selectedPair : Maybe AssetPairCurrency
     , feed : Status CurrencyResponse
     , things :Status (PaginatedList AssetPairCurrency)
     , tradablePairs : Status (Dict String AssetPairInfo)
     , expanded : Bool
     , style : Animation.State
     , response : Maybe ExchangeRequestResponse
    }

init: Session -> Maybe Preconfiguration -> (Model, Cmd Msg)
init session preConfig = 
    let
        md = 
          { session = session 
          , window = Buy
          , config = preConfig
          , first = Nothing
          , fromNumberString = "0"
          , toNumberString = "0"
          , assetPairsCurr = Loading
          , second = Nothing
          , feedMeta = Nothing
          , changeFirst = True
          , toNumberSell = 0.00 
          , actions = []
          , modalVisibility = Invisible
          , message = ""
          , messageTitle = ""
          , modalTransaction = Nothing
          , showDialog = False
          , modalAction = 2
          , modalToken = ""
          , myDrop1State = Dropdown.initialState
          , myDrop2State = Dropdown.initialState
          , myDropStatePackages = Dropdown.initialState
          , selectedPair = Nothing
          , feed = Loading
          , things = Loading
          , tradablePairs = Loading
          , expanded = False
          , style =
             Animation.style
                [ Animation.opacity 1.0
                ]
          , response = Nothing
          }
    in
    (md, getActiveCurrencies2 md.session CompletedFeedLoad)

type PackageButtonMode = 
    LoginMode
    | ScrollBuyMode 

type ModalState = 
    Visible 
    | Invisible 
    | Validation


type Status a
    = Loading
    | LoadingSlowly
    | Loaded a
    | Failed

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

type alias AssetPairCurrencyAnimation = 
    {
        pair : AssetPairCurrency
    ,   animation : Animation.State
    }

type ActionWindow 
    = Buy
    | Sell
    | Exchange


type Msg =
      ChangeWindow ActionWindow
    | SendRequest
    | ChangeToNumb String
    | ChangeFromNumbHand String
    | UpdateDueToWindow
    | SecondSet Currency
    | FirstSet Currency
    | ChangeFromNumb String
    | CompletedTransactionRequestSubmited (Result (DetailedError String) (Http.Metadata, ExchangeRequestResponse))
    | ShowModal
    | CloseModal Int String
    | CloseModalValidation
    | GotAssetPairCurr (List AssetPairCurrency)
    | GetMetaInfoGroupDict (Dict String AssetMetaInfo)
    | MyDrop1Msg Dropdown.State
    | MyDrop2Msg Dropdown.State
    | ItemMsg AssetPairCurrency
    | GetMetaInfoGroup (Result Http.Error (KrakenMetaResponse))
    | CompletedFeedLoad (Result Http.Error (CurrencyResponse))
    | TradablePairs (Result Http.Error (KrakenResponse))
    | MyDropMsgPackages Dropdown.State
    | ToLoginPage
    | SessionExpired
    | ScrollBuy AssetPairCurrency Float
    | Next
    | Prev
    | First
    | Last
    | GoTo Int
    | Expand Bool
    | Receive Value
    | Animate AssetPairCurrencyAnimation Animation.Msg
    | FadeInFadeOut


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

exchangeRequestCreator : Model -> Int -> (Model, Cmd Msg)
exchangeRequestCreator model type_=
  case model.assetPairsCurr of
      Loaded assetPairs->
        let
            _ = Debug.log "Here tat aexaghcjha requets" ""
        in
               case model.first of
                   Just first ->
                       case model.second of
                           Just second ->
                               let
                                 filteredList = List.filter (\assetPair -> assetPair.pair.base == first && assetPair.pair.quote == second)  assetPairs
                                 assetPairMaybe = List.head filteredList
                               in
                               case assetPairMaybe of
                                   Just assetPair ->
                                             case model.feedMeta of
                                                 Just feedDic ->
                                                     case Dict.get assetPair.pair.primaryName feedDic of
                                                         Just metaInfo ->
                                                            case String.toFloat metaInfo.a.price of
                                                               Just price -> 
                                                                  if type_ == 1  || type_ == 3 then
                                                                     case String.toFloat model.toNumberString of
                                                                         Just ammount ->
                                                                            ({model | modalVisibility = Visible, modalAction = 3} ,exchangeRequest model.session  assetPair.pair.quote assetPair.pair.base type_ ammount price assetPair.pair.base.fee CompletedTransactionRequestSubmited assetPair.pair.primaryName)
                                                                         Nothing ->
                                                                            ({model | modalVisibility = Validation , messageTitle= "Validation ", message = "Ammount should be a number"}, Cmd.none)
                                                                   else
                                                                     case String.toFloat model.fromNumberString of
                                                                       Just ammount ->  
                                                                          ({model | modalVisibility = Visible, modalAction = 3 }, exchangeRequest model.session assetPair.pair.quote assetPair.pair.base  type_ ammount price assetPair.pair.base.fee CompletedTransactionRequestSubmited assetPair.pair.primaryName)
                                                                       Nothing ->
                                                                          ({model | modalVisibility = Validation , messageTitle= "Validation ", message = "Ammount should be a number"}, Cmd.none)

                                                               Nothing ->
                                                                 ({model | modalVisibility = Validation , messageTitle= "Asset error", message = "THe pair could not be found"}, Cmd.none)
                                                         Nothing ->
                                                             ({model | modalVisibility = Validation , messageTitle= "Asset error", message = "THe pair could not be found"}, Cmd.none)
                                                 Nothing ->
                                                     ({model | modalVisibility = Validation , messageTitle= "Server error", message = "Values could not be aquired from server"}, Cmd.none) 
                                   Nothing ->
                                       ({model | modalVisibility = Validation , messageTitle= "Asset error", message = "Asset pair could not be assembled"}, Cmd.none)

                           Nothing ->
                               ({model | modalVisibility = Validation , messageTitle= "Asset error", message = "No currency was selected"}, Cmd.none)

                   Nothing ->
                        ({model | modalVisibility = Validation , messageTitle= "Asset error", message = "No currency target was selected"}, Cmd.none)

      _ ->
         ({model | modalVisibility = Validation , messageTitle= "Asset error", message = "Cryptocurrencies could not be aquired from server"}, Cmd.none)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
       FadeInFadeOut ->
            ( { model
                | style =
                    Animation.interrupt
                        [ Animation.to
                            [ Animation.opacity 0
                            ]
                        , Animation.to
                            [ Animation.opacity 1
                            ]
                        ]
                        model.style
              }
            , Cmd.none
            )

       Animate asPerAn animMsg ->
           let
                assetPa = { asPerAn | 
                     animation = Animation.update animMsg asPerAn.animation}

                assetPairNew = 
                    case model.assetPairsCurr of
                        Loaded assetPairs ->
                            Loaded (LE.updateIf (\pairI -> String.contains pairI.pair.primaryName  assetPa.pair.primaryName) (\pairOr -> assetPa) assetPairs)
                        _ ->
                            Loading
           in
            ( { model
               | assetPairsCurr = assetPairNew
              }
            , Cmd.none
            )
       ToLoginPage ->
           (model, Navigat.load (Route.routeToString Route.Login ))

       SessionExpired ->
           (model, Cmd.batch [Api.clearLogInfo, Navigat.load (Route.routeToString Route.Login)])

       ScrollBuy  assetPairCurr quantity ->
           let
               md = 
                   { model | first = Just assetPairCurr.base , second = Just assetPairCurr.quote, window = Buy}
               (model2, som) = valueChange (String.fromFloat quantity) md  
               (modelNew, command)  = exchangeRequestCreator model2 1

           in
           (modelNew, Cmd.batch[scrolUp "",command])

       Expand var ->
           ({model| expanded = var}, Cmd.none)

       GetMetaInfoGroup (Err error) ->
            ( model, Cmd.none)

       ItemMsg pair ->
             ({ model | selectedPair = Just pair, myDrop1State = Dropdown.initialState}, Cmd.none)

       MyDrop2Msg state ->
           ( {model | myDrop2State = state}, Cmd.none)

       MyDrop1Msg state ->
            ( { model | myDrop1State = state }
            , Cmd.none
            )
       MyDropMsgPackages state ->
           ({model | myDropStatePackages = state}, Cmd.none)

       CompletedFeedLoad (Ok feed) ->
            ( { model | feed = Loaded feed}
              ,
               Cmd.batch[
                 getTradableAssetPairs
              ]
            )

       CompletedFeedLoad (Err error) ->
           let
               _ = Debug.log "the error" error
           in
            ( { model | feed = Failed }, Cmd.none )

       GetMetaInfoGroup (Ok krakenResponse) ->
           let
                model_new = {model | feedMeta = Just krakenResponse.assetInfo}
           in
           update (ChangeFromNumb  model_new.fromNumberString) model_new

       GetMetaInfoGroupDict krakenResponse ->
           let
               model_new = {model | feedMeta = Just krakenResponse}
           in
           update (ChangeFromNumb  model_new.fromNumberString) model_new

       CloseModalValidation ->
           ({model | modalVisibility = Invisible, message = "", messageTitle = ""}, Cmd.none)

       CloseModal action token->
         case action of
             1 ->
              ( { model | modalVisibility = Visible, message = "", messageTitle = "" , modalAction = 3, modalToken = "" }
              , exchangeRequestVerification model.session token CompletedTransactionRequestSubmited
              )
             2 ->
              ( { model | modalVisibility = Invisible, message = "", messageTitle = "" , modalAction = 2, modalToken = "", modalTransaction = Nothing }
              , Navigat.load (Route.routeToString Route.Article ) 
              )
             _ ->
              ( { model | modalVisibility = Invisible, message = "", messageTitle = "" , modalAction = 2, modalToken = "", modalTransaction = Nothing }
              , Cmd.none 
              )

       ShowModal ->
            ( { model | modalVisibility =Visible }
            , Cmd.none
            )

       SendRequest ->
           {--let
               modelNew = {model | modalVisibility = Visible, modalAction = 3}
           in--}
           case model.window of
               Sell ->
                   exchangeRequestCreator model 2
               Buy ->
                   exchangeRequestCreator model 1
               Exchange ->
                   exchangeRequestCreator model 3

       CompletedTransactionRequestSubmited (Err httpError) ->
           let
               _ = Debug.log "errrrr" httpError
           in
           case httpError of
               BadStatuss metadata body ->
                   let
                       result = (Json.Decode.decodeString string body)
                   in
                   case result of
                       Err error ->
                           case metadata.statusCode of
                               401 ->
                                   let
                                      md = {model | message = " ", messageTitle = "",  showDialog = True, modalAction = 4}
                                   in
                                   update ShowModal md

                               _ ->
                                  let
                                     md = {model | message = "Unkonwn error", messageTitle = "Error!",  showDialog = True, modalAction = 2}
                                  in
                                  update ShowModal md
                       Ok sthing ->
                           let
                               md = {model | message = sthing, messageTitle = "Error!",  showDialog = True, modalAction = 2}
                           in
                           update ShowModal md
               _ ->
                   (model, Cmd.none)

       CompletedTransactionRequestSubmited (Ok respMsg) ->
           let
            (_, data) = respMsg
            _ = Debug.log "resp" data.transaction
            md = 
              case data.status of
                  2 ->
                    let
                        _ = Debug.log "TRnsaction " data.transaction
                    in
                    {model | message = "It will be processed soon", messageTitle = "Successfully submited transaction", showDialog = True, modalTransaction = Just data.transaction, modalAction = 2} 
                  1 ->
                    let
                        _ = Debug.log "TRnsaction " data.transaction
                    in 
                    {model | message = "Please verify your request", modalAction = 1, modalToken = data.token, messageTitle = "Verification needed", showDialog = True, modalTransaction = Just data.transaction, response = Just data}
                  _ ->
                    model  
           in
           ({md | modalVisibility = Visible}, Cmd.none)

       ChangeWindow action->
           case action of
               Exchange ->
                   case model.assetPairsCurr of
                       Loaded assetPairs ->
                           let
                              pairs = List.filter (\assetPair -> not (String.contains "EUR" assetPair.pair.quote.title )) assetPairs
                           in
                           case List.head pairs of
                               Just pair ->
                                   let 
                                       md = {model | first = Just pair.pair.base, second = Just pair.pair.quote, window = action}
                                   in
                                   update UpdateDueToWindow md
                               Nothing ->
                                   (model, Cmd.none)

                       _ ->
                           (model, Cmd.none)
               Buy ->
                   case model.assetPairsCurr of
                       Loaded assetPairs ->
                           let
                              pairs = List.filter (\assetPair ->  (String.contains "EUR" assetPair.pair.quote.title )) assetPairs
                           in
                           case List.head pairs of
                               Just pair ->
                                   let
                                       md = {model | first = Just pair.pair.base, second = Just pair.pair.quote, window = action}
                                   in
                                   update UpdateDueToWindow md
                               Nothing ->
                                   (model, Cmd.none)

                       _ ->
                           (model, Cmd.none)

               Sell ->
                   case model.assetPairsCurr of
                       Loaded assetPairs ->
                           let
                              pairs = List.filter (\assetPair ->  (String.contains "EUR" assetPair.pair.quote.title )) assetPairs
                           in
                           case List.head pairs of
                               Just pair ->
                                   let 
                                       md = {model | first = Just pair.pair.base, second = Just pair.pair.quote, window = action}
                                   in
                                   update UpdateDueToWindow md
                               Nothing ->
                                   (model, Cmd.none)

                       _ ->
                           (model, Cmd.none)

       FirstSet parameter ->
           case model.assetPairsCurr of
               Loaded assetPairs ->
                 let
                   list =  List.filter (\assetPair -> assetPair.pair.base == parameter) assetPairs
                   assetPairsFiltered =
                         case model.window of
                             Exchange ->
                                 let
                                     listAll = List.filter (\assetPair -> not (String.contains "EUR" assetPair.pair.quote.title ) && assetPair.pair.base == parameter) assetPairs
                                 in
                                 listAll 
                             _ ->
                                List.filter (\assetPair -> (String.contains "EUR" assetPair.pair.quote.title && assetPair.pair.base == parameter))  assetPairs

                   secondFirst = List.head assetPairsFiltered
                   md = 
                       case secondFirst of
                           Just assetPair ->
                              {model | first = Just parameter , second =Just assetPair.pair.quote}
                           Nothing ->
                              {model | first = Just parameter, second = Nothing}
                 in
                 update (ChangeFromNumb  model.fromNumberString) md
               _ ->
                   (model, Cmd.none)

       SecondSet parameter ->
           let
               md = { model | second = Just parameter}
           in
           update (ChangeFromNumb  model.fromNumberString) md

       
       ChangeFromNumb val ->
           case model.window of 
               Sell ->
                 valueChange  model.fromNumberString model
               _ ->
                 valueChange  model.toNumberString model

       UpdateDueToWindow ->
           case model.window of 
               Sell ->
                 valueChange  "1" model
               _ ->
                 valueChange  "1" model


       ChangeFromNumbHand val ->
           let
               _ = Debug.log "The valueee 222########################33333" val
           in
           valueChange val model

       ChangeToNumb val ->
           let
               _ = Debug.log "The valueee ------------------------> " val
           in
           valueChange val model

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
                    
                    mdNew = gotAssetPairCurr model assetPairCurr

                 in
                 (mdNew , Cmd.batch [fetchMetaInfoGroupCsv theStringFinal GetMetaInfoGroup, sendSubscribeMessageString listOfStringForSub ])
               _ ->
                ({model | tradablePairs = Loaded resp.assetPairs}, Cmd.none)

       TradablePairs (Err httpErr) ->
           (model, Cmd.none)

       GoTo index ->
           case model.things of 
               Loaded thingsM ->
                 ({ model | things = Loaded (Paginate.goTo index thingsM) }, Cmd.none)
               _ -> 
                 (model, Cmd.none)

       Next ->
           case model.things of 
               Loaded thingsM ->
                 ({ model | things = Loaded (Paginate.next thingsM) }, Cmd.none)
               _ -> 
                 (model, Cmd.none)

       Prev ->
           case model.things of 
               Loaded thingsM ->
                 ({ model | things = Loaded (Paginate.prev thingsM) }, Cmd.none)
               _ -> 
                 (model, Cmd.none)

       First ->
           case model.things of 
               Loaded thingsM ->
                 ({ model | things = Loaded (Paginate.first thingsM) }, Cmd.none)
               _ -> 
                 (model, Cmd.none)

       Last ->
           case model.things of 
               Loaded thingsM ->
                 ({ model | things = Loaded (Paginate.last thingsM) }, Cmd.none)
               _ -> 
                 (model, Cmd.none)


       GotAssetPairCurr assetPairCurr ->
           let
                    (firstIcon, secondIcon, pair) =
                      case model.config of 
                          Just config ->
                              let
                                theListPre = List.filter (\assetPair -> assetPair.base.id == config.currencyId && (String.contains "EUR" assetPair.quote.title)) assetPairCurr
                              in
                              case List.head theListPre of
                                  Just assetPair ->
                                    (Just assetPair.base, Just assetPair.quote, Just assetPair)
                                  Nothing -> 
                                   case List.head assetPairCurr of
                                     Just assetPair ->
                                        (Just assetPair.base, Just assetPair.quote, Just assetPair)
                                     Nothing ->
                                        (Nothing, Nothing, Nothing)

                          Nothing ->
                              let
                                 theListPre = List.filter (\assetPair ->  (String.contains "EUR" assetPair.quote.title)) assetPairCurr
                              in
                              case List.head theListPre of
                                Just assetPair ->
                                    (Just assetPair.base, Just assetPair.quote, Just assetPair)
                                Nothing ->
                                    (Nothing, Nothing, Nothing)
                      
                    (ammountTo, ammountToString, firstChange) = 
                        case model.config of
                            Just config ->
                                (config.ammount, String.fromFloat config.ammount, False)
                            Nothing ->
                                (0, "0", True)
                    filterPricesAss = List.filter (\pairSing -> String.contains "EUR" pairSing.quote.alias_sort) assetPairCurr
                    asetPairAnim = List.map (\aset -> AssetPairCurrencyAnimation aset (Animation.style  [ Animation.opacity 1.0  ])   ) assetPairCurr

           in
           ({ model | first = firstIcon, second = secondIcon, selectedPair = pair,things = Loaded (Paginate.fromList 5 filterPricesAss ) ,assetPairsCurr = Loaded asetPairAnim, toNumberString = ammountToString, changeFirst = firstChange}, Cmd.none)

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
                                pair = 
                                  case get_val of
                                    Just content ->
                                       let
                                         (a, b) = content
                                       
                                         list =   List.filter (\assetPairCurr -> (String.contains a assetPairCurr.pair.base.title && String.contains b assetPairCurr.pair.quote.title) ) assetPairs
                                         head = List.head list
                                       in
                                       case head of
                                             Just asPerAn ->
                                                 let
                                                   assetPa = 
                                                     case findCurrencyPrice asPerAn.pair model model.window of
                                                       Just numb ->
                                                           case String.toFloat data.metaInf.a.price of
                                                               Just numb2 ->
                                                                  if numb /= numb2 then
                                                                     { asPerAn | 
                                                                        animation = Animation.interrupt 
                                                                           [ Animation.repeat 3 [Animation.to [ Animation.opacity 0], Animation.to [ Animation.opacity 1]] ] asPerAn.animation}
                
                                                                  else 
                                                                     asPerAn
                                                               Nothing ->
                                                                   asPerAn
                                                       Nothing ->
                                                           asPerAn
                                                 in
                                                Just assetPa
                                             Nothing ->
                                                 Nothing

                                    Nothing ->
                                      Nothing

                                newFeedMeta = 
                                    case pair of 
                                        Just assetPair ->
                                            Dict.insert assetPair.pair.primaryName data.metaInf dictMeta
                                        Nothing ->
                                            dictMeta
                                assetPairNew = 
                                    case pair of
                                        Nothing ->
                                            assetPairs
                                        Just pairAt ->
                                            LE.updateIf (\pairI -> pairI.pair.primaryName == pairAt.pair.primaryName) (\pairOr -> pairAt) assetPairs

                                md = {model | feedMeta = Just newFeedMeta , assetPairsCurr = (Loaded assetPairNew) }
                            in
                            update (ChangeFromNumb model.fromNumberString) md

                        Nothing ->
                            (model, Cmd.none)
                    _ ->
                        (model, Cmd.none)
                    
                Err error ->
                    (model, Cmd.none)

gotAssetPairCurr : Model -> (List AssetPairCurrency) -> Model
gotAssetPairCurr model assetPairCurr =  
           let
                    (firstIcon, secondIcon, pair) =
                      case model.config of 
                          Just config ->
                              let
                                theListPre = List.filter (\assetPair -> assetPair.base.id == config.currencyId && (String.contains "EUR" assetPair.quote.title)) assetPairCurr
                              in
                              case List.head theListPre of
                                  Just assetPair ->
                                    (Just assetPair.base, Just assetPair.quote, Just assetPair)
                                  Nothing -> 
                                   case List.head assetPairCurr of
                                     Just assetPair ->
                                        (Just assetPair.base, Just assetPair.quote, Just assetPair)
                                     Nothing ->
                                        (Nothing, Nothing, Nothing)

                          Nothing ->
                              case List.head assetPairCurr of
                                Just assetPair ->
                                    (Just assetPair.base, Just assetPair.quote, Just assetPair)
                                Nothing ->
                                    (Nothing, Nothing, Nothing)
                      
                    (ammountTo, ammountToString, firstChange) = 
                        case model.config of
                            Just config ->
                                (config.ammount, String.fromFloat config.ammount, False)
                            Nothing ->
                                (0, "0", True)
                    asetPairAnim = List.map (\aset -> AssetPairCurrencyAnimation aset (Animation.style  [ Animation.opacity 1.0  ])) assetPairCurr
                    md = { model | first = firstIcon, second = secondIcon, selectedPair = pair, assetPairsCurr = Loaded asetPairAnim, toNumberString = ammountToString, changeFirst = firstChange}
           in
           md


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


getPriceFromCurrency : Model -> AssetPairCurrency -> ActionWindow  -> Float -> Bool -> Maybe Float
getPriceFromCurrency model assetPair action  ammount changeFirst =
  case model.feedMeta of
      Just dict ->
          case findCurrencyPrice assetPair model action of
                     Just cost ->
                            case action of
                               Sell ->
                                  let
                                    _ = Debug.log "amount" ammount
                                    _ = Debug.log "rate" cost
                                    units = ammount * cost
                                    unitsAfter = units - (units * assetPair.base.fee/100) 
                                  in
                                  Just (Round.roundNum assetPair.base.decimals unitsAfter)
                               _ ->
                                  let
                                    units = ammount/cost
                                    unitsAfter = units - (units * assetPair.base.fee/100) 
                                  in
                                  Just (Round.roundNum assetPair.base.decimals unitsAfter)

                     Nothing ->
                         Nothing

      Nothing ->
          Nothing

getPriceFromCurrencyView : Model -> AssetPairCurrency -> ActionWindow  -> Float -> Bool -> Maybe Float
getPriceFromCurrencyView model assetPair action  ammount changeFirst =
  case model.feedMeta of
      Just dict ->
          case findCurrencyPrice assetPair model model.window of
                     Just cost ->
                            case action of
                               Sell ->
                                  let
                                    units = ammount * cost
                                    unitsAfter = units - (units * assetPair.base.fee/100) 
                                  in
                                  Just (Round.roundNum assetPair.base.decimals unitsAfter)
                               _ ->
                                  let
                                     costPre = cost * ammount
                                     costEnd = costPre + (costPre * (assetPair.base.fee/100))
                                  in
                                  Just (Round.roundNum assetPair.quote.decimals costEnd)

                     Nothing ->
                         Nothing

      Nothing ->
          Nothing




findCurrencyPrice : AssetPairCurrency -> Model -> ActionWindow -> Maybe Float
findCurrencyPrice assetPair model action =
    case model.window of
        Sell ->
            case model.feedMeta of
                Just dict ->
                  case Dict.get assetPair.primaryName dict of
                      Just assetMeta ->
                        String.toFloat assetMeta.b.price
                      Nothing ->
                          case Dict.get assetPair.alternateName dict of
                              Just metaInf ->
                                  String.toFloat metaInf.b.price
                              Nothing ->
                                  Nothing
                Nothing ->
                    Nothing

        _ ->
            case model.feedMeta of
                Just dict ->
                  case Dict.get assetPair.primaryName dict of
                      Just assetMeta ->
                        String.toFloat assetMeta.a.price
                      Nothing ->
                          case Dict.get assetPair.alternateName dict of
                              Just metaInf ->
                                  String.toFloat metaInf.a.price
                              Nothing ->
                                  Nothing
                Nothing ->
                    Nothing


valueChange : String -> Model -> (Model, Cmd Msg)
valueChange val model =
     case String.toFloat val of
                      Nothing ->
                          (model, Cmd.none)
                          
                      Just numb ->
                          case model.first of 
                              Just first ->
                                  case  model.second of
                                      Just second ->
                                         case model.assetPairsCurr of
                                             Loaded pairs ->
                                                 let
                                                     pairsFiltered = List.filter (\pair -> pair.pair.base == first && pair.pair.quote == second) pairs
                                                 in
                                                 case List.head pairsFiltered of
                                                     Just thePair ->
                                                            let 
                                                               endResult = getPriceFromCurrency model thePair.pair model.window numb model.changeFirst
                                                            in
                                                            case endResult of 
                                                                 Just res ->
                                                                    case model.window of
                                                                        Sell ->
                                                                           ({model |  fromNumberString = (String.fromFloat numb),toNumberString = (String.fromFloat res)}, Cmd.none) 

                                                                        _ ->
                                                                           ({model |  fromNumberString = (String.fromFloat res),toNumberString = val}, Cmd.none) 
                                                                 Nothing ->
                                                                    ({model |  fromNumberString = "n/a",toNumberString = (String.fromFloat numb)}, Cmd.none) 
                                                     Nothing ->
                                                         ({model | toNumberString = "n/a", fromNumberString = val}, Cmd.none)

                                             _ ->
                                                 ({model | toNumberString ="n/a" ,fromNumberString = val}, Cmd.none)
      
                                      Nothing ->
                                         ({model | toNumberString = "n/a", fromNumberString = val}, Cmd.none)
      
                              Nothing ->
                                  ({model | toNumberString = "n/a", fromNumberString = val}, Cmd.none)


 



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

sendSubscribeMessageString : List String -> Cmd Msg
sendSubscribeMessageString pairs = 
    let
       dictS = (Dict.fromList [ ("name", "ticker")])
       subs = RegisterTopic "subscribe" pairs dictS
       json_subs = encode subs
       command = (sendReq json_subs)
    in
    command

subscriptions : Model -> Sub Msg
subscriptions model =
    let
        animSubs = 
            case model.assetPairsCurr of
                Loaded assetPairs ->
                    (List.map (\assetPair -> Animation.subscription (Animate assetPair) [assetPair.animation]) assetPairs)
                _ ->
                    []
    in
    Sub.batch 
    ([
      Dropdown.subscriptions model.myDrop1State MyDrop1Msg
    , Dropdown.subscriptions model.myDropStatePackages MyDropMsgPackages
    , Dropdown.subscriptions model.myDrop2State MyDrop2Msg
    , receiveVal Receive
    ] ++ animSubs)



