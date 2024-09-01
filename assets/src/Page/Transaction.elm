module Page.Transaction exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (attribute, class, scope, disabled, style, href, src, autocomplete, type_)
import Session exposing (Session)
import Json.Decode exposing (list, string, Decoder, field, map5, decodeString, errorToString, nullable, float, int)
import Json.Encode as E
import Json.Decode.Pipeline exposing (required, optional, hardcoded)
import Task exposing (Task)
import Http.Legacy
import Api.Endpoint as Endpoint
import Api exposing (Cred)
import Http exposing (expectJson)
import Paginate exposing (..)
import List.Extra
import Api2.Data exposing (Currency, decoderCurrency, CurrencyResponse, decoderCurrencyResponse, TransactionRequest, decoderTransaction)
import Api2.Happy exposing (getActiveCurrencies2, getBaseUrl)
import Bootstrap.Modal as Modal
import Bootstrap.Button as Button
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid as Grid
import Bootstrap.Dropdown as Dropdown
import DatePicker exposing (DateEvent(..), defaultSettings)
import Time exposing (Weekday(..))
import Date exposing (Date, day, month, weekday, year)
import File.Download as Download
import Route exposing (Route)
import Browser.Navigation as Navigat
import Round

type alias Model = 
    { 
      session : Session
    , trans : List TransactionRequest 
    , content : Status (List TransactionRequest)
    , currentPage : Int
    , pagination : Status (List Page)
    , action : Action
    , currencies : Status (List Currency)
    , currencyId : Maybe String
    , currency : Maybe Currency
    , dropActionState : Dropdown.State
    , dropCurrencyState : Dropdown.State
    , date : Maybe Date
    , toDate : Maybe Date
    , datePicker : DatePicker.DatePicker
    , toDatePicker : DatePicker.DatePicker
    }


type Action =
   Transaction
   | Buy
   | Sell
   | Exchange


init : Session -> (Model, Cmd Msg)
init session  =
    let
        ( datePicker, datePickerFx ) =
            DatePicker.init 
        ( datePickerTo, datePickerFxTo ) =
            DatePicker.init 

        md = { session = session
               , trans = []
               , content = Loading
               , currentPage = 1
               , pagination = Loading
               , action = Transaction
               , currencies = Loading
               , currencyId = Nothing
               , dropActionState = Dropdown.initialState
               , dropCurrencyState = Dropdown.initialState
               , currency = Nothing
               , date = Nothing
               , toDate = Nothing
               , toDatePicker = datePickerTo
               , datePicker = datePicker
             }
    in
    (md, Cmd.batch [ createUpdateCommand md, getActiveCurrencies2 md.session CompletedFeedLoad, Cmd.map FromDatePicker datePickerFx, Cmd.map ToDatePicker datePickerFxTo])


type alias Page =
    {
        current : Bool
    ,   label : String
    ,   page : Int
    ,   url : String
    }

type Status a                  
    = Loading
    | LoadingSlowly            
    | Loaded a
    | Failed

pagesDecoder : Json.Decode.Decoder Page
pagesDecoder =
    Json.Decode.succeed Page
        |> Json.Decode.Pipeline.required "current" Json.Decode.bool
        |> Json.Decode.Pipeline.required "label" string
        |> Json.Decode.Pipeline.required "page" int
        |> Json.Decode.Pipeline.required "url" string

{--type alias Pagination = 
    { pairs : PaginatedList TransactionRequest
    , reversed : Bool
    , query : String
    , globalId : Int
    }--}

type alias TransactionReqResult = 
    { 
        data : List TransactionRequest
      , pagination : List Page
    }

transReqDecoder : Json.Decode.Decoder TransactionReqResult
transReqDecoder = 
    Json.Decode.succeed TransactionReqResult
      |> required "data" (list decoderTransaction)
      |> required "pagination" (list pagesDecoder)

sortAndFilterTrans: List TransactionRequest -> List TransactionRequest
sortAndFilterTrans trans = 
  List.sortBy .id trans

