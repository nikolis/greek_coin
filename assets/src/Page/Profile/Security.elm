module Page.Profile.Security exposing (..)

import Session exposing (Session)
import Route
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Json.Encode as Encode
import Api exposing (Cred)
import Json.Decode exposing (list, string, Decoder, field, map5, decodeString, errorToString, nullable, int)
import Json.Decode.Pipeline
import Http
import Bootstrap.Modal as Modal
import Bootstrap.Button as Button
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid as Grid
import Http.Detailed
import Dict exposing (Dict)
import Api2.Happy exposing (getBaseUrl)
import Api2.Data exposing (User, Address, decoderUser)
import List.Extra 
import Api
import Route exposing (Route)
import Browser.Navigation as Navigat

type alias Model =
    { session : Session
    , password : PasswordFields
    , modalVisibility : ViewModalStatus
    , updatePassResp : Maybe (List String)
    , logins : Status (List LoginAttempt)
    , authenticatorImage : Maybe String
    , user : Maybe User
    , cancelationCode : String
    , activationCode : String
    , pagination : Status (List Page)
    , currentPage : Int
    }

init : Session -> (Model, Cmd Msg)
init session = 
    let
        md = 
         { session = session
         , activationCode = ""
         , cancelationCode = ""
         , authenticatorImage = Nothing
         , password = PasswordFields "" "" ""
         , modalVisibility =  Invisible
         , logins = Loading
         , updatePassResp = Nothing
         , user = Nothing
         , pagination = Loading
         , currentPage = 1
         }
    in
    (md, Cmd.batch[getLoginAttempts md.session, getUser md.session])

type Status a                  
    = Loading
    | LoadingSlowly            
    | Loaded a
    | Failed

type ViewModalStatus = 
    Invisible 
    | Visible 
    | SessionExpired
 
type alias Page =
    {
        current : Bool
    ,   label : String
    ,   page : Int
    ,   url : String
    }

type alias ChangesetError =
    {
        error : Dict String (List String)
    }

getDepositPage : Model -> String -> Cmd Msg
getDepositPage model url =
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
      , method = "GET"
      , body = Http.emptyBody
      , url = (getBaseUrl  ++ url)
      , expect = Http.expectJson  CompletedLoginLoad decoderLoginResponse
      , timeout = Nothing
      , tracker = Nothing
      }

getLoginAttempts : Session -> Cmd Msg
getLoginAttempts session   =
    Http.request
    {
     headers =
         case Session.cred session of
             Just cred ->
                 [ Api.credHeader cred]
             Nothing ->
                 []
    , method = "GET"
    , body = Http.emptyBody
    , url = (getBaseUrl ++ "/api/v1/users/login/attempts")
    , expect = Http.expectJson  CompletedLoginLoad  decoderLoginResponse
    , timeout = Nothing
    , tracker = Nothing
    }

get2faImmage : Session -> Cmd Msg
get2faImmage session  =

    Http.request
    {
      headers =
         case Session.cred session of
             Just cred ->
                 [ Api.credHeader cred]
             Nothing ->
                 []
    , method = "GET"
    , body = Http.emptyBody
    , url = (getBaseUrl ++ "/api/v1/user/2fa/create")
    , expect = Http.expectJson  Completed2faImmageLoad Json.Decode.string
    , timeout = Nothing
    , tracker = Nothing
    }

delete2fa : Session ->Model ->Cmd Msg
delete2fa session  model =
    let
      body = Encode.object [("validation_code", Encode.string model.cancelationCode)]
    in
    Http.request
    {
      headers =
         case Session.cred session of
             Just cred ->
                 [ Api.credHeader cred]
             Nothing ->
                 []
    , method = "POST"
    , body = Http.jsonBody body
    , url = (getBaseUrl ++ "/api/v1/user/2fa/deactivate")
    , expect = Http.Detailed.expectJson  Completed2faDeactivation Json.Decode.string
    , timeout = Nothing
    , tracker = Nothing
    }

