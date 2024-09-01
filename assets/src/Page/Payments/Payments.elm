port module Page.Payments.Payments exposing (Model, Msg, init, subscriptions, toSession, update, view, viewModal)

import Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http

import Api
import Paginate exposing (..)
import Json.Encode as E
import Json.Decode.Pipeline exposing (required, optional, hardcoded)
import Json.Decode exposing (list, string, Decoder, field, map5, decodeString, errorToString, nullable, float, int)
import Dict exposing (Dict)
import Bootstrap.Modal as Modal
import Bootstrap.Button as Button
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid as Grid
import Asset
import Bootstrap.Dropdown as BDropdown
import Bootstrap.Button as BButton
import Api2.Happy exposing (getAvailableBanks, getMonetaryCurrencies, getActiveCurrencies, getDepositRequest, ErrorDetailed, getBaseUrl)
import Api2.Data exposing (Deposit, CurrencyResponse, BankResponse, UserDeposits, BankDetails, Currency, Withdraw, decoderWithdraw, decoderWithdrawResponse , WithdrawResponse, depositDecoder)
import Http.Detailed
import Page.Payments.Deposit as DepositP exposing(Status(..))
import Page.Payments.Withdraw as WithdrawP exposing(Status(..))
import Page.Exchange.Transactions as TransP
import Page.Exchange.TransactionsView as TransView

port renderCaptcha : String -> Cmd msg
port setRecaptchaToken : (String -> msg) -> Sub msg

type alias Model = 
  {
    session: Session
    , depositModel : DepositP.Model
    , withdrawModel : WithdrawP.Model
    , monetary_cur : Status CurrencyResponse
    , content : Maybe Pagination
    , trans : List Deposit
    , transactions : List DepositWithdraw
    , window : ActionWindow
    , messageTitle : String
    , lastSubmitedDeposit : Maybe Deposit
    , modalResponseVisibility : Modal.Visibility
    , message : String
    , modelTransaction : TransP.Model 
  }


init : Session -> (Model, Cmd Msg)
init session = 
  let
      (modelDepo, cmdsD) = DepositP.init session
      (modelWithdraw, cmdsW) = WithdrawP.init session
      (transModel, cmd) = TransP.init session  Nothing
      md = 
          { session = session
          , depositModel = modelDepo
          , withdrawModel = modelWithdraw
          , monetary_cur = Loading
          , transactions = []
          , window = Deposit
          , content = Nothing
          , trans = []
          , messageTitle = ""
          , lastSubmitedDeposit = Nothing
          , modalResponseVisibility = Modal.hidden
          , message = ""
          , modelTransaction = transModel
          }
  in
  (md, Cmd.batch
       [ getDepositRequest md.session CompletedTransactionRequestLoad
       , getMonetaryCurrencies md.session CompletedMonetaryLoad
       , getActiveCurrencies md.session CompletedFeedLoad
       , getWithdrawalls md
       , (Cmd.map (\depoM -> (DepositMsg depoM)) cmdsD)
       , (Cmd.map (\tr -> (TransactionMsg tr)) cmd)
       , (Cmd.map (\withM -> (WithdrawMsg withM)) cmdsW)
       ])


type ActionWindow 
    = Deposit
    | Withdraw


type alias WalletLocal = 
    {
      public_key: String
    }


type alias DepositWithdraw = 
    {
        withdraw : Maybe Withdraw
    ,   deposit  : Maybe Deposit
    } 


getWithdrawalls : Model -> Cmd Msg
getWithdrawalls model =
    Http.request
        { headers =
            case Session.cred model.session of
                Just cred ->
                    [ Api.credHeader cred ]

                Nothing ->
                    []
        , method = "GET"
        , body = Http.emptyBody
        , url = (getBaseUrl ++ "/api/v1/transaction/user/withdraw")
        , expect = Http.expectJson CompletedWithdrawLoad decoderWithdrawResponse
        , timeout = Nothing
        , tracker = Nothing
        }