createUpdateCommand : Model -> Cmd Msg
createUpdateCommand model = 
   let
     currencyId = 
         case model.currency of
             Just currency ->
                 String.fromInt currency.id
             Nothing ->
                 "all"
     reqDate = 
         case model.date of 
             Just date ->
                 Date.toIsoString date
             Nothing ->
                 "all"
     toDate = 
         case model.toDate of
             Just date ->
                 Date.toIsoString date
             Nothing ->
                 "all"
     action = 
         case model.action of
             Buy ->
                 "1"
             Sell ->
                "2"
             Exchange ->
                 "3"
             Transaction ->
                  "all"
     headers = 
         case Session.cred (model.session) of
             Just cred ->
                 [ Api.credHeader cred]
             Nothing ->
                 []
   in
    Http.request
    {
     headers = headers
    , method = "GET"
    , body = Http.emptyBody
    , url = (getBaseUrl ++ "/api/v1/transaction/user/transactions/"++ currencyId ++ "/"++action ++ "/"++reqDate++"/"++toDate)
    , expect = expectJson  CompletedTransactionRequestLoad transReqDecoder
    , timeout = Nothing
    , tracker = Nothing
    }


simpleIdEnc : Int -> E.Value
simpleIdEnc id=
    E.object
        [ ( "transaction_id", E.int id )
        ]

getCsvFromRecords : Status (List TransactionRequest) -> String
getCsvFromRecords transactionsM = 
    case transactionsM of
        Loaded transactions ->
            let
                startStr = "FROM_CUR,TO_CURR,AMMOUNT,RATE,RETURN,DATE,STATUS"
            in
            List.foldl(\transaction  static -> (static ++"\n" ++ transaction.srcCurrency.alias_ ++ "," ++ transaction.tgtCurrency.alias_ ++ "," ++ (String.fromFloat transaction.srcAmount) ++ "," ++ (String.fromFloat transaction.exchangeRate)  ++ "," ++ (String.fromFloat (transaction.exchangeRate * transaction.srcAmount))++ ","++ (transaction.updatedAt) ++ "," ++ transaction.status )) startStr transactions 

        _ ->
            ""

getDepositPage : Model -> String -> Cmd Msg
getDepositPage model url =
      Http.request
      {
       headers =
           case Session.cred (model.session) of
               Just cred ->
                   [ Api.credHeader cred]
               Nothing ->
                   []
      , method = "GET"
      , body = Http.emptyBody
      , url = (getBaseUrl  ++ url)
      , expect = Http.expectJson  CompletedTransactionRequestLoad transReqDecoder
      , timeout = Nothing
      , tracker = Nothing
      }


cancelRequestCommand : Model -> Int -> Cmd Msg
cancelRequestCommand model id = 
    Http.request
    {
     headers = 
         case Session.cred (model.session) of
             Just cred ->
                 [ Api.credHeader cred]
             Nothing ->
                 []
    , method = "PUT"
    , body = Http.jsonBody (simpleIdEnc id) 
    , url = (getBaseUrl ++ "/api/v1/transaction/transactions")
    , expect = expectJson  CompletedTransactionRequestLoad transReqDecoder
    , timeout = Nothing
    , tracker = Nothing
    }


settings : DatePicker.Settings
settings =
    let
        isDisabled toDate =
            [  ]
                |> List.member (weekday toDate)
    in
    { defaultSettings
        | isDisabled = isDisabled
        , inputClassList = [ ( "form-control", True ) ]
        , inputName = Just "date"
        , inputId = Just "date-field"
    }

settings2 : DatePicker.Settings
settings2 =
    let
        isDisabled toDate =
            [  ]
                |> List.member (weekday toDate)
    in
    { defaultSettings
        | isDisabled = isDisabled
        , inputClassList = [ ( "form-control", True ) ]
        , inputName = Just "date"
        , inputId = Just "date-field2"
    }

view : Model -> { title : String, content : Html Msg}
view model = 
    { title = "History"
    , content = 
          div[]
          [ 
              case List.isEmpty  model.trans of
                  True ->
                    case model.action of
                        Transaction ->
                            case model.currency of 
                                Nothing ->
                                    case model.date of 
                                        Nothing ->
                                            case model.toDate of
                                                Nothing ->
                                                   viewOther model
                                                Just _ ->
                                                    viewSteper model
                                        Just _ ->
                                            viewSteper model
                                Just _ ->
                                    viewSteper model
                        _ ->
                            viewSteper model
                  False ->
                    viewSteper model
          ]
    }