getUser : Session -> Cmd Msg
getUser session = 
    Http.request
    {
     headers =
         case Session.cred session of
             Just cred ->
                 [ Api.credHeader cred]
             Nothing ->
                 []
    , method = "GET"
    , body = Http.emptyBody
    , url = (getBaseUrl ++ "/api/v1/self")
    , expect = Http.expectJson  GotUser decoderUser
    , timeout = Nothing
    , tracker = Nothing
    }


activate2faImmage : Session -> Model -> Cmd Msg
activate2faImmage session  model  =
    let
      body = Encode.object [("validation_code", Encode.string model.activationCode)]
    in
    Http.request
    {
     headers =
         case Session.cred session of
             Just cred ->
                 [ Api.credHeader cred]
             Nothing ->
                 []
    , method = "POST"
    , body = Http.jsonBody body
    , url = (getBaseUrl ++ "/api/v1/user/2fa/activate")
    , expect = Http.Detailed.expectJson  Completed2fActivation Json.Decode.string
    , timeout = Nothing
    , tracker = Nothing
    }

type alias LoginAttempt =
    {
        ipAddress: String
      , result : String
      , id : Int
      , date : String
    }
type alias LoginResponse = 
    {
        data: List LoginAttempt
      , pagination : List Page
    }

decoderLoginResponse : Decoder LoginResponse
decoderLoginResponse = 
    Json.Decode.succeed LoginResponse
      |> Json.Decode.Pipeline.required "data" (Json.Decode.list decoderLoginAttempt)
      |> Json.Decode.Pipeline.required "pagination" (Json.Decode.list pagesDecoder)

pagesDecoder : Json.Decode.Decoder Page
pagesDecoder =
    Json.Decode.succeed Page
        |> Json.Decode.Pipeline.required "current" Json.Decode.bool
        |> Json.Decode.Pipeline.required "label" string
        |> Json.Decode.Pipeline.required "page" int
        |> Json.Decode.Pipeline.required "url" string


decoderLoginAttempt : Decoder LoginAttempt
decoderLoginAttempt =
    Json.Decode.succeed LoginAttempt 
      |> Json.Decode.Pipeline.required "ip_address" string
      |> Json.Decode.Pipeline.required "result" string
      |> Json.Decode.Pipeline.required "id" Json.Decode.int
      |> Json.Decode.Pipeline.required "update_at" string

decoderChangeset : Decoder ChangesetError
decoderChangeset =
    Json.Decode.succeed ChangesetError
    |> Json.Decode.Pipeline.required "errors" (Json.Decode.dict (Json.Decode.list string))


type alias PasswordFields =
    {
        oldPass : String
      , newPass : String
      , newPassRepeat : String
    }

type Msg =
    GotSession Session
    | OldPass String
    | NewPass String
    | NewPassRepeat String
    | UpdateResponse (Result (Http.Detailed.Error String) ( Http.Metadata, String ))
    | SendUpdatePassRequest
    | CloseModal 
    | ShowModal
    | CompletedLoginLoad (Result Http.Error  LoginResponse)
    | Completed2faImmageLoad (Result Http.Error String)
    | Completed2faDeactivation (Result (Http.Detailed.Error String) (Http.Metadata,String))
    | Auth2faUtil Bool
    | Completed2fActivation (Result (Http.Detailed.Error String) (Http.Metadata, String))
    | GotItActivate 
    | GotUser (Result Http.Error User)
    | InputAct String
    | InputDea String
    | GoTo String Int
    | SessionExpiredMsg


updateUserPassCommand : Model -> Cmd Msg
updateUserPassCommand model =
  let
    body = Encode.object
      [ ("password", Encode.string model.password.oldPass)
      , ("credential", Encode.object
        [ 
          ("password" , Encode.string model.password.newPass)
        , ("password_confirmation", Encode.string model.password.newPassRepeat) 
        ])
      ]
  in  
   Http.request
    {
     headers =
         case Session.cred (model.session) of
             Just cred ->
                 [ Api.credHeader cred]
             Nothing ->
                 []
    , method = "PUT"
    , url = (getBaseUrl ++ "/api/v1/user/reset/password")
    , body = Http.jsonBody body
    , expect = Http.Detailed.expectString  UpdateResponse 
    , timeout = Nothing
    , tracker = Nothing
    }


