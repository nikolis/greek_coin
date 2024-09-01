port module Page.Login exposing (..)

{-| The login page.
-}

import Api exposing (Cred(..))
import Browser.Navigation as Navigat
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode.Pipeline exposing (optional)
import Json.Encode as Encode
import Route exposing (Route)
import Session exposing (Session)
import Viewer exposing (Viewer)
import Http.Legacy 
import Time
import Task
import Process
import Bootstrap.Modal as Modal
import Bootstrap.Button as Button
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid as Grid
import Http.Detailed
import Dict exposing (Dict)
import Json.Decode exposing (list, string, Decoder, field, map5, decodeString, errorToString, nullable)
import Api2.Happy exposing (getBaseUrl)
import Username exposing (Username)
import Page.Home.Naview as Nav
import Page.Register as RegP
import Route

{-| Recording validation problems on a per-field basis facilitates displaying
them inline next to the field where the error occurred.

I implemented it this way out of habit, then realized the spec called for
displaying all the errors at the top. I thought about simplifying it, but then
figured it'd be useful to show how I would normally model this data - assuming
the intended UX was to render errors per field.

(The other part of this is having a view function like this:

viewFieldErrors : ValidatedField -> List Problem -> Html msg

...and it filters the list of problems to render only InvalidEntry ones for the
given ValidatedField. That way you can call this:

viewFieldErrors Email problems

...next to the `email` field, and call `viewFieldErrors Password problems`
next to the `password` field, and so on.

The `LoginError` should be displayed elsewhere, since it doesn't correspond to
a particular field.

-}

type ActionWindow 
    = Login
    | Register

port renderCaptcha : String -> Cmd msg
port resetCaptcha : String -> Cmd msg
port setRecaptchaToken : (String -> msg) -> Sub msg
-- MODEL


type alias Model =
    { session : Session
    , problems : List Problem
    , form : Form
    , loginToken : Maybe String
    , authToken : String
    , recaptchaToken : Maybe String
    , modalVisibility : Modal.Visibility
    , modalLogin : Modal.Visibility
    , modalLoginResp : Maybe (List String)
    , modalResponseVisibility : Modal.Visibility
    , modalResponseType : Int
    , modalResponseMessage : String
    , modalMsg : Maybe String
    , email : String
    , updatePassResp : Maybe (List String)
    , updateSetPassResp : Maybe (List String)
    , password : PasswordFields
    , window : ActionWindow
    , regModel : RegP.Model
    }

init : Session -> Int -> ( Model, Cmd Msg )
init session lg =
    let
        (mdR, cmds) =  RegP.init session
    in
    ( { session = session
      , problems = []
      , form =
            { email = ""
            , password = ""
            }
      , loginToken = Nothing
      , authToken = ""
      , modalResponseVisibility = Modal.hidden
      , modalLogin = Modal.hidden
      , modalLoginResp = Nothing
      , modalResponseType = 0
      , modalResponseMessage = ""
      , recaptchaToken = Nothing
      , updatePassResp = Nothing
      , updateSetPassResp = Nothing
      , modalVisibility = Modal.hidden
      , modalMsg = Nothing
      , email = ""
      , password = PasswordFields "" "" ""
      , window = 
          case lg of
              1 ->
                Login
              2 ->
                Register
              _ ->
                Login
      , regModel = mdR
    }
      ,Cmd.batch [renderCaptcha "recaptcha", Cmd.map(\com -> ( RegisterMsg com)) cmds]
    )

type Problem
    = InvalidEntry ValidatedField String
    | ServerError String
    | CaptchaError String


type alias Form =
    { email : String
    , password : String  
    }

type alias ChangesetError =
    {
        error : Dict String (List String)
    }

type alias PasswordFields =
    {
        token : String
      , newPass : String
      , newPassRepeat : String
    }

decoderChangeset : Decoder ChangesetError
decoderChangeset =
    Json.Decode.succeed ChangesetError
    |> Json.Decode.Pipeline.required "errors" (Json.Decode.dict (Json.Decode.list string))

-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Login"
    , content =
        div [ style "height" "100%", style "background-image" "url(\"images/BG.svg\")", style "background-repeat" "no-repeat", style "background-size" "cover", style "padding-bottom" "100vh", style "margin-left" "-15px"]
            [ 
              div[class "col", style "margin-right" "10vw"]
               [
                Nav.naview model.session 2
               ]

            ,contView model
            ]
    }