viewOther : Model -> Html Msg
viewOther model =
     div[class "container-xxl", style "margin-top" "5vh", style "margin-left" "10%", style "margin-right" "10%"] 
          [
            div[class "row"]
            [
              div[class "col"]
              [
                 span[style "color" "rgba(0,99,166,1)", style "font-size" "3.5rem", style "font-weight" "bolder", style "text-shadow" "1px 0 rgba(0,99,166,1)"][text "HISTORY"]
              ,  br[][]
              ,  img[Html.Attributes.src "/images/line.svg"][]
              ]
            ]
         , div[class "row"]
            [
              div[class "col"][]

            , div[class "col"]
               [
                   div[][img[src "images/history.svg"][]]
               ,   div[style "text-align" "center"]
                   [
                       span[style "font-weight" "bolder"][text "Here you will be able to see your"]
                   ,   br[][]
                   ,   span[style "font-weight" "bolder"][text "Exchanges, Buys and Sells"]
                   ]
                   
               ,  div[class "d-flex justify-content-center", style "margin-top" "50px", style "margin-bottom" "150px"]
                 [ 
                      button [type_ "button", style "width" "30%" , style "margin" "auto", style "padding" "10px 3px", onClick ToExchangePage, class "btn btn-primary primary_button"][text "START"]
                 ]
               ]
            , div[class "col"][]
            ]
         ]

viewSteper : Model -> Html Msg
viewSteper model=
          div[class "container-xxl", style "padding-bottom" "5vh", style "margin-top" "5vh", style "margin-left" "10%"] 
          [
            div[class "row"]
            [
              div[class "col"]
              [
                span[style "color" "rgba(0,99,166,1)", style "font-size" "3.5rem", style "font-weight" "bolder", style "text-shadow" "1px 0 rgba(0,99,166,1)"][text "HISTORY"]
              ,  br[][]
              ,  img[Html.Attributes.src "/images/line.svg"][]
              ,  div[class "input-group", style "margin-top" "5vh"]
                 [
                   div[class "input-group-append"]
                    [ 
                       viewActionDropdown model
                    ,  viewCurrencyDropdown model
                    ,  viewDatePicker model
                    ,  viewToDatePicker model
                    ,  button[onClick Download, style "padding" "1rem", style "border-radius" "100px", style "border-style" "none"][img[style "width" "30px",src "images/EXPORT-FILE.svg"][]]
                    ]
                 ]
              ]
            ]
          , div[class "row", style "margin-top" "6vh"]
            [ viewPaginated model.content model]
          ]


type Msg =
   CompletedTransactionRequestLoad (Result Http.Error (TransactionReqResult))
   | GotSession Session
   | Next
   | Prev
   | First
   | Last
   | GoTo String Int
   | CancelTransaction Int
   | SelectActionDr Action 
   | CompletedFeedLoad (Result Http.Error (CurrencyResponse))
   | SelectCurrency String
   | DropdownToggleAction Dropdown.State
   | DropdownToggleCurrency Dropdown.State
   | SelectCurrencyDr (Maybe Currency)
   | FromDatePicker DatePicker.Msg
   | ToDatePicker DatePicker.Msg
   | Download
   | ToExchangePage





viewDatePicker : Model -> Html Msg
viewDatePicker ({ date, datePicker } as model) =
    div [ class "col-md-3"{--, style "background-color" "rgb(239, 239, 239)", style "border-radius" "50px"--} ]
        [ form [ style "height" "100%", autocomplete False ]
            [ div [ class "form-group", style "height" "100%" , autocomplete False]
                [ {--label [style "text-align" "center", style "width" "100%"] [ text "Pick a date" ]--}
                  DatePicker.view date settings datePicker
                    |> Html.map FromDatePicker
                ]
            ]
        ]