view : Model -> Html Msg
view model = 
    div[class "col"]
    [
      div[class "row"]
      [
          div[class "col"]
          [
            {--viewModalOld model--}
          ]
      ]
      
    , div[class "row"]
      [   
        div[class "col-7"]
        [
          div[class "row"]
          [
            div[class "col"]
            [
               img[src "/images/user.svg",style "width" "2vw", style "margin-right" "1vw"][]
            ,  span[style "color" "rgba(0,99,166,1)", style "font-size" "1.5rem" , style "font-weight" "bold"][text "Password"]
            ]
          ]
      , div[class "row", style "margin-top" "4vh", style "border" "2px solid rgb(239, 239, 239)", style "border-radius" "15px"]
        [
          div[class "col", style "padding" "4px"]
          [
            label [class "form-control", style "border" " 0px solid white"][text "Current Password"]
          , input [class "form-control", onInput OldPass,value model.password.oldPass, style "border" " 0px solid white", style "font-weight" "bold"] []
          ]
        , div[class "col-2"]
          [
          ]
        ]

     , div[class "row", style "margin-top" "4vh", style "border" "2px solid rgb(239, 239, 239)", style "border-radius" "15px"]
        [
          div[class "col", style "padding" "4px"]
          [
            label [class "form-control", style "border" " 0px solid white"][text "new password"]
          , input [class "form-control", onInput NewPass,value model.password.newPass, style "border" " 0px solid white", style "font-weight" "bold"] []
          ]
        , div[class "col-2"]
          [
          ]
        ]
     , div[class "row", style "margin-top" "4vh", style "border" "2px solid rgb(239, 239, 239)", style "border-radius" "15px"]
        [
          div[class "col", style "padding" "4px"]
          [
            label [class "form-control", style "border" " 0px solid white"][text "new password"]
          , input [class "form-control", onInput NewPassRepeat,value model.password.newPassRepeat, style "border" " 0px solid white", style "font-weight" "bold"] []
          ]
        , div[class "col-2"]
          [
          ]
        ]
     , div[class "row", style "margin-top" "3vh"]
       [
           div[class "ml-auto"]
           [
              button[class "btn  ml-auto",style "background-color" "rgba(0,99,166,1)",style "color" "white",style "font-weight""bold",style "border-radius" "50px" , onClick SendUpdatePassRequest][text "update"]
           ]
       ]
          ]
    , div[class "col"]
        (view2fa model)      
    ]

   , div[class "row", style "margin-top" "5vh"]
       [ viewTable model.logins model
       ]

  ]


view2fa : Model -> List (Html Msg)
view2fa model =
    case model.user of
        Nothing ->
            []
        Just user ->
              (case model.authenticatorImage of 
                 Just imgSrc ->
                  [
                    h3[][text "Secure Your Account "]
                  , h3[][text "Enable Your Two-Factor Authenticator"]
                  , img[src imgSrc][]
                  , input[style "width" "10vw",class "form-control", placeholder "E.g 910 503", value model.activationCode, onInput InputAct][]
                  , button[class "btn btn-primary", onClick GotItActivate] [text "Got it Please activate my 2fa"]
                  ]
                 Nothing ->
                     let
                       message = 
                         case user.auth2fa of
                             True ->
                                 "Click to disable 2FA"
                             False ->
                                 "Click to enable 2FA"
                     in
                         [
                           h3[][text "Secure Your Account "]
                         , h3[][text "Enable Your Two-Factor Authenticator"]
                         , br[][]
                         , div[class "input-group"]
                           [
                             input[style "width" "30%",class "form-control", placeholder message, value model.cancelationCode, onInput InputDea][]
                           , label[class "switch"]
                             [
                               input[type_ "checkbox", checked (user.auth2fa), onClick (Auth2faUtil (not user.auth2fa))][]
                             , span[class "slider round"][]
                             ]
                           ]
                         ]
              )