loginView : Model -> Html Msg
loginView model =
    div [ class "" ]
                [ div [ class "row" ]
                    [ div [ class "col" ]
                        [ viewModalPass model
                        , viewLogin model
                        , viewModalResponse model
                        {--, p [ class "text-xs-center" ]
                            [ a [ Route.href Route.Register ]
                                [ text "Need an account?" ]
                            ]--}
                        , ul [ class "error-messages" ]
                            (List.map viewProblem model.problems)
                        , viewForm model.form
                        ]
                    ]
                ]


contView : Model -> Html Msg
contView model=
    div[class "container-sm",style "max-width" "600px", style "background-color" "white", style "border-radius" "10px", style "padding-top" "2.5vh",style "margin-top" "6vh", style "padding-bottom" "3vh", style "box-shadow" "8px 8px 16px 8px rgba(0.2,0.2,0.2,0.2)"]
    [
      div[class "row"]
      [
       div[class "col"]
        [
          div[class "row"]
          [
           div[class ("col "++ getClassCol model Login), style "padding-left" "2.5vw"][ a[href "#pageSubmenu", class (getClass model Login), type_ "button",onClick (ChangeWindow Login)][text "SIGN IN"]]
          , div[class ("col "++ getClassCol model Register),style "padding-left" "1.5vw", style "padding-right" "3.5vw", style "margin-right" "1vw"][ a[href "#pageSubmenu", class (getClass model Register), type_ "button" ,onClick (ChangeWindow Register)][text "SIGN UP"]]
          ]
        ]
      ]
     , div[class "row"]
      [
        div[class "col"]
          [ case model.window of 
              Login ->
                 loginView model
              Register ->
                  Html.map (\comR -> RegisterMsg comR) (RegP.view model.regModel)
              
          ]
      ]
    ]

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

resetUserPassCommand : Model -> Cmd Msg
resetUserPassCommand model =
  let
    body = Encode.object
      [ ("email", Encode.string model.email)
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
    , url = (getBaseUrl ++ "/api/v1/user/reset/password/email")
    , body = Http.jsonBody body
    , expect = Http.Detailed.expectString  UpdateResponse 
    , timeout = Nothing
    , tracker = Nothing
    }

setUserPassCommand : Model -> Cmd Msg
setUserPassCommand model =
  let
    body = Encode.object
      [ ("token", Encode.string model.password.token)
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
    , url = (getBaseUrl ++ "/api/v1/user/set/password/email")
    , body = Http.jsonBody body
    , expect = Http.Detailed.expectString  UpdateSetResponse 
    , timeout = Nothing
    , tracker = Nothing
    }

viewModal : Model -> Maybe (Html Msg)
viewModal model =
   case model.window of
      Login ->
         Nothing
      Register ->
          case RegP.viewModal model.regModel of
              Just thml ->
                 Just (Html.map (\comR -> RegisterMsg comR) thml)
              Nothing ->
                 Nothing



viewModalPass : Model  -> Html Msg
viewModalPass model   =
         Grid.container []
         [
           Modal.config CloseModal 
             |> Modal.small
             |> Modal.h5 [] [ text "Password Reset" ]
             |> Modal.body []
                 [
                     div[class "form-group"]
                     [
                         label[for "emailInput"] [text "email address"]
                     ,   input[type_ "email", class "form-control", id "emailInput", placeholder "example@emailserver.com", onInput EmailInput, value model.email]
                         [
                         ]   
                     ]

                 ]
             |> Modal.footer []
                [ Button.button
                    [ Button.outlinePrimary
                    , Button.attrs [ onClick SendEmail  ]
                    ]
                    [ text "Reset"]
                ]
             |> Modal.view model.modalVisibility
         ]