viewToDatePicker : Model -> Html Msg
viewToDatePicker ({ toDate, toDatePicker } as model) =
    div [ class "col-md-3"{--, style "background-color" "rgb(239, 239, 239)", style "border-radius" "50px"--} ]
        [ form [ style "height" "100%", autocomplete False ]
            [ div [ class "form-group", style "height" "100%" ]
                [ {--label [style "text-align" "center", style "width" "100%"] [ text "Pick a date" ]--}
                  DatePicker.view toDate settings2 toDatePicker
                    |> Html.map ToDatePicker
                ]
            ]
        ]

viewCurrencySelect : Model -> Html Msg
viewCurrencySelect model = 
    case model.currencies of
        Loaded currencies ->
            select[ onInput SelectCurrency]
            ((option[Html.Attributes.value "all"][text "All"]) ::
            (List.map (\currency -> option[Html.Attributes.value (String.fromInt  currency.id)][text currency.alias_]) currencies))
        _ ->
            div[][]


viewCurrencyDropdown : Model -> Html Msg
viewCurrencyDropdown  model =
  case model.currencies of
    Loaded currencies ->
      Dropdown.dropdown 
        model.dropCurrencyState
        { options = [ Dropdown.attrs[style "width" "100%", style "height" "100%"]]
        , toggleMsg = DropdownToggleCurrency
        , toggleButton = 
            Dropdown.toggle 
             [
                Button.attrs [ style "background-color" "rgba(239,239,239,1)", style "width" "100%", style "border-radius" "40px"], Button.block
              ]
              [
                 label[style "padding" ".375rem .75rem"][span[style "color" "rgba(112,112,112,1)", style "font-size" "1.25rem", style "font-weight" "bold"][text (
                     case model.currency of
                         Just currency ->
                             currency.alias_
                         Nothing ->
                             "All Currencies"
                             )]] 
              , img [style "margin-left" "5vw",style "width" "40px",style "margin-right" "1vw",Html.Attributes.src "/images/filter.svg"][]
              ]
          , items =
          Dropdown.buttonItem [onClick (SelectCurrencyDr Nothing)  ][text "All Currencies"]::  (List.map (\currency -> Dropdown.buttonItem [onClick (SelectCurrencyDr (Just currency)) ,Html.Attributes.value (String.fromInt  currency.id)][text currency.alias_]) currencies)
          }
    _ ->
        div[][]



viewActionDropdown : Model -> Html Msg
viewActionDropdown  model = 
    Dropdown.dropdown 
      model.dropActionState
      { options = [ Dropdown.attrs[style "width" "100%", style "height" "100%"]]
      , toggleMsg = DropdownToggleAction
      , toggleButton = 
          Dropdown.toggle 
           [
              Button.attrs [ style "background-color" "rgba(239,239,239,1)", style "width" "100%", style "border-radius" "40px"], Button.block
            ]
            [
               label[style "padding" ".375rem .75rem"][span[style "color" "rgba(112,112,112,1)", style "font-size" "1.25rem", style "font-weight" "bold"][text (getStrAction model.action)]] 
            , img [style "margin-left" "5vw",style "width" "40px",style "margin-right" "1vw",Html.Attributes.src "/images/filter.svg"][]
            ]
        , items = 
            [ Dropdown.buttonItem [onClick (SelectActionDr Transaction)][text "All Types"]
            , Dropdown.buttonItem [onClick (SelectActionDr Buy)][text "Buy"]
            , Dropdown.buttonItem [onClick (SelectActionDr Sell)][text "Sell"]
            , Dropdown.buttonItem [onClick (SelectActionDr Exchange)][text "Exchange"]
            ] 
        }

getStrAction : Action -> String
getStrAction action =
    case action of 
        Sell ->
            "Sell"
        Buy ->
            "Buy"
        Exchange ->
            "Exchange"
        Transaction ->
            "All Types"