dataToPageButtons : Status (List Page) -> List (Html Msg)
dataToPageButtons  theListS =
    case theListS of
        Loaded list ->
           List.map toPageButton list
        _ ->
           [div[][]]

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

viewTable : Status (List LoginAttempt) -> Model -> Html Msg
viewTable list model= 
    let
          buttonList =  dataToPageButtons model.pagination
    in
    case list of
        Loaded logins ->
           div[style "width" "100%"]
           [
             table[class "table table-hover"]
              [
                  thead[]
                  [
                    tr[]
                    [
                      th[scope "col"][text "ACTION"]
                    , th[scope "col"][text "IP ADDRESS"]
                    , th[scope "col"][text "OUTCOME"] 
                    , th[scope "col"][text "DATE"]
                    ]
                  ]
                , tbody[]
                    (List.map (\login -> tr[][td[][text "Login"], td[][text login.ipAddress], td[][text login.result],td[][text login.date]]) logins)
                    
              ]
          , div[class "row justify-content-center"]
            [ 
                div[class "col"]
                [
                    ul[class "pagination pagination-lg",style "background-color" "rgb(239, 239, 239)", style "border-radius" "50px", style "padding" "5px"] buttonList
                ]
            ]

          ]


        _  ->
            div[][]


update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
    case msg of
       SessionExpiredMsg ->
           (model, Cmd.batch [Api.clearLogInfo, Navigat.load (Route.routeToString Route.Login)])

       InputAct str ->
           ({model | activationCode = str}, Cmd.none)
       InputDea str ->
           ({ model | cancelationCode = str}, Cmd.none)
       GotUser (Ok user)->
           ({model | user = Just user}, Cmd.none)

       GotUser (Err error) ->
           let
               _ = Debug.log "error getting user" error
           in
           (model, Cmd.none)

       GotItActivate ->
           (model, activate2faImmage model.session model) 

       Completed2fActivation (Ok resp)->
           case model.user of
               Just user ->
                   let
                      newUser = {user | auth2fa = True}
                   in
                   ({model | user = Just newUser, authenticatorImage = Nothing}, Cmd.none)

               Nothing ->                   
                 (model, Cmd.none)

       Completed2fActivation (Err error) ->

           (model, Cmd.none)

       Auth2faUtil variabl ->
           case variabl of
               True ->
                  (model, get2faImmage model.session)
               False ->
                  (model, delete2fa model.session model)

       CloseModal ->
          ({model | modalVisibility = Invisible, updatePassResp = Nothing}, Cmd.none)
       
       ShowModal ->
          ({ model | modalVisibility = Visible}, Cmd.none) 

       SendUpdatePassRequest ->
           (model, updateUserPassCommand model)

       Completed2faImmageLoad (Ok response) ->
           ({model | authenticatorImage = Just response}, Cmd.none)

       Completed2faImmageLoad (Err error) ->
           let
               _ = Debug.log "error"
           in
           (model, Cmd.none)

       Completed2faDeactivation (Ok response) ->
           case model.user of
               Just user ->
                   let
                      newUser = {user | auth2fa = False} 
                   in
                   ({model | user = Just newUser}, Cmd.none)
               Nothing ->
                   (model, Cmd.none)

       Completed2faDeactivation (Err error) ->
           case error of 
               Http.Detailed.BadStatus metadata body ->
                   case metadata.statusCode of
                       401 ->
                         ({model | modalVisibility = SessionExpired }, Cmd.none)
                       _ ->
                         (model, Cmd.none)
               _ ->
                   (model, Cmd.none)

       CompletedLoginLoad (Ok response) ->
           ({model | logins = Loaded response.data, pagination = Loaded response.pagination}, Cmd.none)

       CompletedLoginLoad (Err error) ->
           let
               _ = Debug.log "the logins are not " error
           in
           (model, Cmd.none)

       UpdateResponse (Err error) ->
           case error of
               Http.Detailed.BadStatus metadata body ->
                     case Json.Decode.decodeString decoderChangeset body of
                       Ok errorBody ->
                           let
                             dictComp = Dict.map (\k b -> List.map (\c -> (k,c)) b ) errorBody.error
                             values = Dict.values dictComp
                             listClean = List.concat values
                             list = List.map (\(a,b) -> a++": "++ b) listClean

                             listStr = List.map (\(a,b) -> a++": " ++b) listClean
                           in
                           case metadata.statusCode of
                           401 ->
                              ({model | modalVisibility = SessionExpired }, Cmd.none)
                           _ ->
                              ({model | updatePassResp = Just listStr, modalVisibility = Visible}, Cmd.none)

                       Err error2 ->
                          case metadata.statusCode of
                             401 ->
                                ({model | modalVisibility = SessionExpired }, Cmd.none)
                             _ ->
                                ({model | updatePassResp = Just [body], modalVisibility = Visible}, Cmd.none)

               Http.Detailed.Timeout ->
                  let
                   md = {model | updatePassResp = Just ["server timeout please try later"]}
                 in
                 update ShowModal md
               _ ->
                 (model, Cmd.none)
          
       UpdateResponse (Ok (metadata, response)) ->
           let
             _ = Debug.log "response update" response
             md = { model | updatePassResp = Just [response]} 
           in
           update ShowModal md

       OldPass pass ->
           let
               password = model.password
               newPass = {password | oldPass = pass}
           in
           ({model | password = newPass}, Cmd.none)

       NewPass pass ->
           let
               password = model.password
               newPass = {password | newPass = pass}
           in
           ({model | password = newPass}, Cmd.none)

       NewPassRepeat pass ->
           let
               password = model.password
               newPass = {password | newPassRepeat = pass}
           in
           ({model | password = newPass}, Cmd.none)

       GotSession session ->
            ( { model | session = session }
            , Route.replaceUrl (Session.navKey session) Route.Home
            )

       GoTo url index ->
            ({ model | logins = Loading, currentPage = index}, getDepositPage model url)