viewModalResponse : Model  -> Html Msg
viewModalResponse model   =
   let
               resp = 
                 case model.updateSetPassResp of 
                   Just response ->
                     (List.map (\error -> text error) response)
                   Nothing ->
                      [div[][]]
   in
    case model.modalResponseType of 
      2 ->
         Grid.container []
         [
           Modal.config CloseModalResponse
             |> Modal.small
             |> Modal.h5 [] [ text "Reset update" ]
             |> Modal.body []
                 (resp
                 ++
                 [
                     div[class "form-group"]
                     [
                         label[for "inputToken"] [text "token"]
                     ,   input[type_ "text", class "form-control", id "inputToken", placeholder "SFMyNTY.g3QAAAACZAAEZGF0YWEBZAAGc2lnbmV...", onInput TokenInput, value model.password.token]
                         [
                         ]
                     ,div[class ""]
                      [
                        div[class "input-group mb-3"]
                         [
                           div[]
                           [
                             label[attribute "for"  "newPassword"][ text "New Password"]
                           , input[type_ "password", class "form-control", id "newPassword", onInput PasswordInput, value model.password.newPass][]
                           ]
                        , div[]
                          [
                            label[attribute "for"  "repPassword"][ text "Repeat Password"]
                          , input[type_ "password", class "form-control", id "repPassword", onInput PasswordConfirmInput, value model.password.newPassRepeat][] 
                          ]
                         ]
                       ]

                     ]
                 ])
             |> Modal.footer []
                [ Button.button
                    [ Button.outlinePrimary
                    , Button.attrs [ onClick SendEmailUpdate  ]
                    ]
                    [ text "Reset"]
                ]
             |> Modal.view model.modalResponseVisibility
         ]
      1 ->
          Grid.container []
         [
           Modal.config CloseModal 
             |> Modal.small
             |> Modal.h5 [] [ text "Reset update" ]
             |> Modal.body []
                 [
                     div[class "form-group"]
                     [
                        text  "Could not find email"
                     ]
                 ]
             |> Modal.footer []
                [ Button.button
                    [ Button.outlinePrimary
                    , Button.attrs [ onClick CloseModalResponse  ]
                    ]
                    [ text "Reset"]
                ]
             |> Modal.view model.modalResponseVisibility
         ]

      3 ->
         Grid.container []
         [
           Modal.config CloseModal 
             |> Modal.small
             |> Modal.h5 [] [ text "Reset update" ]
             |> Modal.body []
                 [
                     div[class "form-group"]
                     [
                        text  "Succes update you can login"
                     ]
                 ]
             |> Modal.footer []
                [ Button.button
                    [ Button.outlinePrimary
                    , Button.attrs [ onClick CloseModalResponse  ]
                    ]
                    [ text "Reset"]
                ]
             |> Modal.view model.modalResponseVisibility
         ]
      _ ->
          div[][]

viewProblem : Problem -> Html msg
viewProblem problem =
    let
        errorMessage =
            case problem of
                InvalidEntry _ str ->
                    str

                ServerError str ->
                    str

                CaptchaError str->
                    str
    in
    li [] [ text errorMessage ]


viewForm : Form -> Html Msg
viewForm form =
    Html.form [ onSubmit SubmittedForm ]
        [ div [ class "row", style "border-style" "solid", style "border-color" "rgb(239, 239, 239)", style "border-radius" "20px", style "margin-left" "0.2vw", style "margin-right" "0.2vw"]
          [
           div[class "col-10"]
           [
               label [style "color" "rgba(112,112,112,1)", style "font-weight" "bold", value "Email", class "form-control form-control-lg", style "border-style" "none"][text "Email"]
            ,  input
                [ class "form-control form-control-lg"
                , placeholder "example@mail.com"
                , onInput EnteredEmail
                , value form.email
                , style "border-style" "none"
                ]
                []
            ]
           , div[class "col justify-content-center align-self-center"]
             [
                 img[class "align-middle", src "/images/user.svg", style "width" "2vw", style "margin" "auto"][]
             ]
           ]
        , div [ class "row", style "border-style" "solid", style "border-color" "rgb(239, 239, 239)", style "border-radius" "20px", style "margin-left" "0.2vw", style "margin-right" "0.2vw", style "margin-top" "2vh", style "margin-bottom" "2vh"]
          [
           div[class "col-10"]
           [
               label [style "color" "rgba(112,112,112,1)", style "font-weight" "bold", value "Password", class "form-control form-control-lg", style "border-style" "none"][text "Password"]
            ,  input
                [ type_ "password", class "form-control form-control-lg"
                , onInput EnteredPassword
                , value form.password
                , style "border-style" "none"
                ]
                []
            ]
           , div[class "col justify-content-center align-self-center"]
             [
                 img[class "align-middle", src "/images/password.svg", style "width" "2vw", style "margin" "auto"][]
             ]
           ]

        , div [style "margin" "auto",style "width" "50%",id "recaptcha"][]

        , div[class "input-group "]
          [ 
           button [ type_ "button", style "width" "30%" , style "margin" "auto", class "btn btn-primary primary_button", onClick SubmittedForm]
            [ text "Log In" ]
          ]
          , div[class "wizard-footer"]
          [
           div[class "pull-right", style "float" "right"]
             [ 
               button [ class "btn ",style "border-style" "none", style "color" "rgba(112,112,112,1)",style "font-size" "1rem",style "font-weight" "bold", onClick ShowModal]
               [ text "Forgot Password"]
             ]
           ]
        ]