viewList : Model -> Html Msg
viewList model =
    div []
    [
        span[] [text ("list size: " ++ (String.fromInt (List.length model.trans)))]
    ]
  


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
   case msg of

       ToExchangePage ->
           (model, Navigat.load (Route.routeToString Route.NewArticle ))

       FromDatePicker subMsg ->
            let
                ( newDatePicker, event ) =
                    DatePicker.update settings subMsg model.datePicker
            in
            case event of 
                Picked date ->
                    let
                        md = {model | date = Just date, datePicker = newDatePicker}
                    in
                    (md, createUpdateCommand md)

                _ ->
                    ({ model | date = model.date, datePicker = newDatePicker}, Cmd.none)

       ToDatePicker subMsg ->
            let
                ( newDatePicker, event ) =
                    DatePicker.update settings2 subMsg model.toDatePicker
            in
            case event of 
                Picked date ->
                    let
                       md = { model | toDate = Just date, toDatePicker = newDatePicker } 
                    in
                    (md, createUpdateCommand md)
                _ ->
                  ({model | toDatePicker = newDatePicker}, Cmd.none)

       DropdownToggleAction state ->
          ({ model | dropActionState  = state}, Cmd.none)

       DropdownToggleCurrency state ->
          ({ model | dropCurrencyState = state}, Cmd.none)

       SelectCurrencyDr currency ->
           let
               md = {model | currency = currency}
           in
           (md, createUpdateCommand md)

       SelectCurrency theId ->
           let
               md = {model | currencyId = Just theId}
           in

           (md, createUpdateCommand md)

       SelectActionDr action ->
           case action == model.action of
              True ->
                  (model, Cmd.none)
              False ->
                 let
                      md = { model| action = action}
                 in
                 (md, createUpdateCommand md) 

       CompletedFeedLoad (Ok feed) ->
           ({model | currencies = Loaded feed.currencies}, Cmd.none)

       CompletedFeedLoad (Err error) -> 
           (model, Cmd.none)

       CompletedTransactionRequestLoad (Err error) ->
         (model, Cmd.none)

       CompletedTransactionRequestLoad (Ok result) ->
         let
             trains_c = result.data
             trains_d = sortAndFilterTrans trains_c
             p_list = Paginate.fromList 10 trains_d
             content_c = { pairs = p_list, reversed = False, query = "", globalId = 1}

         in 
         ({model | trans = trains_c, content = Loaded trains_d, pagination = Loaded result.pagination}, Cmd.none)

       GotSession session ->
         ( { model | session = session }, Cmd.none
         )

       GoTo url index ->
          ({ model | content = Loading, currentPage = index}, getDepositPage model url)


       Next ->
                    (model, Cmd.none)
 
       Prev ->
                    (model, Cmd.none)

       First ->
                    (model, Cmd.none)

       Last ->
                    (model, Cmd.none)
                    
       CancelTransaction smthing ->
           (model, cancelRequestCommand model smthing)

       Download ->
           (model, (save (getCsvFromRecords model.content)))


save : String -> Cmd msg
save markdown =
  Download.string "data.csv" "text/plain" markdown

dataToRows : Status (List TransactionRequest) -> List (Html Msg)
dataToRows transactiosnSta =
    case transactiosnSta of
        Loaded transactions ->
            (List.map toTableRow transactions )
        _ ->
            [div[][]]

getReturn : TransactionRequest -> String
getReturn transaction =
    case transaction.actionId of 
        1 ->
          (Round.round transaction.tgtCurrency.decimals ((transaction.srcAmount - (transaction.srcAmount * (transaction.tgtCurrency.fee/100))) / transaction.exchangeRate))
        2 ->
           (Round.round transaction.srcCurrency.decimals ((transaction.srcAmount - (transaction.srcAmount * (transaction.tgtCurrency.fee/100))) * transaction.exchangeRate))
        _ ->
           (Round.round transaction.tgtCurrency.decimals ((transaction.srcAmount - (transaction.srcAmount * (transaction.tgtCurrency.fee/100))) / transaction.exchangeRate))


fromTo : TransactionRequest -> (String, String)
fromTo transactions =
    case transactions.actionId of
       1 ->
           (transactions.srcCurrency.alias_,transactions.tgtCurrency.alias_)
       2 ->
          (transactions.tgtCurrency.alias_, transactions.srcCurrency.alias_)
       _ ->
          (transactions.srcCurrency.alias_,transactions.tgtCurrency.alias_)

statusChange : String -> String
statusChange status = 
    case status of
        "Verification required" ->
            "Transaction Failed"
        _ ->
            status