{--viewModalOld : Model  -> Html Msg
viewModalOld model   =
   case model.updatePassResp of
       Just resp ->
         Grid.container []
         [
           Modal.config CloseModal 
             |> Modal.small
             |> Modal.h5 [] [ text "Update" ]
             |> Modal.body []
                 (List.map (\error -> text error) resp)
             |> Modal.footer []
                [ Button.button
                    [ Button.outlinePrimary
                    , Button.attrs [ onClick CloseModal  ]
                    ]
                    [ text "Ok"]
                ]
             |> Modal.view model.modalVisibility
         ]
       Nothing ->
           div[][]
--}
viewModal : Model  -> Maybe (Html Msg)
viewModal model   =
    case model.modalVisibility of
        Invisible ->
           Nothing 
        Visible ->
           case model.updatePassResp of
               Just resp ->
                 Just(
                  div[class "container"]
                  [
                      div[class "row"]
                      [
                          div[class "col"]
                          [
                              span[class "modal_header center-block"][text "Update"]
                          ]
                      ]
                  ,   div[class "row"]
                      [
                          div[class "col", style "text-align" "center"]
                          [
                              span[class "modal_message"](List.map (\error -> text error) resp)
                          ]
                      ]
                  ,  div[class "row justify-content-center"]
                     [

                        div[class "col-4"]
                         [
                           button [type_ "button", style "width" "100%" , style "margin" "auto", style "padding" "10px 3px", onClick CloseModal , class "btn btn-primary primary_button"]
                           [text "Ok" ]
                         ]
                     ]

                  ]
                )

               Nothing ->
                   Nothing

        SessionExpired ->
              Just(
                  div[class "container"]
                  [
                     div[class "row justify-content-center"]
                     [

                        div[class "col-4"]
                         [
                           button [type_ "button", style "width" "100%" , style "margin" "auto", style "padding" "10px 3px", onClick SessionExpiredMsg , class "btn btn-primary primary_button"]
                           [text "Log In" ]
                         ]
                     ]

                  ]
                )


subscriptions : Model -> Sub Msg
subscriptions model = 
    Sub.batch
    [
        Session.changes GotSession (Session.navKey model.session)
    ]