-- UPDATE

type Msg
    = SubmittedForm
    | EnteredEmail String
    | EnteredPassword String
    | CompletedLogin (Result (Http.Detailed.Error String) (Http.Metadata, LoginResp))
    | CompletedLogin2fa (Result (Http.Detailed.Error String) (Http.Metadata, LoginResp))
    | GotSession Session
    | Ready ()
    | Sub
    | SetRecaptchaToken String
    | CloseModal
    | SendEmail 
    | SendEmailUpdate
    | ShowModal
    | ShowRespModal
    | EmailInput String
    | UpdateResponse (Result (Http.Detailed.Error String) ( Http.Metadata, String ))
    | UpdateSetResponse (Result (Http.Detailed.Error String) ( Http.Metadata, String ))
    | CloseModalResponse
    | TokenInput String
    | PasswordConfirmInput String
    | PasswordInput String
    | CloseModalLogin
    | OpenModalLogin
    | TokenLoginInput String
    | SendLoginTokens
    | ChangeWindow ActionWindow
    | RegisterMsg RegP.Msg 


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
       _ =  Debug.log (Debug.toString msg) 
    in

    
    case msg of
        RegisterMsg msgR ->
            let
                (regM, comReg) = RegP.update msgR model.regModel
            in
            ({model | regModel = regM}, Cmd.map (\regCom -> (RegisterMsg regCom)) comReg)

        SendLoginTokens ->
            (model, login2fa model)
        TokenLoginInput txt ->
            ({model | authToken = txt}, Cmd.none)

        ChangeWindow action ->
            case action of
                Login ->
                  ({ model | window = action}, renderCaptcha "recaptcha")

                Register ->
                  ({ model | window = action}, Cmd.none)

        OpenModalLogin ->
          ({model | modalLogin = Modal.shown}, Cmd.none)

        ShowModal ->
          ({ model | modalVisibility = Modal.shown}, Cmd.none) 

        CloseModalLogin ->
          ({ model | modalLogin = Modal.hidden, modalLoginResp = Nothing}, Cmd.none)

        UpdateResponse (Err error) ->
           case error of
               Http.Detailed.BadStatus metadata body ->
                 let
                   md =  
                     case Json.Decode.decodeString decoderChangeset body of
                       Ok errorBody ->
                           let
                             dictComp = Dict.map (\k b -> List.map (\c -> (k,c)) b ) errorBody.error
                             values = Dict.values dictComp
                             listClean = List.concat values
                             list = List.map (\(a,b) -> a++": "++ b) listClean

                             listStr = List.map (\(a,b) -> a++": " ++b) listClean
                           in

                          {model | updateSetPassResp = Just listStr, modalResponseType = 1}

                       Err error2 ->
                          {model | updateSetPassResp = Just [body], modalResponseType = 1}
                 in
                 ({md | modalResponseVisibility = Modal.shown}, Cmd.none)

               Http.Detailed.Timeout ->
                 let
                   md = {model | updateSetPassResp = Just ["server timeout please try later"], modalResponseType = 1}
                 in
                 ({md | modalResponseVisibility = Modal.shown}, Cmd.none)

               _ ->
                ({model | modalResponseVisibility = Modal.shown}, Cmd.none)

          
        UpdateResponse (Ok (metadata, response)) ->
           let
             md = { model | updateSetPassResp = Just [response], modalResponseType = 2} 
           in
           ({md | modalResponseVisibility = Modal.shown}, Cmd.none)

        UpdateSetResponse (Err error) ->
           case error of
               Http.Detailed.BadStatus metadata body ->
                 let
                   md =  
                     case Json.Decode.decodeString decoderChangeset body of
                       Ok errorBody ->
                           let
                             dictComp = Dict.map (\k b -> List.map (\c -> (k,c)) b ) errorBody.error
                             values = Dict.values dictComp
                             listClean = List.concat values
                             list = List.map (\(a,b) -> a++": "++ b) listClean

                             listStr = List.map (\(a,b) -> a++": " ++b) listClean
                           in

                          {model | updateSetPassResp = Just listStr}

                       Err error2 ->
                          {model | updateSetPassResp = Just [body]}
                 in
                  ({md | modalResponseType = 2}, Cmd.none)

               Http.Detailed.Timeout ->
                  let
                   md = {model | updateSetPassResp = Just ["server timeout please try later"]}
                 in
                 ({md | modalResponseType = 2}, Cmd.none)
               _ ->
                 (model, Cmd.none)

          
        UpdateSetResponse (Ok (metadata, response)) ->
           let
             _ = Debug.log "response update" response
             md = { model| modalResponseType = 3} 
           in
           (md, Cmd.none)

           


        SendEmailUpdate ->
           (model, setUserPassCommand model) 

        EmailInput email ->
          ({ model | email = email}, Cmd.none)

        CloseModal ->
          ({model | modalVisibility = Modal.hidden}, Cmd.none)

        CloseModalResponse ->
          ({model | modalResponseVisibility = Modal.hidden}, Cmd.none)
 
        ShowRespModal ->
          ({ model | modalResponseVisibility = Modal.shown, modalResponseType = 2}, Cmd.none)

        TokenInput string ->
            let
                password = model.password
                passNew = {password | token = string}
            in
            ({model | password = passNew}, Cmd.none)

        PasswordInput pass ->
            let
                password = model.password
                passNew = {password | newPass = pass}
            in
            ({model | password = passNew}, Cmd.none)

        PasswordConfirmInput string ->
            let
                password = model.password
                passNew = {password | newPassRepeat = string}
            in
            ({model | password = passNew}, Cmd.none)

        SendEmail ->
          ({model | modalVisibility = Modal.hidden}, resetUserPassCommand model)
       
        
        SubmittedForm ->
            case validate  model model.form of
                Ok validForm ->
                    case model.recaptchaToken of 
                        Just token ->
                          ( { model | problems = [] }
                           , (login validForm token (Session.viewer model.session))
                          )
                        Nothing ->
                          (model, Cmd.none)

                Err problems ->
                    ( { model | problems = problems }
                    , Cmd.none
                    )

        EnteredEmail email ->
            updateForm (\form -> { form | email = email }) model

        EnteredPassword password ->
            updateForm (\form -> { form | password = password }) model

        CompletedLogin (Err error) ->
           let
              _ = Debug.log "tje errro" error
           in
           case error of
               Http.Detailed.BadStatus metadata body ->
                 let
                   md =  
                     case Json.Decode.decodeString decoderChangeset body of
                       Ok errorBody ->
                           let
                             dictComp = Dict.map (\k b -> List.map (\c -> (k,c)) b ) errorBody.error
                             values = Dict.values dictComp
                             listClean = List.concat values
                             list = List.map (\(a,b) -> a++": "++ b) listClean

                             listStr = List.map (\(a,b) -> a++": " ++b) listClean
                           in

                          {model | modalLoginResp = Just listStr}

                       Err error2 ->
                          {model | modalLoginResp = Just [body]}
                 in
                 ({md | modalLogin = Modal.shown, loginToken = Nothing}, resetCaptcha "recaptcha")

               Http.Detailed.Timeout ->
                  let
                   md = {model | updatePassResp = Just ["server timeout please try later"]}
                 in
                 ({ md | modalVisibility = Modal.shown }, resetCaptcha "recaptcha")
               _ ->
                 (model, Cmd.none)


        CompletedLogin (Ok (metadata, resp)) ->
            case resp.viewer of 
               Just viewer -> 
                   let
                     _ = Debug.log "viewr"
                   in
                 ( model, Cmd.batch [Viewer.store viewer, Navigat.load (Route.routeToString Route.NewArticle )] )
               Nothing ->
                 let
                     _ = Debug.log "No viewer"
                 in
                 case resp.loginToken of 
                     Just token ->
                         ({model | loginToken = Just token, modalLogin = Modal.shown},resetCaptcha "recaptcha")
                     Nothing ->
                         (model, resetCaptcha "recaptcha")


        CompletedLogin2fa (Err error) ->
           let
              _ = Debug.log "t2fa errro" error
           in
           case error of
               Http.Detailed.BadStatus metadata body ->
                 let
                   md =  
                     case Json.Decode.decodeString decoderChangeset body of
                       Ok errorBody ->
                           let
                             dictComp = Dict.map (\k b -> List.map (\c -> (k,c)) b ) errorBody.error
                             values = Dict.values dictComp
                             listClean = List.concat values
                             list = List.map (\(a,b) -> a++": "++ b) listClean

                             listStr = List.map (\(a,b) -> a++": " ++b) listClean
                           in

                          {model | modalLoginResp = Just listStr, loginToken = Nothing}

                       Err error2 ->
                          {model | modalLoginResp = Just [body], loginToken = Nothing}
                 in
                 ({md | modalLogin = Modal.shown}, resetCaptcha "recaptcha")

               Http.Detailed.Timeout ->
                  let
                   md = {model | updatePassResp = Just ["server timeout please try later"]}
                 in
                 ({ md | modalVisibility = Modal.shown }, resetCaptcha "recaptcha")
               _ ->
                 (model, Cmd.none)


        CompletedLogin2fa (Ok (metadata, resp)) ->
            case resp.viewer of 
               Just viewer -> 
                   let
                     _ = Debug.log "viewr"
                   in
                 ( model, Cmd.batch [Viewer.store viewer, Navigat.load (Route.routeToString Route.NewArticle )] )
               Nothing ->
                 let
                     _ = Debug.log "No viewer"
                 in
                 case resp.loginToken of 
                     Just token ->
                         ({model | loginToken = Just token, modalLogin = Modal.shown}, resetCaptcha "recaptcha")
                     Nothing ->
                         (model,  resetCaptcha "recaptcha")



        Ready _ ->
            ( model, Cmd.none)
        
        Sub ->
            let
                _ = Debug.log "adfaf" "adsa"
            in
            (model, Cmd.none) 
        GotSession session ->
            ( { model | session = session }
            , Route.replaceUrl (Session.navKey session) Route.Home
            )
        
        SetRecaptchaToken token ->
            ({model | recaptchaToken = Just token}, Cmd.none)