toTableRow:  TransactionRequest -> Html Msg
toTableRow transactions =
    let
        (first, second) = fromTo transactions
        date = List.foldr(\first3 second3 -> first3 ++ " " ++ second3) "" (String.split "T" transactions.updatedAt)
    in
     tr []
     [ td[][span[][text first]]
     , td[][span[][text second]]
     , td[][span[][text (String.fromFloat transactions.srcAmount)]]
     , td[][span[][text (String.fromFloat transactions.exchangeRate)]]
     , td[][span[][text (getReturn transactions)]]

     , td[][span[][text date]]
     , td[][span[style "border" ("2px solid " ++ getColor transactions.status), style "color" (getColor transactions.status), style "border-radius" "50px", style "padding" "0.5rem 1rem", style "text-transform" "uppercase", style "font-weight" "bold"][text (statusChange transactions.status)]]
     ]



getColor : String -> String
getColor status =
    case status of 
        "Created" ->
            "rgba(255,158,46,1)"
        _ ->
            "rgb(58, 213, 160)"


toPageButton: Page -> Html Msg
toPageButton page =
  case page.current of
      True ->
        li[class "page-item"]
        [ 
            button 
            [ class "page-link"
            , style "color" "rgba(0,99,166,1)"
            , style "text-shadow" "1px 0 rgba(0,99,166,1)"
            , style "border-radius" "80px"
            , style "font-weight" "bolder"
            , style "padding" "0.2rem 0.8rem"
            , style "border-style" "none"
            , style "background-color" "white"
            , style "font-size" "1.25rem"
            , onClick (GoTo page.url page.page)
            ]
            [span[][text page.label]]
        ]

      False ->
        li[class "page-item"]
        [ 
            button 
            [ class "page-link"
            , style "color" "rgba(68,68,68,1)"
            , style "text-shadow" "1px 0 rgba(68,68,68,1)"
            , style "background-color" "transparent" 
            , style "font-weight" "bolder"
            , style "padding" "0.2rem 0.8rem"
            , style "border-style" "none"
            , style "font-size" "1.25rem"

            , onClick (GoTo page.url  page.page)
            ]
            [span[][text page.label]]
        ]



dataToPageButtons : Status (List Page) -> List (Html Msg)
dataToPageButtons  theListS =
    case theListS of
        Loaded list ->
           List.map toPageButton list
        _ ->
           [div[][]]

viewPaginated : Status (List TransactionRequest) -> Model -> Html Msg
viewPaginated transactions model=
    let        
        displayInfoView =
            div [class "col"]
                [ span [][ text <|
                    String.join " "
                        [ "page"
                        , String.fromInt <| 0
                        , "of"
                        , String.fromInt <| 1
                        ]]
                , div[] [ table [class "table",  style "border-color" "white"]
                  ( [
                       thead [class "thead", style "border-top" "0px solid red"]
                       [ 
                          th [scope "col"] [ span[][text "From" ]]
                       ,  th [scope "col"] [ span[] [text "To" ]]
                       ,  th [scope "col"] [ span[][text "Ammount"]]
                       ,  th [scope "col"] [ span[][text "Exch Rate"]]
                       ,  th [scope "col"] [ span[] [text "Return"]]
                       ,  th [scope "col"] [ span[] [text "Updated"]]
                       ,  th [scope "col"] [ span[] [text "Status"]]
                       ]
                   ] ++  
                    (dataToRows transactions))
                  ]
                ]
        buttonList =  dataToPageButtons model.pagination
    in
    div[style "width" "80%"][
      div[class "row"] [
       displayInfoView
      ]
      ,div[class "row justify-content-center"]
        [ 
            div[class "col"]
            [
                ul[class "pagination pagination-lg",style "background-color" "rgb(239, 239, 239)", style "border-radius" "50px", style "display" "table", style "padding" "10px" , style "margin" "auto"] 
                  buttonList
            ]
        ]
    ]

toSession : Model -> Session
toSession model =
    model.session

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ 
                Session.changes GotSession (Session.navKey model.session)
              , Dropdown.subscriptions model.dropActionState DropdownToggleAction
              , Dropdown.subscriptions model.dropCurrencyState DropdownToggleCurrency
              ]