deleteWithdraw : Model -> Int  -> Cmd Msg
deleteWithdraw model id =
    Http.request
        { headers =
            case Session.cred model.session of
                Just cred ->
                    let
                        _ =
                            Debug.log "cred" (Api.credHeader cred)
                    in
                    [ Api.credHeader cred ]

                Nothing ->
                    []
        , method = "Delete"
        , body = Http.emptyBody
        , url = (getBaseUrl ++ "/api/v1/transaction/withdraw/" ++ (String.fromInt id))
        , expect = Http.Detailed.expectJson CompletedWithdrawDeletion decoderWithdraw
        , timeout = Nothing
        , tracker = Nothing
        }


deleteDeposit : Model -> Int  -> Cmd Msg
deleteDeposit model id =
    Http.request
        { headers =
            case Session.cred model.session of
                Just cred ->
                    let
                        _ =
                            Debug.log "cred" (Api.credHeader cred)
                    in
                    [ Api.credHeader cred ]

                Nothing ->
                    []
        , method = "Delete"
        , body = Http.emptyBody
        , url = (getBaseUrl ++ "/api/v1/transaction/deposit/" ++ (String.fromInt id))
        , expect = Http.Detailed.expectJson CompletedDepositDeletion depositDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


iconDeposit : Html msg
iconDeposit =
    Html.img
        [ Asset.src Asset.deposit
        , style "width" "30vw"
        , style "height" "30vh"
        , style "margin-bottom" "5vh"
        , style "margin-top" "5vh"
        , alt ""
        ]
        []

type Status a
    = Loading
    | LoadingSlowly
    | Loaded a
    | Failed

type alias Pagination = 
    { pairs : PaginatedList DepositWithdraw
    , reversed : Bool
    , query : String
    , globalId : Int
   }

type Msg
  = GotSession Session
    | DropdownChanged (Maybe String)
    | CompletedTransactionRequestLoad (Result Http.Error (UserDeposits))
    | CompletedWithdrawDeletion (Result (Http.Detailed.Error String) (Http.Metadata, Withdraw))
    | CompletedDepositDeletion (Result (Http.Detailed.Error String) (Http.Metadata, Deposit))
    | Next
    | Prev
    | First
    | Last
    | GoTo Int
    | CompletedMonetaryLoad (Result Http.Error (CurrencyResponse))
    | CompletedFeedLoad (Result Http.Error (CurrencyResponse))
    | CloseModalResponse
    | ShowModalResponse
    | AnimateResponseModal Modal.Visibility
    | ChangeWindow ActionWindow
    | CompletedWithdrawLoad (Result Http.Error WithdrawResponse)
    | DeleteWithdraw Int
    | DeleteDeposit Int
    | DepositMsg DepositP.Msg
    | WithdrawMsg WithdrawP.Msg
    | TransactionMsg TransP.Msg


viewModalResponse : Model -> String -> Html Msg
viewModalResponse model  msg =
  case model.lastSubmitedDeposit of
    Just dep ->
      case dep.bankDetails of
        Just bankDets ->
         Grid.container []
            [
             Modal.config CloseModalResponse
                |> Modal.h5 [] [ text "Deposit Important Details" ]
                |> Modal.body []
                    [ Grid.containerFluid []
                        [
                            Grid.row []
                            [
                              Grid.col
                              []
                              [  
                                 span[][text "Bank name: "]
                              ]
                            , Grid.col[]
                              [
                                span[][text bankDets.name]
                              ] 
                            ]
                        , Grid.row[]
                          [
                              Grid.col []
                              [
                                  span[][text "Iban"]
                              ]
                            , Grid.col []
                              [
                                  span[][text bankDets.iban]    
                              ]
                          ]
                        , Grid.row[]
                          [
                              Grid.col []
                              [
                                  span[][text "Beneficiary name:"]
                              ]
                            , Grid.col []
                              [
                                  span[][text bankDets.beneficiaryName]    
                              ]
                          ]
                         ]
                       
                    ]
                |> Modal.withAnimation AnimateResponseModal
                |> Modal.footer []
                    [ Button.button
                        [ Button.outlinePrimary
                        , Button.attrs [ onClick <| AnimateResponseModal Modal.hiddenAnimated ]
                        ]
                        [ text "Ok" ]
                    ]
                |> Modal.view model.modalResponseVisibility
            ]
        Nothing ->
          let
            _ = Debug.log "asdfasdfdfasdafssdaf:saddfsadsfa" "asdfdasfdsfadsafdsfadf 23223"
          in
          div[][]
    Nothing ->
       Grid.container []
        [
         Modal.config CloseModalResponse
            |> Modal.h5 [] [ text "Request feedback" ]
            |> Modal.body []
                [ Grid.containerFluid []
                    [
                        Grid.row []
                        [
                          Grid.col
                          []
                          [ 
                            h5[][text model.message] 
                          ]   
                        ]
                    ]
                ]
            |> Modal.withAnimation AnimateResponseModal
            |> Modal.footer []
                [ Button.button
                    [ Button.outlinePrimary
                    , Button.attrs [ onClick <| AnimateResponseModal Modal.hiddenAnimated ]
                    ]
                    [ text "Ok" ]
                ]
            |> Modal.view model.modalResponseVisibility
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
       TransactionMsg transM ->
           let
               (trM, command) = TransP.update transM model.modelTransaction 
           in
           ({model | modelTransaction = trM}, Cmd.map(\transMsg -> TransactionMsg transMsg) command)

       DepositMsg depositMsg ->
           case depositMsg of 
               DepositP.CompletedTransactionRequestSubmited (Ok (metada, result)) ->
                 case model.content of 
                     Just pagination ->
                       let
                         (depModel , cmnd) = DepositP.update depositMsg model.depositModel
                         old_trans = Paginate.allItems pagination.pairs
                         list = List.filter (\dep -> 
                             case dep.deposit of
                               Just depo ->
                                 ( not (depo.id == result.id))
                               Nothing ->
                                 True
                            ) old_trans 
                         new_list = (DepositWithdraw Nothing (Just result))::list        
                         p_list = Paginate.fromList 10 new_list 
                         content_c = { pairs = p_list, reversed = False, query = "", globalId = 1}
                       in
                       ({ model | depositModel = depModel, content = Just content_c}, Cmd.map(\depM -> (DepositMsg depM)) cmnd)
                     Nothing ->
                       let
                         (depModel , cmnd) = DepositP.update depositMsg model.depositModel
                       in
                       ({ model | depositModel = depModel}, Cmd.map(\depM -> (DepositMsg depM)) cmnd)

               _ ->
                 let
                    (depModel , cmnd) = DepositP.update depositMsg model.depositModel
                 in
                 ({ model | depositModel = depModel}, Cmd.map(\depM -> (DepositMsg depM)) cmnd)

       WithdrawMsg withdrawM ->
           case withdrawM of
               WithdrawP.CompletedWithdrawRequestSubmited (Ok(metadata, result)) ->
                   case model.content of 
                       Just pagination ->
                         let
                            old_trans = Paginate.allItems pagination.pairs
                            list = List.filter (\with -> 
                                case with.withdraw of
                                  Just wit ->
                                      case result.withdraw of 
                                          Just withRes ->
                                              ( not (wit.id == withRes.id))
                                          Nothing ->
                                              True
                                  Nothing ->
                                     True
                                ) old_trans 
                            new_list =
                                case result.withdraw of 
                                    Just withRes ->
                                      (DepositWithdraw  (Just withRes) Nothing)::list 
                                    Nothing ->
                                      list
                            p_list = Paginate.fromList 10 new_list 
                            content_c = { pairs = p_list, reversed = False, query = "", globalId = 1}
                            (withModel , cmnd) = WithdrawP.update withdrawM model.withdrawModel
                         in
                         ({model | content = Just content_c, withdrawModel = withModel}, Cmd.none)

                       Nothing ->
                         let
                            (withModel , cmnd) = WithdrawP.update withdrawM model.withdrawModel
                         in
                          ({ model | withdrawModel = withModel}, Cmd.map(\with -> (WithdrawMsg with)) cmnd)
               _ ->
                 let
                   (withModel , cmnd) = WithdrawP.update withdrawM model.withdrawModel
                 in
                 ({ model | withdrawModel = withModel}, Cmd.map(\with -> (WithdrawMsg with)) cmnd)

       DeleteWithdraw id ->
           (model , deleteWithdraw model id)

       DeleteDeposit id ->
           (model , deleteDeposit model id)

       CompletedDepositDeletion (Ok (metadata, result)) ->
                   let
                       _ = Debug.log "som " "some"
                   in
                   case model.content of 
                       Just pagination ->
                         let
                           old_trans = Paginate.allItems pagination.pairs
                           list = List.filter (\dep -> 
                               case dep.deposit of
                                 Just depo ->
                                   ( not (depo.id == result.id))
                                 Nothing ->
                                   True
                              ) old_trans 
                           p_list = Paginate.fromList 10 list 
                           content_c = { pairs = p_list, reversed = False, query = "", globalId = 1}
                         in
                         ({model | content = Just content_c}, Cmd.none)
                       Nothing ->
                           (model, Cmd.none)
 
       CompletedDepositDeletion (Err error) ->
           let
               _ = Debug.log "some" error
           in
           (model, Cmd.none)

       CompletedWithdrawDeletion (Ok (metadata, result)) ->
               case model.content of 
                   Just pagination ->
                       let
                            old_trans = Paginate.allItems pagination.pairs
                            list = List.filter (\with -> 
                                case with.withdraw of
                                  Just wit ->
                                     ( not (wit.id == result.id))
                                  Nothing ->
                                     True
                                ) old_trans 

                            p_list = Paginate.fromList 10 list 
                            content_c = { pairs = p_list, reversed = False, query = "", globalId = 1}
                        in
                        ({model | content = Just content_c}, Cmd.none)

                   Nothing ->
                        (model, Cmd.none)

       CompletedWithdrawDeletion (Err error) ->
           let
               _ = Debug.log "skepsu" error
           in
           (model, Cmd.none)
       {--
       CompletedWithdrawRequestSubmited(Err error) ->
           let
               _  = Debug.log "Eroor" error
           in
           case error of
             Http.Detailed.BadStatus metadata body ->
               let
                   errorResult = decodeString (field "error" string) body
               in
               case errorResult of 
                   Ok errorStr ->
                       let
                           _ = Debug.log "stagg here: " errorStr
                       in
                     ({model | message = errorStr, modalResponseVisibility = Modal.shown}, Cmd.none)
                   _  ->
                     ({model | message = "Unknwon ERROR", modalResponseVisibility = Modal.shown}, Cmd.none)

             _ ->
               ({model| message = "Unknown ERROR", modalResponseVisibility = Modal.shown}, Cmd.none)
--}
       ChangeWindow action ->
           ({model | window = action}, Cmd.none)

       AnimateResponseModal visibility ->
           ({ model | modalResponseVisibility = visibility}, Cmd.none)

       CloseModalResponse ->
           ( { model | modalResponseVisibility = Modal.hidden, lastSubmitedDeposit = Nothing}, Cmd.none)

       ShowModalResponse ->
           ( { model | modalResponseVisibility = Modal.shown}, Cmd.none)
  
       GotSession session ->
         ({model |session = session}, Cmd.none)

       DropdownChanged sth ->
         (model, Cmd.none)      

       CompletedMonetaryLoad (Ok feed) ->
            let
                initFromCurr = List.head feed.currencies
                initCurTitle = currencyToTitle initFromCurr
                depM = model.depositModel 
                depNew = {depM | monetary_cur = DepositP.Loaded feed, currency =initFromCurr}
                withM = model.withdrawModel
                withNew = {withM | monetary_cur = WithdrawP.Loaded feed, currencyTitleWithdraw = initCurTitle, currency = initFromCurr}
            in
            ({model | monetary_cur = Loaded feed,{-- currencyTitleWithdraw = initCurTitle--} depositModel = depNew, withdrawModel = withNew}, Cmd.none)

       CompletedMonetaryLoad (Err error) ->
           (model, Cmd.none)

       CompletedFeedLoad (Err error) ->
            (model, Cmd.none )

       CompletedFeedLoad (Ok feed) ->
           let
               _ = Debug.log "action" feed
           in
           (model, Cmd.none)
{--
       CompletedTransactionRequestSubmited (Err error) ->
         let
             _= Debug.log "error getting the staff" (Debug.toString error)
         in
         case error of
             Http.Detailed.BadStatus metadata body ->
               let
                   errorResult = decodeString (field "error" string) body
               in
               case errorResult of 
                   Ok errorStr ->
                       let
                           _ = Debug.log "stagg here: " errorStr
                       in
                     ({model | message = errorStr, modalResponseVisibility = Modal.shown}, Cmd.none)
                   _  ->
                     ({model | message = "Unknwon ERROR", modalResponseVisibility = Modal.shown}, Cmd.none)

             _ ->
               ({model| message = "Unknown ERROR", modalResponseVisibility = Modal.shown}, Cmd.none)
--}
       CompletedTransactionRequestLoad (Err error) ->
         let
             _= Debug.log "error" (Debug.toString error)
         in
         (model, Cmd.none)

       CompletedTransactionRequestLoad (Ok result) ->
         case model.content of 
             Nothing ->
               let
                  _= Debug.log "not the error" (Debug.toString result)
                  trains_c = List.map (\dep -> DepositWithdraw Nothing (Just dep)) result.data
                  p_list = Paginate.fromList 10 trains_c
                  content_c = { pairs = p_list, reversed = False, query = "", globalId = 1}
               in
               ({model |  content = Just content_c}, Cmd.none)

             Just content ->
                 let
                  trains_c = List.map (\dep -> DepositWithdraw Nothing (Just dep)) result.data
                  complete_list = (Paginate.allItems content.pairs) ++ trains_c
                  p_list = Paginate.fromList 10 complete_list
                  content_c = { pairs = p_list, reversed = False, query = "", globalId = 1}
                 in
                  ({model |  content = Just content_c}, Cmd.none)

       CompletedWithdrawLoad (Ok result) ->
           let
               _ = Debug.log "result of withdraw:" result
           in
         case model.content of
            Nothing ->
              let
                 _= Debug.log "not the error" (Debug.toString result)
                 trains_c = List.map (\dep -> DepositWithdraw  (Just dep) Nothing) result.withdrawalls
                 p_list = Paginate.fromList 10 trains_c
                 content_c = { pairs = p_list, reversed = False, query = "", globalId = 1}
              in
              ({ model | content = Just content_c}, Cmd.none)
            Just content ->
                let
                  trains_c = List.map (\dep -> DepositWithdraw  (Just dep) Nothing) result.withdrawalls
                  
                  complete_list = trains_c ++ (Paginate.allItems content.pairs)
                  p_list = Paginate.fromList 10 complete_list
                  content_c = { pairs = p_list, reversed = False, query = "", globalId = 1}
                in
                ({model | content = Just content_c}, Cmd.none)

       CompletedWithdrawLoad (Err error) ->
           let
               _ =Debug.log "error" error
           in
           (model, Cmd.none)

       GoTo index ->
            case model.content of
                Just pgnation -> 
                    let 
                        old_pagination = pgnation
                        new_pagination = { old_pagination | pairs = Paginate.goTo index old_pagination.pairs }
                    in
                    ({ model | content = Just new_pagination}
                    , Cmd.none
                    )
                Nothing ->
                    (model, Cmd.none)

       Next ->
            case model.content of
                Just pgnation -> 
                    let 
                        old_pagination = pgnation
                        new_pagination = { old_pagination | pairs = Paginate.next old_pagination.pairs }
                    in
                    ({ model | content = Just new_pagination}
                     , Cmd.none
                     ) 
                Nothing ->
                    (model, Cmd.none)
 
       Prev ->
            case model.content of
                Just pgnation -> 
                    let 
                        old_pagination = pgnation
                        new_pagination = { old_pagination | pairs = Paginate.prev  old_pagination.pairs }
                    in
                    ({ model | content = Just new_pagination}, Cmd.none)
                Nothing ->
                    (model, Cmd.none)

       First ->
            case model.content of
                Just pgnation -> 
                    let 
                        old_pagination = pgnation
                        new_pagination = { old_pagination | pairs = Paginate.first old_pagination.pairs }
                    in
                    ({ model | content = Just new_pagination}, Cmd.none)
                Nothing ->
                    (model, Cmd.none)

       Last ->
             case model.content of
                Just pgnation -> 
                    let 
                        old_pagination = pgnation
                        new_pagination = { old_pagination | pairs = Paginate.last old_pagination.pairs }
                    in
                    ({ model | content = Just new_pagination}, Cmd.none)
                Nothing ->
                    (model, Cmd.none)


currencyToTitle : Maybe Currency -> Maybe String 
currencyToTitle currency =
    case currency of
        Just curr ->
            Just curr.title
        Nothing ->
            Nothing
   


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Deposits"
    , content =
        case model.content of 
            Nothing ->
              div []
              [exchangeView model
              ] 
            Just pagination ->
              div []
              [
                exchangeView model
              ]
    }

getClass: Model -> ActionWindow -> String
getClass model action =
    case (model.window == action) of
        True ->
            "panel_button active"
        False ->
            "panel_button"

getClassCol: Model -> ActionWindow -> String
getClassCol model action =
    case (model.window == action) of
        True ->
            "panel_col active"
        False ->
            "panel_col"


binanceView : Model -> Html Msg
binanceView model=
    div[class "container", style "background-color" "white", style "border-radius" "10px", style "padding-top" "2.5vh", style "padding-bottom" "3vh", style "box-shadow" "8px 8px 16px 8px rgba(0.2,0.2,0.2,0.2)"]
    [
      div[class "row"]
      [
           div[class ("col "++ getClassCol model Deposit)][a[href "#pageSubmenu", class (getClass model Deposit), type_ "button",onClick (ChangeWindow Deposit)][text "Deposit"]]
         , div[class ("col "++ getClassCol model Withdraw)][ a[href "#pageSubmenu", class (getClass model Withdraw), type_ "button",onClick (ChangeWindow Withdraw)][text "Withdraw"]]
      ]
     , div[class "row", style "padding-top" "4vh"]
      [
        div[class "col"][depositWithdrawView model]
      ]
    ]

depositWithdrawView : Model -> Html Msg
depositWithdrawView model = 
     div[class "",style "padding-bottom" "5vh", style "padding-right" "0.5%", style "padding-left" "0.5%"]
        [
            case model.window of
                Withdraw ->
                    Html.map (\withMsg -> (WithdrawMsg withMsg)) (WithdrawP.view model.withdrawModel)
                Deposit ->
                    Html.map (\depMsg -> (DepositMsg depMsg)) (DepositP.view model.depositModel)
        ]

viewModal : Model -> Maybe (Html Msg)
viewModal model =
    case model.window of
        Withdraw ->
            case WithdrawP.viewModal model.withdrawModel of
                Nothing ->
                    Nothing
                Just viewSth ->
                    Just (Html.map (\withMsg -> (WithdrawMsg withMsg)) viewSth)

        Deposit ->
            case DepositP.viewModal model.depositModel of
                Nothing ->
                    Nothing
                Just viewSth ->
                    Just (Html.map (\withMsg -> (DepositMsg withMsg)) viewSth)


dateProccess : String -> String
dateProccess date = 
   let
       list =  (String.split "T" date) 
   in
   List.foldr (\first existing -> (first ++ " " ++ existing)) "" list

toTableRow: DepositWithdraw -> Html Msg
toTableRow depositWithdraw =
  case depositWithdraw.deposit of
      Just deposit ->
        tr []
        [ td[style "font-weight" "bold"][text "Deposit"]
        , td[][text deposit.currency.alias_sort]
        , td[][text deposit.status]
        , td[][ text (getWalletOrIban depositWithdraw)]
        , td[][ text (dateProccess deposit.updated_at)]
        , if deposit.status == "created" then
           td[][ button[class "btn btn-danger", onClick (DeleteDeposit deposit.id)][text "Delete"]]
          else
           td[][]
        ]
      Nothing ->
          case depositWithdraw.withdraw of
              Just withdraw ->
                  tr[]
                  [
                    td[style "font-weight" "bold"][text "Withdrawall"]
                  , td[][text withdraw.currency.alias_]
                  , td[][text withdraw.status]
                  , td[][text (getWalletOrIban depositWithdraw) ]
                  , td[][ text (dateProccess withdraw.updated_at)]
                  , if withdraw.status == "created" then
                     td[][ button [class "btn btn-danger", onClick (DeleteWithdraw withdraw.id)][text "Delete"]]
                    else 
                     td[][]
                  ]
              Nothing ->
                  tr[][]

getWalletOrIban : DepositWithdraw -> String
getWalletOrIban depWith =
    case depWith.withdraw of 
        Just withd ->
            case withd.bankAccountDetails of 
                Just bank ->
                    bank.iban
                Nothing ->
                    case withd.wallet of
                        Just wall ->
                            wall.public_key 
                        Nothing ->
                            "N/A"
        Nothing ->
            case depWith.deposit of
                Just deposit ->
                    case deposit.bankDetails of
                        Just bDetails ->
                            bDetails.iban
                        Nothing ->
                            case deposit.wallet of
                                Just wallet ->
                                    wallet.public_key 
                                Nothing ->
                                    "N/A"

                Nothing ->
                    "N/A"

viewPaginated : PaginatedList DepositWithdraw -> Html Msg
viewPaginated transactions=
    let        
        displayInfoView =
            div []
                [ text <|
                    String.join " "
                        [ "page"
                        , String.fromInt <| Paginate.currentPage transactions
                        , "of"
                        , String.fromInt <| Paginate.totalPages transactions
                        ]
                , div[] [ table [class "table",  style "border-color" "white"]
                  ( [
                       thead [class "thead", style "border-top" "0px solid red"]
                       [
                          th [scope "col"] [ text "Action"]   
                       ,  th [scope "col"] [ text "Currency" ]
                       ,  th [scope "col"] [ text "Status"]
                       ,  th [scope "col"] [ text "Wallet Address/Iban"]
                       ,  th [scope "col"] [ text "Date & Time"]
                       ]
                   ] ++  
                   (List.map toTableRow (Paginate.page transactions) ))
                  ]
                ]                
        
        prevButtons =
               button 
                 [
                  style "border-style" "none"
                 , style "background-color" "white"
                 , onClick First
                 , style "font-weight" "bolder"
                 , style "background-color" "transparent"
                 , style "pading" "1rem"
                 , style "border-style" "none"
                 , style "font-size" "1.25rem"

                 , disabled <| Paginate.isFirst transactions
                 ] 
                 [ text "Previous" ]
              

        nextButtons =
              [ button 
                [
                  style "border-style" "none"
                , style "background-color" "white"
                , onClick Next
                , style "font-weight" "bolder"
                , style "background-color" "transparent"
                , style "pading" "1rem"
                , style "border-style" "none"
                , style "font-size" "1.25rem"
                , disabled <| Paginate.isLast transactions ] [ text "Next" ]
              ]

        pagerButtonView index isActive =
                button
                  [ style "color"
                    (if isActive then
                        "rgba(0,99,166,1)"

                     else
                        "rgba(68,68,68,1)"
                    )
                  , style "text-shadow"
                    (if isActive then
                        "1px 0 rgba(0,99,166,1)"

                     else
                        "1px 0 rgba(68,68,68,1)"
                    )
                  , style "border-radius"
                    (if isActive then
                        "80px"

                     else
                        ""
                    )
                  , style "background-color"
                    (if isActive then
                        "white"

                     else
                        "transparent"
                    )
                  , style "font-weight" "bolder"
                  , style "padding" "0.2rem 0.8rem"
                  , style "border-style" "none"
                  , style "font-size" "1.25rem"
                  , onClick <| GoTo index
                  ]
                 [ text <| String.fromInt index ]
        pagerOptions =
                { innerWindow = 1
                , outerWindow = 1
                , pageNumberView = pagerButtonView
                , gapView = text "..."
                }


    in
    div[class "col",  style "padding-top" "50px", style "padding-bottom" "10px"]
                        [
                          div[class "row"]
                          [
                              div[class "col"]
                              [
                                 displayInfoView
                              ]
                          ]
                        , div[class "row justify-content-center" ]
                          [
                              div[class "col-4"]
                              [
                                 div[style "background-color" "rgb(239, 239, 239)", style "border-radius" "50px", style "padding" "5px", class "row justify-content-center"]
                                 [
                                   div[class "col"][prevButtons]
                                 , div[class "col"][(span [style "bakground-color" "rgb(239, 239, 239)"] <| Paginate.elidedPager pagerOptions transactions)]
                                 , div[class "col"]nextButtons
                                 ]

                              ]
                          ]

                        ]



exchangeView : Model ->  Html Msg
exchangeView model =
    case model.monetary_cur of
        Loaded cryptocurencies ->
            div[class "container-xxl", style "padding-bottom" "5vh", style "margin-top" "5vh", style "margin-left" "10%", style "margin-right" "10%"] 
          [
            div[class "row"]
            [
              div[class "col"]
              [
                 span[style "color" "rgba(0,99,166,1)", style "font-size" "3.5rem", style "font-weight" "bolder", style "text-shadow" "1px 0 rgba(0,99,166,1)"][text "DEPOSITS / WITHDRAWALS"]
              ,  br[][]
              ,  img[Html.Attributes.src "/images/line.svg"][]
              ]
            ]
          , div[class "row"]
            [ 
                div[class "col"]
                [
                 viewModalResponse model "markoutsaki"
                ]
            ]
          , div[class "row justify-content-center", style "margin-top" "50px"]
            [
                div[class "col col-md-12 col-lg-5 col-xl-5 col-sm-12 col-xs-12", style "margin-bottom" "40px"]
                [
                  binanceView model
                ]
            ,   div[class "col col-xl-5 col-lg-7"]
                [
                   Html.map(\transCom -> TransactionMsg transCom) (TransView.pricesTable model.modelTransaction 5)
                ]
            ]
            , div[class "row"]
              [
                div[class "col-12"]
                [
                  (case model.content of
                    Just pagination ->
                      viewPaginated pagination.pairs 
                    Nothing ->
                      div[][h1[][text "O kipos einai anthiros" ]]
                   )
                ]
              ]
          ]

        _ ->
           div[][]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
    [ Session.changes GotSession (Session.navKey model.session)
    , Modal.subscriptions model.modalResponseVisibility AnimateResponseModal
    , Sub.map (\msgDep -> DepositMsg msgDep) (DepositP.subscriptions model.depositModel)
    , Sub.map (\msgDep -> WithdrawMsg msgDep) (WithdrawP.subscriptions model.withdrawModel)
    ]


toSession : Model -> Session
toSession model =
    model.session