{-| Helper function for `update`. Updates the form and returns Cmd.none.
Useful for recording form fields!
-}
updateForm : (Form -> Form) -> Model -> ( Model, Cmd Msg )
updateForm transform model =
    ( { model | form = transform model.form }, Cmd.none )

viewLogin : Model  -> Html Msg
viewLogin model   =
   case model.loginToken of
     Just token ->
         Grid.container []
             [
               Modal.config CloseModalLogin
                 |> Modal.small
                 |> Modal.h5 [] [ text "Google Authenticator 2FA" ]
                 |> Modal.body []
                     [
                        Html.form[]
                        [
                            div[class "form-group"]
                            [
                                label[attribute "for" "token"][text "authenticator token"]
                            ,   input[class "form-control", id "token", onInput TokenLoginInput] []
                            ,   small[class "form-text text-muted"][text "Enter the one-time code found in your authenticator app to sign in to GREEKCOIN"]
                            ]    
                        ]
                     ]
                 |> Modal.footer []
                    [ Button.button
                        [ Button.outlinePrimary
                        , Button.attrs [ onClick SendLoginTokens  ]
                        ]
                        [ text "Enter"]
                    ]
                 |> Modal.view model.modalLogin
             ]

     Nothing ->
       case model.modalLoginResp of
           Just resp ->
             Grid.container []
             [
               Modal.config CloseModalLogin
                 |> Modal.small
                 |> Modal.h5 [] [ text "Invalid Code" ]
                 |> Modal.body []
                     (List.map (\error -> text error) resp)
                 |> Modal.footer []
                    [ Button.button
                        [ Button.outlinePrimary
                        , Button.attrs [ onClick CloseModalLogin  ]
                        ]
                        [ text "Ok"]
                    ]
                 |> Modal.view model.modalLogin
             ]
           Nothing ->
               div[][]


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
       Sub.batch
         [ Session.changes GotSession (Session.navKey model.session)
         , setRecaptchaToken SetRecaptchaToken
         ] 



-- FORM

type TrimmedForm
    = Trimmed Form


{-| When adding a variant here, add it to `fieldsToValidate` too!
-}
type ValidatedField
    = Email
    | Password


fieldsToValidate : List ValidatedField
fieldsToValidate =
    [ Email
    , Password
    ]


{-| Trim the form and validate its fields. If there are problems, report them!
-}
validate : Model -> Form -> Result (List Problem) TrimmedForm
validate model form =
    let
        trimmedForm =
            trimFields form
    in
    case List.concatMap (validateField trimmedForm) fieldsToValidate of
        [] ->
            case model.recaptchaToken of 
               Just token -> 
                  Ok trimmedForm
               Nothing ->
                  Err [(CaptchaError "Robot test not passed")]

        problems ->
            Err problems


validateField : TrimmedForm -> ValidatedField -> List Problem
validateField (Trimmed form) field =
    List.map (InvalidEntry field) <|
        case field of
            Email ->
                if String.isEmpty form.email then
                    [ "email can't be blank." ]

                else
                    []

            Password ->
                if String.isEmpty form.password then
                    [ "password can't be blank." ]

                else
                    []


{-| Don't trim while the user is typing! That would be super annoying.
Instead, trim only on submit.
-}
trimFields : Form -> TrimmedForm
trimFields form =
    Trimmed
        { email = String.trim form.email
        , password = String.trim form.password
        }

-- HTTP

login : TrimmedForm ->  String -> Maybe Viewer  -> Cmd Msg
login (Trimmed form) token viewer= 
       let
             user =
                 Encode.object
                     [ ( "email", Encode.string form.email )
                     , ( "password", Encode.string form.password )
                     , ( "captcha_token", Encode.string token) 
                     ]

             body =
                 Encode.object [ ( "credential", user ) ]
                     |> Http.jsonBody
         in
   Http.request
    {
     headers =  []
    , method = "POST"
    , url = (getBaseUrl ++ "/api/v1/users/login")
    , body =  body
    , expect = Http.Detailed.expectJson  CompletedLogin (decoderLoginResp viewer)

    , timeout = Nothing
    , tracker = Nothing
    }

login2fa : Model -> Cmd Msg
login2fa model= 
  case model.loginToken of 
    Just token ->
       let
             user =
                 Encode.object
                     [ ( "token", Encode.string model.authToken )
                     , ( "login_token", Encode.string token )
                     ]

             body = user
                    |> Http.jsonBody
         in
     Http.request
      {
       headers =  []
      , method = "POST"
      , url = (getBaseUrl ++ "/api/v1/user/2fa/login/validate")
      , body =  body
      , expect = Http.Detailed.expectJson  CompletedLogin2fa (decoderLoginResp (Session.viewer model.session))
  
      , timeout = Nothing
      , tracker = Nothing
      }
    Nothing ->
        Cmd.none


type alias LoginResp = 
    {
        loginToken : Maybe String
    ,   viewer : Maybe Viewer
    }
    
decoderLoginResp :Maybe Viewer -> Decoder LoginResp
decoderLoginResp viewer = 
    Json.Decode.succeed LoginResp
    |> Json.Decode.Pipeline.required "login_token" (nullable string)
    |> Json.Decode.Pipeline.required "user" (nullable (decoderFromCred (Viewer.decoderApi viewer ))) 

decoderFromCred : Decoder (Cred -> a) -> Decoder a
decoderFromCred decoder =
    Json.Decode.map2 (\fromCred cred -> fromCred cred)
        decoder
        credDecoder

credDecoder : Decoder Cred
credDecoder =
    Json.Decode.succeed Cred
        |> Json.Decode.Pipeline.required "username" Username.decoder
        |> Json.Decode.Pipeline.required "token" Json.Decode.string

-- EXPORT

toSession : Model -> Session
toSession model =
    model.session
